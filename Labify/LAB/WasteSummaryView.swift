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
    
    let weight: Double
    let unit: String
    let memo: String
    let aiResult: AIClassifyResponse?
    let manualCategory: String?
    
    @State private var selectedLab: Lab?
    @State private var showingLabSelector = false
    @State private var availableUntil = Date().addingTimeInterval(30 * 24 * 60 * 60) // 기본 30일 후
    @State private var showingDatePicker = false
    @State private var isRegistering = false
    @State private var userInfo: UserInfo?
    @State private var showingSuccessAlert = false
    @State private var registeredWaste: DisposalDetail?
    
    private var categoryText: String {
        if let manual = manualCategory, !manual.isEmpty {
            return manual
        } else if let ai = aiResult {
            return ai.displayCoarse
        }
        return "미분류"
    }
    
    private var canRegister: Bool {
        selectedLab != nil && userInfo != nil
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 실험실 선택
                    labSelectionSection
                    
                    // 폐기물 정보 요약
                    wasteInfoSection
                    
                    // 보관 기한
                    availableUntilSection
                    
                    // AI 분류 결과 (있는 경우)
                    if let result = aiResult {
                        aiResultSection(result: result)
                    }
                    
                    // 메모 (있는 경우)
                    if !memo.isEmpty {
                        memoSection
                    }
                }
                .padding(20)
                .padding(.bottom, 100)
            }
            .background(Color.white)
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
            .task {
                await loadData()
            }
            .alert("등록 완료", isPresented: $showingSuccessAlert) {
                Button("확인") {
                    // LabHistoryView로 이동 (임시로 dismiss)
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
            Text("실험실 선택")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            Button(action: {
                showingLabSelector = true
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        if let lab = selectedLab {
                            Text(lab.name)
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(.primary)
                            Text(lab.location)
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        } else {
                            Text("실험실을 선택하세요")
                                .font(.system(size: 17))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(selectedLab != nil ? Color(red: 30/255, green: 59/255, blue: 207/255).opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 1.5)
                )
            }
        }
    }
    
    // MARK: - 폐기물 정보 요약
    private var wasteInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("폐기물 정보")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            VStack(spacing: 16) {
                InfoRow(icon: "square.grid.2x2", title: "분류", value: categoryText)
                Divider().padding(.horizontal, 8)
                InfoRow(icon: "scalemass", title: "무게", value: "\(String(format: "%.1f", weight)) \(unit)")
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
            )
        }
    }
    
    // MARK: - 보관 기한 섹션
    private var availableUntilSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("보관 기한")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            Button(action: {
                showingDatePicker = true
            }) {
                HStack {
                    Image(systemName: "calendar")
                        .font(.system(size: 18))
                        .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
                    
                    Text(formatDate(availableUntil))
                        .font(.system(size: 17))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            }
        }
    }
    
    // MARK: - AI 분류 결과 섹션
    private func aiResultSection(result: AIClassifyResponse) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 18))
                    .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
                
                Text("AI 분류 상세")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            VStack(spacing: 12) {
                InfoRow(icon: "list.bullet.rectangle", title: "세분류", value: result.displayFine)
                Divider().padding(.horizontal, 8)
                InfoRow(
                    icon: result.is_bio ? "cross.circle.fill" : "cross.circle",
                    title: "생물학적 위험",
                    value: result.is_bio ? "예" : "아니오"
                )
                
                if result.is_ocr, let ocrText = result.ocr_text, !ocrText.isEmpty {
                    Divider().padding(.horizontal, 8)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            Text("감지된 텍스트")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        
                        Text(ocrText)
                            .font(.system(size: 15))
                            .foregroundColor(.primary)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.08))
                            )
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(red: 244/255, green: 247/255, blue: 255/255))
            )
        }
    }
    
    // MARK: - 메모 섹션
    private var memoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("메모")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            Text(memo)
                .font(.system(size: 15))
                .foregroundColor(.primary)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
                )
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
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    colors: [Color(red: 30/255, green: 59/255, blue: 207/255),
                             Color(red: 113/255, green: 100/255, blue: 230/255)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(16)
        }
        .disabled(!canRegister || isRegistering)
        .opacity(canRegister && !isRegistering ? 1.0 : 0.5)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white)
    }
    
    // MARK: - 데이터 로드
    private func loadData() async {
        // 실험실 목록 조회
        await labViewModel.fetchLabs()
        
        // 사용자 정보 조회
        if let token = UserDefaults.standard.string(forKey: "accessToken") {
            do {
                userInfo = try await AuthService.getUserInfo(token: token)
            } catch {
                print("❌ 사용자 정보 조회 실패: \(error)")
            }
        }
    }
    
    // MARK: - 폐기물 등록
    private func registerWaste() async {
        guard let lab = selectedLab,
              let user = userInfo else {
            return
        }
        
        isRegistering = true
        
        let result = await wasteViewModel.registerWaste(
            labId: lab.id,
            wasteTypeId: 1, // 임시 고정값
            weight: weight,
            unit: unit,
            memo: memo.isEmpty ? nil : memo,
            availableUntil: formatDateForAPI(availableUntil),
            createdById: user.userId
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

// MARK: - Info Row Component
struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Lab Selector Bottom Sheet
struct LabSelectorBottomSheet: View {
    @Environment(\.dismiss) private var dismiss
    let labs: [Lab]
    @Binding var selectedLab: Lab?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(labs) { lab in
                        Button(action: {
                            selectedLab = lab
                            dismiss()
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(lab.name)
                                        .font(.system(size: 17, weight: .medium))
                                        .foregroundColor(.primary)
                                    Text(lab.location)
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                
                                if selectedLab?.id == lab.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                        }
                        
                        if lab.id != labs.last?.id {
                            Divider()
                                .padding(.leading, 20)
                        }
                    }
                }
            }
            .navigationTitle("실험실 선택")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Date Picker Sheet
struct DatePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDate: Date
    @State private var tempDate: Date
    
    init(selectedDate: Binding<Date>) {
        self._selectedDate = selectedDate
        self._tempDate = State(initialValue: selectedDate.wrappedValue)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                DatePicker(
                    "보관 기한",
                    selection: $tempDate,
                    in: Date()...,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding(20)
                
                Spacer()
                
                Button(action: {
                    selectedDate = tempDate
                    dismiss()
                }) {
                    Text("확인")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 30/255, green: 59/255, blue: 207/255),
                                         Color(red: 113/255, green: 100/255, blue: 230/255)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(12)
                }
                .padding(20)
            }
            .navigationTitle("보관 기한 선택")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    NavigationStack {
        WasteSummaryView(
            weight: 2.5,
            unit: "kg",
            memo: "냉장 보관 필요",
            aiResult: nil,
            manualCategory: "화학"
        )
    }
}
