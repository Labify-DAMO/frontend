//
//  ScheduleListView.swift
//  Labify
//
//  Created by F_S on 10/30/25.
//

import SwiftUI

enum ScheduleFilter: String, CaseIterable {
    case all = "전체"
    case today = "오늘"
    case tomorrow = "내일"
    case thisWeek = "이번주"
    case nextWeek = "다음주"
}

struct ScheduleListView: View {
    @StateObject private var viewModel = PickupViewModel()
    @State private var selectedFilter: ScheduleFilter = .tomorrow
    @State private var useMockData = true
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                filterBar
                
                ScrollView {
                    if filteredPickups.isEmpty && !viewModel.isLoading {
                        emptyStateView
                    } else {
                        VStack(spacing: 12) {
                            ForEach(filteredPickups) { item in
                                SchedulePickupCard(item: item, filter: selectedFilter)
                            }
                        }
                        .padding()
                    }
                }
                .background(Color(red: 0.98, green: 0.98, blue: 0.98))
            }
            .navigationTitle("수거 예정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        useMockData.toggle()
                    }) {
                        Image(systemName: useMockData ? "eye.fill" : "eye.slash.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
            .task {
                if !useMockData {
                    await loadSchedules()
                }
            }
            .refreshable {
                await loadSchedules()
            }
        }
    }
    
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(ScheduleFilter.allCases, id: \.self) { filter in
                    FilterChip(
                        title: filter.rawValue,
                        isSelected: selectedFilter == filter,
                        count: getCount(for: filter)
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedFilter = filter
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(Color.white)
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            Text("예정된 수거가 없습니다")
                .font(.system(size: 18, weight: .semibold))
            Text(emptyMessage)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
    }
    
    private var emptyMessage: String {
        switch selectedFilter {
        case .all: return "등록된 수거 일정이 없습니다"
        case .today: return "오늘은 수거 예정이 없습니다"
        case .tomorrow: return "내일은 수거 예정이 없습니다"
        case .thisWeek: return "이번 주는 수거 예정이 없습니다"
        case .nextWeek: return "다음 주는 수거 예정이 없습니다"
        }
    }
    
    private var filteredPickups: [TomorrowPickupItem] {
        if !useMockData {
            return viewModel.tomorrowPickups
        }
        
        switch selectedFilter {
        case .all:
            return TodayPickupItem.mockData.map { convertToTomorrowItem($0) }
                + TomorrowPickupItem.mockTomorrow
                + TomorrowPickupItem.mockThisWeek
                + TomorrowPickupItem.mockNextWeek
        case .today:
            return TodayPickupItem.mockData.map { convertToTomorrowItem($0) }
        case .tomorrow:
            return TomorrowPickupItem.mockTomorrow
        case .thisWeek:
            return TomorrowPickupItem.mockThisWeek
        case .nextWeek:
            return TomorrowPickupItem.mockNextWeek
        }
    }
    
    private func convertToTomorrowItem(_ today: TodayPickupItem) -> TomorrowPickupItem {
        TomorrowPickupItem(
            pickupId: today.pickupId,
            labName: today.labName,
            labLocation: today.labLocation,
            facilityAddress: today.facilityAddress,
            status: today.status
        )
    }
    
    private func getCount(for filter: ScheduleFilter) -> Int {
        if !useMockData {
            return viewModel.tomorrowPickups.count
        }
        
        switch filter {
        case .all:
            return TodayPickupItem.mockData.count
                + TomorrowPickupItem.mockTomorrow.count
                + TomorrowPickupItem.mockThisWeek.count
                + TomorrowPickupItem.mockNextWeek.count
        case .today:
            return TodayPickupItem.mockData.count
        case .tomorrow:
            return TomorrowPickupItem.mockTomorrow.count
        case .thisWeek:
            return TomorrowPickupItem.mockThisWeek.count
        case .nextWeek:
            return TomorrowPickupItem.mockNextWeek.count
        }
    }
    
    private func loadSchedules() async {
        await viewModel.fetchTomorrowPickups()
    }
}
