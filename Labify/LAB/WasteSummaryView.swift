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
    let onRegistrationComplete: (() -> Void)?
    
    @State private var selectedLab: Lab?
    @State private var showingLabSelector = false
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
        onRegistrationComplete: (() -> Void)? = nil
    ) {
        self.weight = weight
        self.unit = unit
        self.memo = memo
        self.aiResult = aiResult
        self.manualCategory = manualCategory
        self.onRegistrationComplete = onRegistrationComplete
    }
    
    private var canRegister: Bool {
        selectedLab != nil && aiResult != nil && weight > 0
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 1. 실험실 선택
                    labSelectionSection
                    
                    // 2. 보관 기한
                    availableUntilSection
                    
                    // 3. 폐기물 정보 (AI 결과 포함)
                    if let result = aiResult {
                        wasteInfoSection(result: result)
                    }
                    
                    // 4. 메모 (있는 경우)
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
            .task {
                await labViewModel.fetchLabs()
            }
            .alert("등록 완료", isPresented: $showingSuccessAlert) {
                Button("확인") {
                    onRegistrationComplete?()
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
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)
            
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
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
            }
        }
    }
    
    // MARK: - 보관 기한 섹션
    private var availableUntilSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("보관 기한")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)
            
            Button(action: {
                showingDatePicker = true
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "calendar")
                        .font(.system(size: 16))
                        .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
                    
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
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
            }
        }
    }
    
    // MARK: - 폐기물 정보 섹션 (AI 결과 통합)
    private func wasteInfoSection(result: AIClassifyResponse) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 88/255, green: 86/255, blue: 214/255))
                
                Text("폐기물 정보")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            VStack(spacing: 0) {
                // 분류 (대분류)
                HStack(spacing: 12) {
                    Image(systemName: "square.grid.2x2")
                        .font(.system(size: 16))
                        .foregroundColor(Color(red: 88/255, green: 86/255, blue: 214/255))
                        .frame(width: 24)
                    
                    Text("분류")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .frame(width: 60, alignment: .leading)
                    
                    Spacer()
                    
                    Text(result.coarse)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                
                Divider().padding(.leading, 52)
                
                // 세분류
                HStack(spacing: 12) {
                    Image(systemName: "list.bullet.rectangle")
                        .font(.system(size: 16))
                        .foregroundColor(Color(red: 88/255, green: 86/255, blue: 214/255))
                        .frame(width: 24)
                    
                    Text("세분류")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .frame(width: 60, alignment: .leading)
                    
                    Spacer()
                    
                    Text(result.fine)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                
                Divider().padding(.leading, 52)
                
                // 무게
                HStack(spacing: 12) {
                    Image(systemName: "scalemass")
                        .font(.system(size: 16))
                        .foregroundColor(Color(red: 88/255, green: 86/255, blue: 214/255))
                        .frame(width: 24)
                    
                    Text("무게")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .frame(width: 60, alignment: .leading)
                    
                    Spacer()
                    
                    Text(String(format: "%.1f %@", weight, unit))
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                
                // 생물학적 위험 (is_bio가 true인 경우만)
                if result.is_bio {
                    Divider().padding(.leading, 52)
                    
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.shield.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Color(red: 88/255, green: 86/255, blue: 214/255))
                            .frame(width: 24)
                        
                        Text("생물학적 위험")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .frame(width: 60, alignment: .leading)
                        
                        Spacer()
                        
                        Text("⚠️ 주의 필요")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }
            }
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        }
    }
    
    // MARK: - 메모 섹션
    private var memoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("메모")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)
            
            Text(memo)
                .font(.system(size: 15))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
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
    
    // MARK: - 폐기물 등록
    private func registerWaste() async {
        guard let lab = selectedLab,
              let result = aiResult else { return }
        
        isRegistering = true
        
        // AI의 fine 값을 wasteTypeName으로 사용
        let disposal = await wasteViewModel.registerWaste(
            labId: lab.id,
            wasteTypeName: result.fine,
            weight: weight,
            unit: unit,
            memo: memo.isEmpty ? nil : memo,
            availableUntil: formatDateForAPI(availableUntil)
        )
        
        isRegistering = false
        
        if let disposal = disposal {
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
