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
    @StateObject private var viewModel = FacViewModel()
    @State private var selectedTab = 0
    @State private var searchText = ""
    @State private var showRegisterSheet = false
    @State private var showInviteSheet = false
    @State private var showEditSheet = false
    @State private var showRelationSheet = false
    @State private var selectedLab: Lab?
    @State private var requestTab = 0 // 0: 실험실 개설 요청, 1: 시설 가입 요청
    
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
                    FacilityTabButton(title: "수거업체", isSelected: selectedTab == 1) {
                        selectedTab = 1
                    }
                    FacilityTabButton(title: "권한", isSelected: selectedTab == 2) {
                        selectedTab = 2
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                if selectedTab == 0 {
                    facilityTabContent
                } else if selectedTab == 1 {
                    pickupRelationTabContent
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
            .sheet(isPresented: $showRelationSheet) {
                AddPickupRelationSheet(
                    isPresented: $showRelationSheet,
                    viewModel: viewModel
                )
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
               // await viewModel.fetchFacilityJoinRequests()
                await viewModel.fetchFacilityRelations()
                await viewModel.fetchPickupFacilities()
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
                StatCard(title: "담당자", value: "34")
                StatCard(title: "이번 달 비용", value: "1.2 M", unit: "(₩)")
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
                                managerCount: 0,
                                isActive: true
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
    
    // MARK: - 수거업체 관계 탭 콘텐츠
    private var pickupRelationTabContent: some View {
        VStack(spacing: 0) {
            // 추가 버튼
            HStack {
                Spacer()
                Button(action: { showRelationSheet = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus.circle.fill")
                        Text("수거업체 연결")
                    }
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
            .padding(.horizontal)
            .padding(.top, 20)
            
            // 관계 목록
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 40)
            } else if viewModel.facilityRelations.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "truck.box")
                        .font(.system(size: 48))
                        .foregroundColor(.gray.opacity(0.5))
                    Text("연결된 수거업체가 없습니다")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 40)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(viewModel.facilityRelations) { relation in
                            PickupRelationCard(
                                relation: relation,
                                onDelete: {
                                    Task {
                                        await viewModel.deleteFacilityRelation(
                                            relationshipId: relation.id
                                        )
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
    
    // MARK: - 권한 탭 콘텐츠
    private var permissionTabContent: some View {
        VStack(spacing: 0) {
            // 요청 타입 선택 탭
            HStack(spacing: 0) {
                Button(action: { requestTab = 0 }) {
                    VStack(spacing: 8) {
                        Text("실험실 개설 요청")
                            .font(.system(size: 15, weight: requestTab == 0 ? .semibold : .regular))
                            .foregroundColor(requestTab == 0 ? .primary : .gray)
                        Rectangle()
                            .fill(requestTab == 0 ? Color.primary : Color.clear)
                            .frame(height: 2)
                    }
                }
                .frame(maxWidth: .infinity)
                
                Button(action: { requestTab = 1 }) {
                    VStack(spacing: 8) {
                        Text("시설 가입 요청")
                            .font(.system(size: 15, weight: requestTab == 1 ? .semibold : .regular))
                            .foregroundColor(requestTab == 1 ? .primary : .gray)
                        Rectangle()
                            .fill(requestTab == 1 ? Color.primary : Color.clear)
                            .frame(height: 2)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
            .padding(.top, 12)
            
            if requestTab == 0 {
                labRequestListContent
            } else {
                facilityJoinRequestListContent
            }
        }
    }
    
    // MARK: - 실험실 개설 요청 목록
    private var labRequestListContent: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 40)
            } else if viewModel.labRequests.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(.gray.opacity(0.5))
                    Text("대기 중인 실험실 개설 요청이 없습니다")
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
    
    // MARK: - 시설 가입 요청 목록
    private var facilityJoinRequestListContent: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 40)
            } else if viewModel.facilityJoinRequests.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 48))
                        .foregroundColor(.gray.opacity(0.5))
                    Text("대기 중인 시설 가입 요청이 없습니다")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 40)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(viewModel.facilityJoinRequests) { request in
                            FacilityJoinRequestCard(
                                request: request,
                                onConfirm: {
                                    Task {
                                        await viewModel.confirmFacilityJoinRequest(
                                            requestId: request.id
                                        )
                                    }
                                },
                                onReject: {
                                    Task {
                                        await viewModel.rejectFacilityJoinRequest(
                                            requestId: request.id
                                        )
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

// MARK: - 수거업체 연결 시트
struct AddPickupRelationSheet: View {
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: FacViewModel
    
    @State private var selectedPickupFacilityId: Int?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("수거업체 선택")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.gray)
                    
                    if viewModel.pickupFacilities.isEmpty {
                        Text("사용 가능한 수거업체가 없습니다")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(white: 0.96))
                            .cornerRadius(12)
                    } else {
                        Menu {
                            ForEach(viewModel.pickupFacilities) { facility in
                                Button(facility.name) {
                                    selectedPickupFacilityId = facility.id
                                }
                            }
                        } label: {
                            HStack {
                                if let selectedId = selectedPickupFacilityId,
                                   let facility = viewModel.pickupFacilities.first(where: { $0.id == selectedId }) {
                                    Text(facility.name)
                                        .foregroundColor(.primary)
                                } else {
                                    Text("수거업체를 선택하세요")
                                        .foregroundColor(.gray)
                                }
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
                    
                    Button("연결하기") {
                        Task {
                            guard let pickupId = selectedPickupFacilityId else { return }
                            let success = await viewModel.createFacilityRelation(
                                labFacilityId: 1, // TODO: 실제 시설 ID
                                pickupFacilityId: pickupId
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
                    .disabled(selectedPickupFacilityId == nil || viewModel.isLoading)
                    .opacity(selectedPickupFacilityId == nil ? 0.5 : 1)
                }
            }
            .padding()
            .navigationTitle("수거업체 연결")
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

// MARK: - 수거업체 관계 카드
struct PickupRelationCard: View {
    let relation: FacilityRelation
    let onDelete: () -> Void
    
    @State private var showDeleteAlert = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(relation.pickupCompanyName)
                    .font(.system(size: 16, weight: .semibold))
                Text("연결일: \(formatDate(relation.createdAt))")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: { showDeleteAlert = true }) {
                Image(systemName: "trash")
                    .font(.system(size: 16))
                    .foregroundColor(.red)
                    .padding(8)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .alert("연결 해제", isPresented: $showDeleteAlert) {
            Button("취소", role: .cancel) { }
            Button("해제", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("이 수거업체와의 연결을 해제하시겠습니까?")
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "yyyy.MM.dd"
            return formatter.string(from: date)
        }
        return dateString
    }
}

// MARK: - 시설 가입 요청 카드
struct FacilityJoinRequestCard: View {
    let request: FacilityJoinRequestItem
    let onConfirm: () -> Void
    let onReject: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(request.userName)
                        .font(.system(size: 16, weight: .semibold))
                    Text(request.userEmail)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                Spacer()
                Text(formatDate(request.requestedAt))
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("시설 코드")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    Text(request.facilityCode)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.blue)
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
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "MM/dd HH:mm"
            return formatter.string(from: date)
        }
        return dateString
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
