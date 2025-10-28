//
//  FacManagementView.swift
//  Labify
//
//  Created by F_S on 10/14/25.
//

import SwiftUI

struct FacManagementView: View {
    let userInfo: UserInfo
    @StateObject private var viewModel = FacViewModel()
    
    @State private var selectedTab = 0
    @State private var searchText = ""
    
    // 시트 상태
    @State private var showRegisterSheet = false
    @State private var showRegisterLabSheet = false
    @State private var showInviteSheet = false
    @State private var showRelationSheet = false
    @State private var selectedLab: Lab?
    
    @State private var requestTab = 0
    
    var filteredLabs: [Lab] {
        viewModel.filteredLabs(searchText: searchText)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                if !viewModel.hasFacility {
                    noFacilityEmptyState
                } else {
                    // 상단 탭
                    HStack(spacing: 0) {
                        FacilityTabButton(title: "시설", isSelected: selectedTab == 0) { selectedTab = 0 }
                        FacilityTabButton(title: "수거업체", isSelected: selectedTab == 1) { selectedTab = 1 }
                        FacilityTabButton(title: "권한", isSelected: selectedTab == 2) { selectedTab = 2 }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // 탭 컨텐츠
                    if selectedTab == 0 { facilityTabContent }
                    else if selectedTab == 1 { pickupRelationTabContent }
                    else { permissionTabContent }
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
                FacilityRegisterSheet(
                    isPresented: $showRegisterSheet,
                    viewModel: viewModel,
                    userInfo: userInfo
                )
            }
            .sheet(isPresented: $showRegisterLabSheet) {
                if let fid = viewModel.facilityId {
                    RegisterLabSheet(
                        isPresented: $showRegisterLabSheet,
                        viewModel: viewModel,
                        facilityId: fid
                    )
                } else {
                    ProgressView("시설 정보 불러오는 중...")
                }
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
                await viewModel.fetchFacilityInfo()
                if viewModel.hasFacility {
                    await viewModel.fetchLabs()
                    await viewModel.fetchLabRequests()
                    await viewModel.fetchFacilityJoinRequests()
                    await viewModel.fetchFacilityRelations()
                    await viewModel.fetchPickupFacilities()
                }
            }
        }
    }
}

// MARK: - 시설 없음 안내 뷰
private extension FacManagementView {
    var noFacilityEmptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "building.2.crop.circle.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.7))
            
            Text("등록된 시설이 없습니다")
                .font(.title3.weight(.semibold))
            Text("시설을 먼저 등록한 후 연구실/수거업체/권한 관리를 진행하세요.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            
            Button {
                if viewModel.hasFacility {
                    viewModel.errorMessage = "이미 등록된 시설이 있습니다."
                    viewModel.showError = true
                } else {
                    showRegisterSheet = true
                }
            } label: {
                Text("시설 등록하기")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.blue)
                    .cornerRadius(12)
                    .padding(.horizontal, 24)
            }
            Spacer()
        }
    }
}

// MARK: - 시설 탭
private extension FacManagementView {
    var facilityTabContent: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                FilterButton(title: "새 실험실 등록", isSelected: false) {
                    if let facilityId = viewModel.facilityId {
                        print("🟢 시설 ID 확인됨: \(facilityId)")
                        showRegisterLabSheet = true
                    } else {
                        print("❌ 시설 ID가 없습니다!")
                        viewModel.errorMessage = "시설 정보를 불러오는 중입니다. 잠시 후 다시 시도해주세요."
                        viewModel.showError = true
                    }
                }
                FilterButton(title: "담당자 초대", isSelected: false, isOutlined: true) {
                    showInviteSheet = true
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            // ✅ 통계 카드 - 실험실 수는 실제 데이터, 나머지는 하드코딩
            HStack(spacing: 12) {
                StatCard(title: "실험실 수", value: "\(viewModel.labs.count)")
                StatCard(title: "담당자", value: "34")
                StatCard(title: "이번 달 비용", value: "1.2 M", unit: "(₩)")
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
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
                            .onTapGesture { selectedLab = lab }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 100)
                }
            }
        }
    }
}

// MARK: - 수거업체 탭
private extension FacManagementView {
    var pickupRelationTabContent: some View {
        VStack(spacing: 0) {
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
            
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(viewModel.facilityRelations) { relation in
                            PickupRelationCard(
                                relation: relation,
                                onDelete: {
                                    Task {
                                        await viewModel.deleteFacilityRelation(relationshipId: relation.id)
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

// MARK: - 권한 탭
private extension FacManagementView {
    var permissionTabContent: some View {
        VStack(spacing: 0) {
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
                }.frame(maxWidth: .infinity)
                
                Button(action: { requestTab = 1 }) {
                    VStack(spacing: 8) {
                        Text("시설 가입 요청")
                            .font(.system(size: 15, weight: requestTab == 1 ? .semibold : .regular))
                            .foregroundColor(requestTab == 1 ? .primary : .gray)
                        Rectangle()
                            .fill(requestTab == 1 ? Color.primary : Color.clear)
                            .frame(height: 2)
                    }
                }.frame(maxWidth: .infinity)
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
    
    var labRequestListContent: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.labRequests.isEmpty {
                FacEmptyStateView(icon: "doc.text.magnifyingglass", text: "대기 중인 실험실 개설 요청이 없습니다")
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(viewModel.labRequests) { req in
                            LabRequestCard(
                                request: req,
                                onConfirm: { Task { await viewModel.confirmLabRequest(requestId: req.id) } },
                                onReject: { Task { await viewModel.rejectLabRequest(requestId: req.id) } }
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
    
    var facilityJoinRequestListContent: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.facilityJoinRequests.isEmpty {
                FacEmptyStateView(icon: "person.badge.plus", text: "대기 중인 시설 가입 요청이 없습니다")
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(viewModel.facilityJoinRequests) { req in
                            FacilityJoinRequestCard(
                                request: req,
                                onConfirm: { Task { await viewModel.confirmFacilityJoinRequest(requestId: req.id) } },
                                onReject: { Task { await viewModel.rejectFacilityJoinRequest(requestId: req.id) } }
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

// MARK: - 공용 빈 상태 뷰
private struct FacEmptyStateView: View {
    let icon: String
    let text: String
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.gray.opacity(0.5))
            Text(text)
                .font(.system(size: 16))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 40)
    }
}

// MARK: - Preview
#Preview {
    FacManagementView(
        userInfo: UserInfo(
            userId: 3,
            name: "이시설",
            email: "facility@test.com",
            role: "FACILITY_MANAGER"
        )
    )
}
