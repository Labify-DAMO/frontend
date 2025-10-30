//
//  LabHistoryView.swift
//  Labify
//
//  Created by KITS on 10/13/25.
//

import SwiftUI

struct LabHistoryView: View {
    @StateObject private var requestViewModel = RequestViewModel()
    @State private var selectedTab: RequestStatus? = nil
    @State private var searchText = ""
    @State private var showingCancelConfirmation = false
    @State private var requestToCancel: Request?
    
    private var filteredRequests: [Request] {
        let requests = selectedTab == nil ? requestViewModel.requests : requestViewModel.filterByStatus(selectedTab!)
        
        if searchText.isEmpty {
            return requests
        }
        return requestViewModel.searchRequests(query: searchText)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 검색 바
                searchBar
                
                // 탭 선택
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        FilterTabButton(title: "전체", isSelected: selectedTab == nil) {
                            selectedTab = nil
                        }
                        ForEach(RequestStatus.allCases, id: \.self) { status in
                            FilterTabButton(
                                title: status.displayName,
                                count: requestViewModel.getCountByStatus(status),
                                isSelected: selectedTab == status
                            ) {
                                selectedTab = status
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                }
                .background(Color.white)
                
                Divider()
                
                // 요청 리스트
                if requestViewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if filteredRequests.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredRequests) { request in
                                NavigationLink(destination: RequestDetailView(requestId: request.id)) {
                                    RequestHistoryCard(
                                        request: request,
                                        onCancel: {
                                            requestToCancel = request
                                            showingCancelConfirmation = true
                                        }
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(20)
                    }
                    .background(Color(red: 249/255, green: 250/255, blue: 252/255))
                    .refreshable {
                        await requestViewModel.fetchRequests()
                    }
                }
            }
            .navigationTitle("수거 요청 이력")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await requestViewModel.fetchRequests()
            }
            .alert("수거 요청 취소", isPresented: $showingCancelConfirmation) {
                Button("취소", role: .cancel) {
                    requestToCancel = nil
                }
                Button("확인", role: .destructive) {
                    if let request = requestToCancel {
                        Task {
                            await cancelRequest(request)
                        }
                    }
                }
            } message: {
                Text("이 수거 요청을 취소하시겠습니까?")
            }
            .alert("알림", isPresented: $requestViewModel.showSuccessMessage) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(requestViewModel.successMessage ?? "")
            }
            .alert("오류", isPresented: $requestViewModel.showError) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(requestViewModel.errorMessage ?? "알 수 없는 오류가 발생했습니다.")
            }
        }
    }
    
    // MARK: - 검색 바
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .font(.system(size: 16))
            
            TextField("폐기물 종류로 검색", text: $searchText)
                .font(.system(size: 16))
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.system(size: 16))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(red: 249/255, green: 250/255, blue: 252/255))
        .cornerRadius(12)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white)
    }
    
    // MARK: - 빈 상태 뷰
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 64))
                .foregroundColor(.gray.opacity(0.5))
            
            Text(searchText.isEmpty ? "수거 요청 이력이 없습니다" : "검색 결과가 없습니다")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.secondary)
            
            if searchText.isEmpty {
                Text("폐기물을 등록하고 수거 요청을 시작해보세요")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 249/255, green: 250/255, blue: 252/255))
    }
    
    // MARK: - Helper Functions
    private func cancelRequest(_ request: Request) async {
        let success = await requestViewModel.cancelRequest(requestId: request.id)
        if success {
            requestToCancel = nil
        }
    }
}

// MARK: - Filter Tab Button
struct FilterTabButton: View {
    let title: String
    var count: Int?
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                
                if let count = count {
                    Text("\(count)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(isSelected ? .white : .secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(isSelected ? Color.white.opacity(0.3) : Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                isSelected ?
                LinearGradient(
                    colors: [
                        Color(red: 30/255, green: 59/255, blue: 207/255),
                        Color(red: 113/255, green: 100/255, blue: 230/255)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                ) :
                LinearGradient(
                    colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.1)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(20)
        }
    }
}

// MARK: - Request History Card
struct RequestHistoryCard: View {
    let request: Request
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // 헤더
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Image(systemName: request.statusEnum?.systemImage ?? "circle")
                            .font(.system(size: 14))
                            .foregroundColor(statusColor)
                        
                        Text(request.statusEnum?.displayName ?? request.status)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(statusColor)
                    }
                    
                    Text(request.displayDate)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if request.canCancel {
                    Button(action: onCancel) {
                        Text("취소")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.red)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
            }
            .padding(16)
            
            Divider()
            
            // 폐기물 목록
            VStack(spacing: 12) {
                ForEach(request.disposalItems.prefix(3)) { item in
                    HStack {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 6, height: 6)
                        
                        Text(item.wasteTypeName)
                            .font(.system(size: 15))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(item.displayWeight)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
                
                if request.disposalItems.count > 3 {
                    HStack {
                        Text("외 \(request.disposalItems.count - 3)건")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
            }
            .padding(16)
            
            Divider()
            
            // 요약 정보
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "cube.box")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    Text("총 \(request.itemCount)건")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 6) {
                    Image(systemName: "scalemass")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    Text(String(format: "%.1f kg", request.totalWeight))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                }
            }
            .padding(16)
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
    
    private var statusColor: Color {
        guard let status = request.statusEnum else { return .gray }
        switch status {
        case .requested: return .orange
        case .scheduled: return Color(red: 30/255, green: 59/255, blue: 207/255)
        case .completed: return .green
        case .canceled: return .gray
        }
    }
}

// MARK: - Request Detail View
struct RequestDetailView: View {
    let requestId: Int
    @StateObject private var requestViewModel = RequestViewModel()
    @State private var requestDetail: RequestDetail?
    @State private var showingCancelConfirmation = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            if let detail = requestDetail {
                VStack(spacing: 20) {
                    // 상태 카드
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            Image(systemName: detail.statusEnum?.systemImage ?? "circle")
                                .font(.system(size: 32))
                                .foregroundColor(statusColor)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("요청 상태")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                Text(detail.statusEnum?.displayName ?? detail.status)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                        }
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("수거 예정일")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                                Text(detail.displayDate)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                        }
                    }
                    .padding(20)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(red: 244/255, green: 247/255, blue: 255/255),
                                Color.white
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(statusColor.opacity(0.3), lineWidth: 1)
                    )
                    
                    // 폐기물 목록
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("폐기물 목록")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text("\(detail.disposalItems.count)건")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(spacing: 12) {
                            ForEach(detail.disposalItems) { item in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.wasteTypeName)
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(.primary)
                                        
                                        Text(item.displayWeight)
                                            .font(.system(size: 14))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                            }
                        }
                    }
                    
                    // 총 무게
                    HStack {
                        Text("총 무게")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(String(format: "%.1f kg", detail.totalWeight))
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                    
                    // 취소 버튼
                    if detail.canCancel {
                        Button(action: {
                            showingCancelConfirmation = true
                        }) {
                            Text("수거 요청 취소")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                }
                .padding(20)
            } else if requestViewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Text("요청 정보를 불러올 수 없습니다")
                    .foregroundColor(.secondary)
            }
        }
        .background(Color(red: 249/255, green: 250/255, blue: 252/255))
        .navigationTitle("요청 상세")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            requestDetail = await requestViewModel.fetchRequestDetail(requestId: requestId)
        }
        .alert("수거 요청 취소", isPresented: $showingCancelConfirmation) {
            Button("취소", role: .cancel) {}
            Button("확인", role: .destructive) {
                Task {
                    await cancelRequest()
                }
            }
        } message: {
            Text("이 수거 요청을 취소하시겠습니까?")
        }
        .alert("오류", isPresented: $requestViewModel.showError) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(requestViewModel.errorMessage ?? "알 수 없는 오류가 발생했습니다.")
        }
    }
    
    private var statusColor: Color {
        guard let status = requestDetail?.statusEnum else { return .gray }
        switch status {
        case .requested: return .orange
        case .scheduled: return Color(red: 30/255, green: 59/255, blue: 207/255)
        case .completed: return .green
        case .canceled: return .gray
        }
    }
    
    private func cancelRequest() async {
        let success = await requestViewModel.cancelRequest(requestId: requestId)
        if success {
            dismiss()
        }
    }
}

#Preview {
    LabHistoryView()
}
