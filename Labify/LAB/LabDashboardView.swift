//
//  LabDashboardView.swift
//  Labify
//
//  Created by F_s on 9/22/25.
//

import SwiftUI

struct LabDashboardView: View {
    @StateObject private var viewModel = LabViewModel()
    @State private var selectedLabIds: Set<Int> = []
    @State private var showingLabSelector = false
    @State private var showingLabRequestSheet = false
    @State private var todayPickupCount = 3
    @State private var previewCount = 2
    @State private var estimatedRoute = "35분"
    @State private var showingWasteRegistration = false
    @State private var showingPickupRequest = false
    @State private var recentItems: [WasteItem] = [
        WasteItem(name: "감염성", weight: 1.2, time: "10:12"),
        WasteItem(name: "화학", weight: 2.6, time: "10:01"),
        WasteItem(name: "감염성", weight: 1.2, time: "09:12"),
        WasteItem(name: "감염성", weight: 1.2, time: "08:12"),
        WasteItem(name: "감염성", weight: 1.2, time: "08:00")
    ]
    
    var selectedLabsText: String {
        if selectedLabIds.isEmpty {
            return "전체"
        } else if selectedLabIds.count == viewModel.labs.count {
            return "전체"
        } else if selectedLabIds.count == 1,
                  let labId = selectedLabIds.first,
                  let lab = viewModel.labs.first(where: { $0.id == labId }) {
            return lab.name
        } else {
            return "\(selectedLabIds.count)개 실험실"
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 실험실 선택 영역
                    HStack(spacing: 12) {
                        Button(action: {
                            showingLabSelector = true
                        }) {
                            HStack(spacing: 8) {
                                Text(selectedLabsText)
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                        }
                        
                        Button(action: {
                            showingLabRequestSheet = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
                                .padding(8)
                                .background(Color(red: 244/255, green: 247/255, blue: 255/255))
                                .cornerRadius(12)
                        }
                    }
                    
                    // 오늘 수거 예정 카드
                    VStack(spacing: 16) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("오늘 수거 예정")
                                    .font(.system(size: 15))
                                    .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
                                Text("\(todayPickupCount)건")
                                    .font(.system(size: 32, weight: .bold))
                            }
                            Spacer()
                            Button(action: {
                                showingPickupRequest = true
                            }) {
                                Text("수거 요청")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 28)
                                    .padding(.vertical, 14)
                                    .background(
                                        LinearGradient(
                                            colors: [Color(red: 30/255, green: 59/255, blue: 207/255),
                                                     Color(red: 113/255, green: 100/255, blue: 230/255)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .cornerRadius(24)
                            }
                        }
                    }
                    .padding(20)
                    .background(Color(red: 244/255, green: 247/255, blue: 255/255))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(red: 30/255, green: 59/255, blue: 207/255).opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 2)
                    
                    // 내일 미리보기 카드
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("내일 미리보기")
                                    .font(.system(size: 15))
                                    .foregroundColor(.gray)
                                Text("\(previewCount)건")
                                    .font(.system(size: 32, weight: .bold))
                            }
                            Spacer()
                            Text("루트 예측 \(estimatedRoute)")
                                .font(.system(size: 15))
                                .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
                        }
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                    
                    // 폐기물 등록 및 등록 이력 버튼
                    HStack(spacing: 12) {
                        Button(action: {
                            showingWasteRegistration = true
                        }) {
                            Text("폐기물 등록")
                                .font(.system(size: 17, weight: .semibold))
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
                                .shadow(color: Color(red: 30/255, green: 59/255, blue: 207/255).opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        
                        Button(action: {}) {
                            Text("등록 이력")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(Color.white)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.gray.opacity(0.25), lineWidth: 1.5)
                                )
                                .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 2)
                        }
                    }
                    
                    // 보관 기한 임박 경고
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                            .font(.system(size: 16))
                        Text("보관 기한 임박 항목 1건 (D-1)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.red)
                        Spacer()
                    }
                    .padding(.vertical, 4)
                    
                    // 오늘 등록된 항목
                    VStack(alignment: .center, spacing: 16) {
                        Text("오늘 등록된 항목")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color(red: 244/255, green: 247/255, blue: 255/255))
                            .cornerRadius(12)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ], spacing: 12) {
                            ForEach(recentItems) { item in
                                VStack(spacing: 8) {
                                    Text(item.name)
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("\(String(format: "%.1f", item.weight))kg")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                    Text(item.time)
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .background(Color.white)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
                            }
                        }
                    }
                }
                .padding(20)
                .padding(.bottom, 100)
            }
            .background(Color.white)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("대시보드")
                        .font(.system(size: 17, weight: .semibold))
                }
            }
            .sheet(isPresented: $showingWasteRegistration) {
                LabRegistrationView()
            }
            .sheet(isPresented: $showingPickupRequest) {
                PickupRequestView()
            }
            .sheet(isPresented: $showingLabSelector) {
                LabSelectorSheet(
                    labs: viewModel.labs,
                    selectedLabIds: $selectedLabIds
                )
            }
            .sheet(isPresented: $showingLabRequestSheet) {
                LabRequestSheet(viewModel: viewModel)
            }
            .task {
                await viewModel.fetchLabs()
                // 초기 로드 시 전체 선택
                if selectedLabIds.isEmpty {
                    selectedLabIds = Set(viewModel.labs.map { $0.id })
                }
            }
            .alert("오류", isPresented: $viewModel.showError) {
                Button("확인", role: .cancel) {}
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }
}

// MARK: - Lab Selector Sheet
struct LabSelectorSheet: View {
    @Environment(\.dismiss) private var dismiss
    let labs: [Lab]
    @Binding var selectedLabIds: Set<Int>
    @State private var tempSelectedLabIds: Set<Int>
    
    init(labs: [Lab], selectedLabIds: Binding<Set<Int>>) {
        self.labs = labs
        self._selectedLabIds = selectedLabIds
        self._tempSelectedLabIds = State(initialValue: selectedLabIds.wrappedValue)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 전체 선택 버튼
                Button(action: {
                    if tempSelectedLabIds.count == labs.count {
                        tempSelectedLabIds.removeAll()
                    } else {
                        tempSelectedLabIds = Set(labs.map { $0.id })
                    }
                }) {
                    HStack {
                        Text("전체")
                            .font(.system(size: 17))
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: tempSelectedLabIds.count == labs.count ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(tempSelectedLabIds.count == labs.count ? Color(red: 30/255, green: 59/255, blue: 207/255) : .gray)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color(red: 244/255, green: 247/255, blue: 255/255))
                }
                
                Divider()
                
                // 실험실 목록
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(labs) { lab in
                            Button(action: {
                                if tempSelectedLabIds.contains(lab.id) {
                                    tempSelectedLabIds.remove(lab.id)
                                } else {
                                    tempSelectedLabIds.insert(lab.id)
                                }
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
                                    Image(systemName: tempSelectedLabIds.contains(lab.id) ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(tempSelectedLabIds.contains(lab.id) ? Color(red: 30/255, green: 59/255, blue: 207/255) : .gray)
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
                
                // 하단 버튼
                VStack(spacing: 12) {
                    Button(action: {
                        selectedLabIds = tempSelectedLabIds
                        dismiss()
                    }) {
                        Text("적용")
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
                    .disabled(tempSelectedLabIds.isEmpty)
                    .opacity(tempSelectedLabIds.isEmpty ? 0.5 : 1)
                }
                .padding(20)
                .background(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: -5)
            }
            .navigationTitle("실험실 선택")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Lab Request Sheet
struct LabRequestSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: LabViewModel
    @State private var labName = ""
    @State private var location = ""
    @State private var isSubmitting = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("실험실 이름", text: $labName)
                    TextField("위치 (예: Seoul A-101)", text: $location)
                } header: {
                    Text("실험실 정보")
                } footer: {
                    Text("시설 관리자에게 실험실 개설 요청이 전송됩니다.")
                }
            }
            .navigationTitle("실험실 추가 요청")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("요청") {
                        Task {
                            await submitRequest()
                        }
                    }
                    .disabled(labName.isEmpty || location.isEmpty || isSubmitting)
                }
            }
            .disabled(isSubmitting)
        }
    }
    
    private func submitRequest() async {
        isSubmitting = true
        
        // TODO: facilityId와 managerId를 실제 값으로 교체
        let success = await viewModel.requestLabCreation(
            facilityId: 1,
            name: labName,
            location: location,
            managerId: 1
        )
        
        isSubmitting = false
        
        if success {
            dismiss()
        }
    }
}

struct WasteItem: Identifiable {
    let id = UUID()
    let name: String
    let weight: Double
    let time: String
}

#Preview {
    LabDashboardView()
}
