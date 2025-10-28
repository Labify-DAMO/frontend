//
//  WasteSummaryView.swift
//  Labify
//
//  Created by F_S on 10/24/25.
//

import SwiftUI

struct WasteSummaryView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var wasteViewModel = WasteViewModel()
    @StateObject private var labViewModel = LabViewModel()
    
    let memo: String
    let aiResult: AIClassifyResponse?
    let manualCategory: String?
    let onRegistrationComplete: (() -> Void)?  // ✅ 추가
    
    // ✅ 수정 가능한 필드들
    @State private var weight: Double
    @State private var selectedCategory: String = ""
    @State private var selectedWasteType: String = ""
    @State private var selectedUnit: String = ""
    
    @State private var selectedLab: Lab?
    @State private var showingLabSelector = false
    @State private var showingWeightEditor = false
    @State private var availableUntil = Date().addingTimeInterval(30 * 24 * 60 * 60)
    @State private var showingDatePicker = false
    @State private var isRegistering = false
    @State private var showingSuccessAlert = false
    @State private var registeredWaste: DisposalDetail?
    
    init(
        weight: Double,
        unit: String,
        memo: String,
        aiResult: AIClassifyResponse?,
        manualCategory: String?,
        onRegistrationComplete: (() -> Void)? = nil  // ✅ 추가
    ) {
        self._weight = State(initialValue: weight)
        self.memo = memo
        self.aiResult = aiResult
        self.manualCategory = manualCategory
        self.onRegistrationComplete = onRegistrationComplete  // ✅ 추가
    }
    
    private var canRegister: Bool {
        selectedLab != nil && !selectedCategory.isEmpty && !selectedWasteType.isEmpty && weight > 0
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 실험실 선택
                    labSelectionSection
                    
                    // ✅ AI 분류 결과 (읽기 전용) - AI 사용한 경우만
                    if let result = aiResult {
                        aiResultSection(result: result)
                    }
                    
                    // ✅ 폐기물 정보 (수정 가능)
                    wasteInfoEditSection
                    
                    // 보관 기한
                    availableUntilSection
                    
                    // 메모 (있는 경우)
                    if !memo.isEmpty {
                        memoSection
                    }
                }
                .padding(20)
                .padding(.bottom, 100)
            }
            .background(Color(red: 249/255, green: 250/255, blue: 252/255))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.primary)
                            .font(.system(size: 17, weight: .semibold))
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("폐기물 등록 확인")
                        .font(.system(size: 17, weight: .semibold))
                }
            }
            .safeAreaInset(edge: .bottom) {
                registerButton
            }
            .sheet(isPresented: $showingLabSelector) {
                LabSelectorBottomSheet(
                    labs: labViewModel.labs,
                    selectedLab: $selectedLab
                )
            }
            .sheet(isPresented: $showingDatePicker) {
                DatePickerSheet(selectedDate: $availableUntil)
            }
            .sheet(isPresented: $showingWeightEditor) {
                WeightEditorSheet(weight: $weight, unit: $selectedUnit)
            }
            .task {
                await loadData()
                
                // ✅ AI 분류 결과로 초기값 설정
                if let aiResult = aiResult {
                    selectedCategory = aiResult.coarse
                    selectedUnit = aiResult.unit ?? "piece"
                    
                    // fine (waste type)은 API 응답 후 설정
                    if !wasteViewModel.filteredWasteTypes.isEmpty {
                        selectedWasteType = aiResult.fine
                    }
                }
            }
            .onChange(of: selectedCategory) { _, newCategory in
                // 카테고리 변경시 waste type 목록 업데이트
                Task {
                    await wasteViewModel.fetchWasteTypes(categoryName: newCategory)
                    // 첫 번째 타입으로 자동 선택
                    if let firstType = wasteViewModel.filteredWasteTypes.first {
                        selectedWasteType = firstType.name
                    }
                }
            }
            .alert("등록 완료", isPresented: $showingSuccessAlert) {
                Button("확인") {
                    dismiss()
                }
            } message: {
                if let waste = registeredWaste {
                    Text("폐기물이 성공적으로 등록되었습니다.\n등록 ID: \(waste.id)")
                }
            }
            .alert("오류", isPresented: $wasteViewModel.showError) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(wasteViewModel.errorMessage ?? "알 수 없는 오류가 발생했습니다.")
            }
        }
    }
    
    // MARK: - 실험실 선택 섹션
    private var labSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "building.2")
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
                
                Text("실험실")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            Button(action: {
                showingLabSelector = true
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        if let lab = selectedLab {
                            Text(lab.name)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                            Text(lab.location)
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        } else {
                            Text("실험실을 선택하세요")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(selectedLab != nil ? Color(red: 30/255, green: 59/255, blue: 207/255).opacity(0.3) : Color.gray.opacity(0.15), lineWidth: 1.5)
                )
            }
        }
    }
    
    // MARK: - ✅ AI 분류 결과 섹션 (읽기 전용)
    private func aiResultSection(result: AIClassifyResponse) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 147/255, green: 112/255, blue: 219/255))
                
                Text("AI 분류 결과")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("참고용")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(red: 147/255, green: 112/255, blue: 219/255))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(red: 147/255, green: 112/255, blue: 219/255).opacity(0.1))
                    )
            }
            
            VStack(spacing: 0) {
                AIInfoRow(title: "대분류", value: result.coarse)
                Divider().padding(.leading, 40)
                AIInfoRow(title: "세분류", value: result.fine)
                Divider().padding(.leading, 40)
                AIInfoRow(title: "권장 단위", value: result.unit ?? "미지정")
                
                if result.is_bio {
                    Divider().padding(.leading, 40)
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.orange)
                            .frame(width: 24)
                        
                        Text("생물학적 위험")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.orange)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                
                if result.is_ocr, let ocrText = result.ocr_text, !ocrText.isEmpty {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                            Text("감지된 텍스트")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        
                        Text(ocrText)
                            .font(.system(size: 14))
                            .foregroundColor(.primary)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.06))
                            )
                            .padding(.horizontal, 16)
                            .padding(.bottom, 12)
                    }
                }
            }
            .background(Color.white)
            .cornerRadius(12)
        }
    }
    
    // MARK: - ✅ 폐기물 정보 편집 섹션
    private var wasteInfoEditSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "pencil.circle")
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
                
                Text("폐기물 정보")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("수정 가능")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(red: 30/255, green: 59/255, blue: 207/255).opacity(0.1))
                    )
            }
            
            VStack(spacing: 0) {
                // 카테고리
                EditableRow(
                    icon: "square.grid.2x2",
                    title: "카테고리",
                    isFirst: true
                ) {
                    Menu {
                        ForEach(wasteViewModel.wasteCategories) { category in
                            Button(action: {
                                selectedCategory = category.name
                            }) {
                                HStack {
                                    Text(category.name)
                                    if selectedCategory == category.name {
                                        Spacer()
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text(selectedCategory.isEmpty ? "선택" : selectedCategory)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(selectedCategory.isEmpty ? .secondary : .primary)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Divider().padding(.leading, 52)
                
                // 타입
                EditableRow(
                    icon: "list.bullet.rectangle",
                    title: "타입"
                ) {
                    Menu {
                        ForEach(wasteViewModel.filteredWasteTypes) { type in
                            Button(action: {
                                selectedWasteType = type.name
                                selectedUnit = type.unit // 타입 변경시 단위도 자동 업데이트
                            }) {
                                HStack {
                                    Text(type.name)
                                    if selectedWasteType == type.name {
                                        Spacer()
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text(selectedWasteType.isEmpty ? "선택" : selectedWasteType)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(selectedWasteType.isEmpty ? .secondary : .primary)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                    }
                    .disabled(selectedCategory.isEmpty)
                }
                
                Divider().padding(.leading, 52)
                
                // 무게
                EditableRow(
                    icon: "scalemass",
                    title: "무게"
                ) {
                    Button(action: {
                        showingWeightEditor = true
                    }) {
                        HStack(spacing: 6) {
                            Text(String(format: "%.1f %@", weight, selectedUnit))
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.primary)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Divider().padding(.leading, 52)
                
                // 단위
                EditableRow(
                    icon: "ruler",
                    title: "단위",
                    isLast: true
                ) {
                    Menu {
                        ForEach(WasteUnit.allCases) { unit in
                            Button(action: {
                                selectedUnit = unit.rawValue
                            }) {
                                HStack {
                                    Text(unit.rawValue)
                                    if selectedUnit == unit.rawValue {
                                        Spacer()
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text(selectedUnit)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.primary)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .background(Color.white)
            .cornerRadius(12)
        }
    }
    
    // MARK: - 보관 기한 섹션
    private var availableUntilSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
                
                Text("보관 기한")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            Button(action: {
                showingDatePicker = true
            }) {
                HStack {
                    Text(formatDate(availableUntil))
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - 메모 섹션
    private var memoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "note.text")
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
                
                Text("메모")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            Text(memo)
                .font(.system(size: 15))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(Color.white)
                .cornerRadius(12)
        }
    }
    
    // MARK: - 등록 버튼
    private var registerButton: some View {
        Button(action: {
            Task {
                await registerWaste()
            }
        }) {
            HStack(spacing: 12) {
                if isRegistering {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                    Text("폐기물 등록하기")
                        .font(.system(size: 18, weight: .semibold))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: canRegister ? [
                        Color(red: 30/255, green: 59/255, blue: 207/255),
                        Color(red: 113/255, green: 100/255, blue: 230/255)
                    ] : [Color.gray.opacity(0.5), Color.gray.opacity(0.5)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(14)
            .shadow(color: canRegister ? Color(red: 30/255, green: 59/255, blue: 207/255).opacity(0.3) : Color.clear, radius: 8, y: 4)
        }
        .disabled(!canRegister || isRegistering)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white)
    }
    
    // MARK: - 데이터 로드
    private func loadData() async {
        await labViewModel.fetchLabs()
        await wasteViewModel.fetchWasteCategories()
        
        // ✅ AI 결과가 있으면 해당 카테고리의 waste types 로드 (수정됨)
        if let aiResult = aiResult {
            await wasteViewModel.fetchWasteTypes(categoryName: aiResult.coarse)
            selectedWasteType = aiResult.fine
        }
    }
    
    // MARK: - ✅ 폐기물 등록
    private func registerWaste() async {
        guard let lab = selectedLab else { return }
        
        isRegistering = true
        
        let result = await wasteViewModel.registerWaste(
            labId: lab.id,
            wasteTypeName: selectedWasteType,
            weight: weight,
            unit: selectedUnit,
            memo: memo.isEmpty ? nil : memo,
            availableUntil: formatDateForAPI(availableUntil)
        )
        
        isRegistering = false
        
        if let disposal = result {
            registeredWaste = disposal
            showingSuccessAlert = true
        }
    }
    
    // MARK: - Helper Functions
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    private func formatDateForAPI(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        WasteSummaryView(
            weight: 2.5,
            unit: "kg",
            memo: "냉장 보관 필요",
            aiResult: AIClassifyResponse(
                coarse: "sharps",
                fine: "syringe",
                unit: "piece",
                is_bio: true,
                is_ocr: true,
                ocr_text: "USE SINGLE FOR"
            ),
            manualCategory: nil
        )
    }
}
