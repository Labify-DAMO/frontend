//
//  TodayProgressView.swift
//  Labify
//
//  Created by F_s on 9/29/25.
//

import SwiftUI

struct TodayProgressView: View {
    @StateObject private var viewModel = PickupViewModel()
    @State private var selectedTab = 0 // 0: 전체, 1: 대기, 2: 진행, 3: 완료
    
    var filteredItems: [TodayPickupItem] {
        switch selectedTab {
        case 1:
            return viewModel.filteredTodayPickups(by: .waiting)
        case 2:
            return viewModel.filteredTodayPickups(by: .inProgress)
        case 3:
            return viewModel.filteredTodayPickups(by: .completed)
        default:
            return viewModel.todayPickups
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 탭 선택
                HStack(spacing: 0) {
                    ProgressTabButton(title: "전체", isSelected: selectedTab == 0) {
                        selectedTab = 0
                    }
                    ProgressTabButton(title: "대기", isSelected: selectedTab == 1) {
                        selectedTab = 1
                    }
                    ProgressTabButton(title: "진행", isSelected: selectedTab == 2) {
                        selectedTab = 2
                    }
                    ProgressTabButton(title: "완료", isSelected: selectedTab == 3) {
                        selectedTab = 3
                    }
                }
                .background(Color.white)
                
                // 현재 진행중 헤더 (진행 탭일 때만 표시)
                if selectedTab == 2 && !filteredItems.isEmpty {
                    HStack {
                        Text("현재 진행중")
                            .font(.system(size: 14))
                            .foregroundColor(.blue)
                        Spacer()
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                }
                
                // 리스트
                ScrollView {
                    if filteredItems.isEmpty {
                        emptyStateView
                    } else {
                        VStack(spacing: 12) {
                            ForEach(filteredItems) { item in
                                TodayPickupItemRow(
                                    item: item,
                                    onStatusChange: { newStatus in
                                        Task {
                                            await viewModel.updatePickupStatus(
                                                pickupId: item.id,
                                                status: newStatus
                                            )
                                        }
                                    }
                                )
                            }
                        }
                        .padding()
                    }
                }
                .background(Color.gray.opacity(0.05))
            }
            .navigationTitle("오늘 진행")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await viewModel.fetchTodayPickups()
            }
            .refreshable {
                await viewModel.fetchTodayPickups()
            }
            .alert("오류", isPresented: $viewModel.showError) {
                Button("확인", role: .cancel) {}
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "shippingbox")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.5))
            Text("진행 중인 수거가 없습니다")
                .font(.system(size: 16))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
    }
}

struct ProgressTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(isSelected ? .blue : .gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                
                Rectangle()
                    .fill(isSelected ? Color.blue : Color.clear)
                    .frame(height: 2)
            }
        }
    }
}

struct TodayPickupItemRow: View {
    let item: TodayPickupItem
    let onStatusChange: (PickupItemStatus) -> Void
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.labName)
                    .font(.system(size: 17, weight: .semibold))
                
                Text(item.location)
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                
                Text("\(item.scheduledTime) · \(item.wasteCount)건 (\(String(format: "%.1f", item.totalWeight))kg)")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            statusButton
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    @ViewBuilder
    var statusButton: some View {
        Menu {
            Button("대기") {
                onStatusChange(.waiting)
            }
            Button("진행중") {
                onStatusChange(.inProgress)
            }
            Button("완료") {
                onStatusChange(.completed)
            }
        } label: {
            HStack(spacing: 4) {
                Text(item.status.displayText)
                    .font(.system(size: 14, weight: .medium))
                Image(systemName: "chevron.down")
                    .font(.system(size: 10))
            }
            .foregroundColor(statusColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(statusBackground)
            .cornerRadius(6)
        }
    }
    
    private var statusColor: Color {
        switch item.status {
        case .waiting: return .gray
        case .inProgress: return .white
        case .completed: return .white
        }
    }
    
    private var statusBackground: Color {
        switch item.status {
        case .waiting: return Color.gray.opacity(0.2)
        case .inProgress: return .black
        case .completed: return .blue
        }
    }
}

#Preview {
    TodayProgressView()
}
