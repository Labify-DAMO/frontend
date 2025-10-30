//
//  PickupRequestView.swift
//  Labify
//
//  Created by F_s on 10/14/25.
//

import SwiftUI

// MARK: - Lab 확장 (UI용 추가 정보)
extension Lab {
    var displayManager: String {
        // TODO: 실제 담당자 정보는 API에서 가져오기
        return "담당 관리자"
    }
    
    var displayPhone: String {
        // TODO: 실제 연락처 정보는 API에서 가져오기
        return "02-000-0000"
    }
}

struct PickupRequestView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var labViewModel = LabViewModel()
    
    @State private var searchText = ""
    @State private var selectedFilter = "9월"
    @State private var selectedLab: Lab?
    @State private var showingWasteSelection = false
    
    let filters = ["9월", "전체 지역"]
    
    var filteredLabs: [Lab] {
        if searchText.isEmpty {
            return labViewModel.labs
        } else {
            return labViewModel.labs.filter { lab in
                lab.name.localizedCaseInsensitiveContains(searchText) ||
                lab.location.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchSection
                filterSection
                labListSection
                
                Spacer()
            }
            .background(Color.white)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("등록")
                        .font(.system(size: 17, weight: .semibold))
                }
            }
            .safeAreaInset(edge: .bottom) {
                selectButton
            }
            .sheet(isPresented: $showingWasteSelection) {
                if let lab = selectedLab {
                    WasteSelectionView(
                        lab: lab,
                        labViewModel: labViewModel
                    )
                }
            }
            .task {
                await labViewModel.fetchLabs()
            }
            .alert("오류", isPresented: $labViewModel.showError) {
                Button("확인", role: .cancel) {}
            } message: {
                if let error = labViewModel.errorMessage {
                    Text(error)
                }
            }
            .overlay {
                if labViewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
        }
    }
    
    private var searchSection: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .padding(.leading, 16)
                
                TextField("실험실/부서 검색", text: $searchText)
                    .padding(.vertical, 14)
            }
            .background(Color(red: 0.96, green: 0.96, blue: 0.96))
            .cornerRadius(12)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
    
    private var filterSection: some View {
        HStack(spacing: 12) {
            ForEach(filters, id: \.self) { filter in
                PickupFilterButton(
                    title: filter,
                    isSelected: selectedFilter == filter
                ) {
                    selectedFilter = filter
                }
            }
            
            Spacer()
            
            Button(action: {
                // TODO: CSV 내보내기 기능
                print("CSV 내보내기")
            }) {
                Text("CSV 내보내기")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 30/255, green: 59/255, blue: 207/255),
                                     Color(red: 113/255, green: 100/255, blue: 230/255)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(20)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
    
    private var labListSection: some View {
        ScrollView {
            if filteredLabs.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "building.2")
                        .font(.system(size: 50))
                        .foregroundColor(.gray.opacity(0.5))
                    Text("등록된 실험실이 없습니다")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 100)
            } else {
                VStack(spacing: 12) {
                    ForEach(filteredLabs) { lab in
                        LabSelectionCard(
                            lab: lab,
                            isSelected: selectedLab?.id == lab.id
                        ) {
                            selectedLab = lab
                        }
                    }
                }
                .padding(20)
                .padding(.bottom, 100)
            }
        }
    }
    
    private var selectButton: some View {
        Button(action: {
            if selectedLab != nil {
                showingWasteSelection = true
            }
        }) {
            Text("선택하기")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(selectedLab == nil ? .gray : .primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color.white)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1.5)
                )
        }
        .disabled(selectedLab == nil)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white)
    }
}

// MARK: - Waste Selection View
struct WasteSelectionView: View {
    @Environment(\.dismiss) var dismiss
    let lab: Lab
    @ObservedObject var labViewModel: LabViewModel
    
    // ✅ WasteViewModel 대신 직접 상태 관리
    @State private var disposalItems: [DisposalItemData] = []
    @State private var isLoadingWastes = false
    @State private var wasteError: String?
    @State private var showWasteError = false
    
    @State private var selectedDate = Date()
    @State private var selectedWastes: Set<Int> = []
    @State private var showingDatePicker = false
    @State private var showSuccessAlert = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 실험실 정보
                labInfoSection
                
                // 수거 날짜 선택
                dateSelectionSection
                
                // 폐기물 목록
                wasteListSection
                
                Spacer()
            }
            .background(Color.white)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.primary)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("폐기물 선택")
                        .font(.system(size: 17, weight: .semibold))
                }
            }
            .safeAreaInset(edge: .bottom) {
                requestButton
            }
            .task {
                await loadDisposalItems()
            }
            .alert("성공", isPresented: $showSuccessAlert) {
                Button("확인") {
                    dismiss()
                }
            } message: {
                Text("수거 요청이 성공적으로 생성되었습니다.")
            }
            .alert("오류", isPresented: $showWasteError) {
                Button("확인", role: .cancel) {}
            } message: {
                if let error = wasteError {
                    Text(error)
                }
            }
            .overlay {
                if isLoadingWastes || labViewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
        }
    }
    
    private var labInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(lab.name)
                .font(.system(size: 18, weight: .semibold))
            HStack(spacing: 4) {
                Text(lab.displayManager)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                Text("·")
                    .foregroundColor(.gray)
                Text(lab.displayPhone)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color(red: 244/255, green: 247/255, blue: 255/255))
    }
    
    private var dateSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("수거 날짜")
                .font(.system(size: 16, weight: .semibold))
            
            Button(action: {
                withAnimation {
                    showingDatePicker.toggle()
                }
            }) {
                HStack {
                    Text(formattedDate)
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "calendar")
                        .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                )
            }
            
            if showingDatePicker {
                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .labelsHidden()
            }
        }
        .padding(20)
    }
    
    private var wasteListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("폐기물 목록")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Text("\(selectedWastes.count)개 선택")
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
            }
            .padding(.horizontal, 20)
            
            ScrollView {
                if disposalItems.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "tray")
                            .font(.system(size: 50))
                            .foregroundColor(.gray.opacity(0.5))
                        Text("등록된 폐기물이 없습니다")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 50)
                } else {
                    VStack(spacing: 12) {
                        ForEach(disposalItems) { waste in
                            WasteSelectionCard(
                                waste: waste,
                                isSelected: selectedWastes.contains(waste.id)
                            ) {
                                if selectedWastes.contains(waste.id) {
                                    selectedWastes.remove(waste.id)
                                } else {
                                    selectedWastes.insert(waste.id)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
        }
    }
    
    private var requestButton: some View {
        Button(action: {
            createPickupRequest()
        }) {
            Text("수거 요청")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    selectedWastes.isEmpty ?
                    LinearGradient(colors: [Color.gray, Color.gray], startPoint: .top, endPoint: .bottom) :
                    LinearGradient(
                        colors: [Color(red: 30/255, green: 59/255, blue: 207/255),
                                 Color(red: 113/255, green: 100/255, blue: 230/255)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(16)
        }
        .disabled(selectedWastes.isEmpty || labViewModel.isLoading)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: selectedDate)
    }
    
    private var formattedDateWithTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter.string(from: selectedDate)
    }
    
    // ✅ 폐기물 목록 로드 (LabService 사용)
    private func loadDisposalItems() async {
        guard let token = UserDefaults.standard.string(forKey: "accessToken") else {
            wasteError = "인증 토큰이 없습니다."
            showWasteError = true
            return
        }
        
        isLoadingWastes = true
        defer { isLoadingWastes = false }
        
        do {
            // LabService의 fetchDisposalItems 메서드 사용
            let response = try await WasteService.fetchDisposalItems(
                labId: lab.id,
                token: token
            )
            disposalItems = response.disposalItems
            print("✅ 폐기물 목록 조회 성공: \(disposalItems.count)개")
        } catch {
            wasteError = "폐기물 목록을 불러오는데 실패했습니다."
            showWasteError = true
            print("❌ 폐기물 목록 조회 실패: \(error)")
        }
    }
    
    private func createPickupRequest() {
        Task {
            let success = await labViewModel.createPickupRequest(
                labId: lab.id,
                requestDate: formattedDateWithTime,
                disposalItemIds: Array(selectedWastes)
            )
            
            if success {
                showSuccessAlert = true
            }
        }
    }
}

// MARK: - Filter Button
struct PickupFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(buttonBackground)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1.5)
                )
        }
    }
    
    private var buttonBackground: LinearGradient {
        if isSelected {
            return LinearGradient(
                colors: [Color(red: 30/255, green: 59/255, blue: 207/255),
                         Color(red: 113/255, green: 100/255, blue: 230/255)],
                startPoint: .top,
                endPoint: .bottom
            )
        } else {
            return LinearGradient(
                colors: [Color.white, Color.white],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}

// MARK: - Lab Selection Card
struct LabSelectionCard: View {
    let lab: Lab
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                Text(lab.name)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                HStack(spacing: 4) {
                    Text(lab.displayManager)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Text("·")
                        .foregroundColor(.gray)
                    Text(lab.displayPhone)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ?
                        Color(red: 30/255, green: 59/255, blue: 207/255) :
                        Color.gray.opacity(0.25),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
        }
    }
}

// MARK: - Waste Selection Card
struct WasteSelectionCard: View {
    let waste: DisposalItemData
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // 체크박스
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isSelected ? Color(red: 30/255, green: 59/255, blue: 207/255) : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
//                        Text(waste.name)
//                            .font(.system(size: 17, weight: .semibold))
                        Spacer()
                        Text("\(String(format: "%.1f", waste.weight))\(waste.unit)")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    
//                    HStack(spacing: 4) {
//                        Text("Lab ID: \(waste.labId)")
//                            .font(.system(size: 14))
//                            .foregroundColor(.gray)
//                        Text("·")
//                            .foregroundColor(.gray)
//                        Text(waste.status)
//                            .font(.system(size: 14))
//                            .foregroundColor(.gray)
//                    }
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color(red: 30/255, green: 59/255, blue: 207/255) : Color.gray.opacity(0.25), lineWidth: isSelected ? 2 : 1)
            )
        }
    }
}

#Preview {
    PickupRequestView()
}
