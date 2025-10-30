//
//  HistoryTabView.swift
//  Labify
//
//  Created by F_s on 10/29/25.
//

import SwiftUI

struct HistoryTabView: View {
    @StateObject private var viewModel = PickupViewModel()
    @State private var showMonthPicker = false
    @State private var showRegionPicker = false
    
    let months = ["전체", "8월", "9월", "10월", "11월", "12월"]
    let regions = ["전체 지역", "서울 영등포", "서울 강남", "서울 마포", "경기 성남"]
    
    var body: some View {
        VStack(spacing: 0) {
            // 상단 필터 바
            HStack(spacing: 12) {
                // 월 선택 버튼
                Button(action: {
                    showMonthPicker.toggle()
                    showRegionPicker = false
                }) {
                    HStack(spacing: 4) {
                        Text(viewModel.selectedMonth)
                            .font(.system(size: 15))
                            .foregroundColor(.black)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .cornerRadius(20)
                }
                
                // 지역 선택 버튼
                Button(action: {
                    showRegionPicker.toggle()
                    showMonthPicker = false
                }) {
                    HStack(spacing: 4) {
                        Text(viewModel.selectedRegion)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.black)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .cornerRadius(20)
                }
                
                Spacer()
                
                // CSV 내보내기 버튼
                Button(action: {
                    // TODO: CSV 내보내기 기능
                }) {
                    Text("CSV 내보내기")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(Color.white)
            
            // 피커 오버레이
            if showMonthPicker || showRegionPicker {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(showMonthPicker ? months : regions, id: \.self) { item in
                        Button(action: {
                            if showMonthPicker {
                                viewModel.selectedMonth = item
                                showMonthPicker = false
                            } else {
                                viewModel.selectedRegion = item
                                showRegionPicker = false
                            }
                        }) {
                            HStack {
                                Text(item)
                                    .font(.system(size: 15))
                                    .foregroundColor(.black)
                                Spacer()
                                if (showMonthPicker && item == viewModel.selectedMonth) ||
                                   (!showMonthPicker && item == viewModel.selectedRegion) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                        }
                        
                        if item != (showMonthPicker ? months.last : regions.last) {
                            Divider()
                        }
                    }
                }
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                .padding(.horizontal)
                .padding(.top, 4)
                .zIndex(1)
            }
            
            // 리스트
//            ScrollView {
//                if viewModel.filteredHistory.isEmpty && !viewModel.isLoading {
//                    emptyStateView
//                } else {
//                    VStack(spacing: 12) {
//                        ForEach(viewModel.filteredHistory) { item in
//                            HistoryItemRow(item: item)
//                        }
//                    }
//                    .padding()
//                }
//            }
//            .background(Color(red: 0.98, green: 0.98, blue: 0.98))
        }
        .task {
            await viewModel.fetchPickupHistory()
        }
        .refreshable {
            await viewModel.fetchPickupHistory()
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
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.5))
            Text("처리 이력이 없습니다")
                .font(.system(size: 16))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
    }
}

struct HistoryItemRow: View {
    let item: PickupHistoryItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
//            Text("\(item.date) · \(item.labName) · \(item.labLocation)")
//                .font(.system(size: 15, weight: .medium))
//                .foregroundColor(.black)
            
            Text(item.facilityAddress)
                .font(.system(size: 13))
                .foregroundColor(.gray)
            
            HStack {
                Text("상태: ")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                Text(statusText(item.status))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(statusColor(item.status))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private func statusText(_ status: String) -> String {
        switch status {
        case "REQUESTED": return "대기"
        case "PROCESSING": return "진행중"
        case "COMPLETED": return "완료"
        case "CANCELED": return "취소"
        default: return status
        }
    }
    
    private func statusColor(_ status: String) -> Color {
        switch status {
        case "REQUESTED": return .orange
        case "PROCESSING": return .black
        case "COMPLETED": return .blue
        case "CANCELED": return .red
        default: return .gray
        }
    }
}

#Preview {
    HistoryTabView()
}
