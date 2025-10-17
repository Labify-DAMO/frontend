//
//  FacManagementView.swift
//  Labify
//
//  Created by F_S on 10/14/25.
//

import SwiftUI

// MARK: - 관리 화면
struct FacManagementView: View {
    let userInfo: UserInfo
    @StateObject private var viewModel = LabViewModel()
    @State private var selectedTab = 0
    @State private var searchText = ""
    @State private var showRegisterSheet = false
    @State private var showInviteSheet = false
    @State private var showEditSheet = false
    @State private var selectedLab: Lab?
    
    var filteredLabs: [Lab] {
        viewModel.filteredLabs(searchText: searchText)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 상단 탭
                HStack(spacing: 0) {
                    FacilityTabButton(title: "시설", isSelected: selectedTab == 0) {
                        selectedTab = 0
                    }
                    FacilityTabButton(title: "권한", isSelected: selectedTab == 1) {
                        selectedTab = 1
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                if selectedTab == 0 {
                    facilityTabContent
                } else {
                    permissionTabContent
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("관리")
                        .font(.system(size: 17, weight: .semibold))
                }
            }
            .sheet(isPresented: $showRegisterSheet) {
                RegisterLabSheet(
                    isPresented: $showRegisterSheet,
                    viewModel: viewModel,
                    facilityId: 1 // TODO: userInfo에서 facilityId 가져오기
                )
            }
            .sheet(isPresented: $showInviteSheet) {
                InviteManagerSheet(isPresented: $showInviteSheet)
            }
            .sheet(item: $selectedLab) { lab in
                EditLabSheet(
                    isPresented: Binding(
                        get: { selectedLab != nil },
                        set: { if !$0 { selectedLab = nil } }
                    ),
                    lab: lab,
                    viewModel: viewModel
                )
            }
            .alert("오류", isPresented: $viewModel.showError) {
                Button("확인", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "알 수 없는 오류가 발생했습니다.")
            }
            .task {
                await viewModel.fetchLabs()
                await viewModel.fetchLabRequests()
            }
        }
    }
    
    // MARK: - 시설 탭 콘텐츠
    private var facilityTabContent: some View {
        VStack(spacing: 0) {
            // 필터 버튼
            HStack(spacing: 12) {
                FilterButton(title: "새 실험실 등록", isSelected: false) {
                    showRegisterSheet = true
                }
                FilterButton(title: "담당자 초대", isSelected: false, isOutlined: true) {
                    showInviteSheet = true
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            // 통계 카드
            HStack(spacing: 12) {
                StatCard(title: "실험실", value: "\(viewModel.labs.count)")
                StatCard(title: "담당자", value: "34") // TODO: 실제 데이터
                StatCard(title: "이번 달 비용", value: "1.2 M", unit: "(₩)") // TODO: 실제 데이터
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            // 검색바
            HStack {
                TextField("실험실/부서 검색", text: $searchText)
                    .padding(.leading, 12)
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .padding(.trailing, 12)
            }
            .frame(height: 48)
            .background(Color(white: 0.96))
            .cornerRadius(24)
            .padding(.horizontal)
            .padding(.top, 16)
            
            // 실험실 리스트
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if filteredLabs.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "building.2")
                        .font(.system(size: 48))
                        .foregroundColor(.gray.opacity(0.5))
                    Text(searchText.isEmpty ? "등록된 실험실이 없습니다" : "검색 결과가 없습니다")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(filteredLabs) { lab in
                            FacilityCard(
                                name: lab.name,
                                location: lab.location,
                                managerCount: 0, // TODO: 실제 데이터
                                isActive: true // TODO: 실제 데이터
                            )
                            .onTapGesture {
                                selectedLab = lab
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 100)
                }
            }
        }
    }
    
    // MARK: - 권한 탭 콘텐츠
    private var permissionTabContent: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 40)
            } else if viewModel.labRequests.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(.gray.opacity(0.5))
                    Text("대기 중인 요청이 없습니다")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 40)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(viewModel.labRequests) { request in
                            LabRequestCard(
                                request: request,
                                onConfirm: {
                                    Task {
                                        await viewModel.confirmLabRequest(requestId: request.id)
                                    }
                                },
                                onReject: {
                                    Task {
                                        await viewModel.rejectLabRequest(requestId: request.id)
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .padding(.bottom, 100)
                }
            }
        }
    }
}

// MARK: - 실험실 등록 시트
struct RegisterLabSheet: View {
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: LabViewModel
    let facilityId: Int
    
    @State private var labName = ""
    @State private var location = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("실험실 이름")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.gray)
                    TextField("예: 세포배양실", text: $labName)
                        .padding()
                        .background(Color(white: 0.96))
                        .cornerRadius(12)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("위치")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.gray)
                    TextField("예: A동 3층 217호", text: $location)
                        .padding()
                        .background(Color(white: 0.96))
                        .cornerRadius(12)
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button("취소") {
                        isPresented = false
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(white: 0.95))
                    .foregroundColor(.primary)
                    .cornerRadius(12)
                    
                    Button("등록하기") {
                        Task {
                            let success = await viewModel.registerLab(
                                name: labName,
                                location: location,
                                facilityId: facilityId
                            )
                            if success {
                                isPresented = false
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [Color(red: 30/255, green: 59/255, blue: 207/255),
                                     Color(red: 113/255, green: 100/255, blue: 230/255)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .disabled(labName.isEmpty || location.isEmpty || viewModel.isLoading)
                    .opacity(labName.isEmpty || location.isEmpty ? 0.5 : 1)
                }
            }
            .padding()
            .navigationTitle("새 실험실 등록")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

// MARK: - 담당자 초대 시트
struct InviteManagerSheet: View {
    @Binding var isPresented: Bool
    
    @State private var email = ""
    @State private var selectedRole = "실험실 관리자"
    @State private var selectedLocation = "A동 3층"
    @State private var memo = ""
    @State private var isSubmitting = false
    
    let roles = ["실험실 관리자", "일반 사용자", "연구원"]
    let locations = ["A동 3층", "A동 2층", "B동 1층", "C동 2층"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("이메일")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.gray)
                        TextField("name@example.com", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color(white: 0.96))
                            .cornerRadius(12)
                    }
                    
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("역할")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.gray)
                            Menu {
                                ForEach(roles, id: \.self) { role in
                                    Button(role) {
                                        selectedRole = role
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedRole)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.up.chevron.down")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color(white: 0.96))
                                .cornerRadius(12)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("소속")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.gray)
                            Menu {
                                ForEach(locations, id: \.self) { location in
                                    Button(location) {
                                        selectedLocation = location
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedLocation)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.up.chevron.down")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color(white: 0.96))
                                .cornerRadius(12)
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("메모(옵션)")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.gray)
                        TextEditor(text: $memo)
                            .frame(height: 120)
                            .padding(8)
                            .background(Color(white: 0.96))
                            .cornerRadius(12)
                            .overlay(
                                Group {
                                    if memo.isEmpty {
                                        Text("권한 범위/사유 등...")
                                            .foregroundColor(.gray.opacity(0.6))
                                            .padding(.leading, 12)
                                            .padding(.top, 16)
                                    }
                                },
                                alignment: .topLeading
                            )
                    }
                    
                    Text("* 초대 수락 시 자동으로 권한이 부여됩니다.")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 12) {
                        Button("취소") {
                            isPresented = false
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(white: 0.95))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                        
                        Button("초대 보내기") {
                            sendInvite()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color(red: 30/255, green: 59/255, blue: 207/255),
                                         Color(red: 113/255, green: 100/255, blue: 230/255)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .disabled(email.isEmpty || isSubmitting)
                        .opacity(email.isEmpty ? 0.5 : 1)
                    }
                    .padding(.top, 20)
                }
                .padding()
            }
            .navigationTitle("담당자 초대")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") {
                        isPresented = false
                    }
                }
            }
        }
    }
    
    private func sendInvite() {
        isSubmitting = true
        // TODO: API 호출 - POST /invites
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isSubmitting = false
            isPresented = false
        }
    }
}

// MARK: - 실험실 수정 시트
struct EditLabSheet: View {
    @Binding var isPresented: Bool
    let lab: Lab
    @ObservedObject var viewModel: LabViewModel
    
    @State private var labName: String
    @State private var location: String
    
    init(isPresented: Binding<Bool>, lab: Lab, viewModel: LabViewModel) {
        self._isPresented = isPresented
        self.lab = lab
        self.viewModel = viewModel
        self._labName = State(initialValue: lab.name)
        self._location = State(initialValue: lab.location)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("실험실 이름")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.gray)
                    TextField("예: 세포배양실", text: $labName)
                        .padding()
                        .background(Color(white: 0.96))
                        .cornerRadius(12)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("위치")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.gray)
                    TextField("예: A동 3층 217호", text: $location)
                        .padding()
                        .background(Color(white: 0.96))
                        .cornerRadius(12)
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button("취소") {
                        isPresented = false
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(white: 0.95))
                    .foregroundColor(.primary)
                    .cornerRadius(12)
                    
                    Button("수정하기") {
                        Task {
                            let success = await viewModel.updateLab(
                                labId: lab.id,
                                name: labName,
                                location: location
                            )
                            if success {
                                isPresented = false
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [Color(red: 30/255, green: 59/255, blue: 207/255),
                                     Color(red: 113/255, green: 100/255, blue: 230/255)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .disabled(labName.isEmpty || location.isEmpty || viewModel.isLoading)
                    .opacity(labName.isEmpty || location.isEmpty ? 0.5 : 1)
                }
            }
            .padding()
            .navigationTitle("실험실 정보 수정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

// MARK: - 실험실 요청 카드
struct LabRequestCard: View {
    let request: LabRequest
    let onConfirm: () -> Void
    let onReject: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(request.labName)
                        .font(.system(size: 16, weight: .semibold))
                    Text(request.location)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                Spacer()
                Text(formatDate(request.createdAt))
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("요청자")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    Text(request.requesterName)
                        .font(.system(size: 14, weight: .medium))
                }
                Spacer()
            }
            
            HStack(spacing: 8) {
                Button("거절") {
                    onReject()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color(white: 0.95))
                .foregroundColor(.red)
                .cornerRadius(8)
                
                Button("승인") {
                    onConfirm()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [Color(red: 30/255, green: 59/255, blue: 207/255),
                                 Color(red: 113/255, green: 100/255, blue: 230/255)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "MM/dd"
            return formatter.string(from: date)
        }
        return dateString
    }
}

// MARK: - 상단 탭 버튼
struct FacilityTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .primary : .gray)
                Rectangle()
                    .fill(isSelected ? Color.primary : Color.clear)
                    .frame(height: 2)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 필터 버튼
struct FilterButton: View {
    let title: String
    let isSelected: Bool
    var isOutlined: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(isOutlined ? .primary : .white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    Group {
                        if isOutlined {
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1.5)
                                .background(Color.white)
                        } else {
                            LinearGradient(
                                colors: [Color(red: 30/255, green: 59/255, blue: 207/255),
                                         Color(red: 113/255, green: 100/255, blue: 230/255)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        }
                    }
                )
                .cornerRadius(20)
        }
    }
}

// MARK: - 통계 카드
struct StatCard: View {
    let title: String
    let value: String
    var unit: String = ""
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(.gray)
            HStack(alignment: .bottom, spacing: 2) {
                Text(value)
                    .font(.system(size: 22, weight: .bold))
                if !unit.isEmpty {
                    Text(unit)
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                        .padding(.bottom, 2)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - 실험실 카드
struct FacilityCard: View {
    let name: String
    let location: String
    let managerCount: Int
    let isActive: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(name)
                .font(.system(size: 16, weight: .semibold))
            HStack(spacing: 8) {
                Text(location)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                Text("·")
                    .foregroundColor(.gray)
                Text("담당 \(managerCount)명")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                Text("·")
                    .foregroundColor(.gray)
                Text(isActive ? "활성" : "비활성")
                    .font(.system(size: 14))
                    .foregroundColor(isActive ? .blue : .gray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Preview
#Preview {
    FacManagementView(
        userInfo: UserInfo(
            userId: 3,
            name: "이시설",
            email: "facility@test.com",
            role: "FACILITY_MANAGER",
            affiliation: "종합관리센터"
        )
    )
}
