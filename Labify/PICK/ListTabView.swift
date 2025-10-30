////
////  ListTabView.swift
////  Labify
////
////  Created by F_s on 10/29/25.
////
//
//import SwiftUI
//
//struct ListTabView: View {
//    @StateObject private var viewModel = PickupViewModel()
//    
//    var body: some View {
//        ScrollView {
//            if viewModel.tomorrowPickups.isEmpty && !viewModel.isLoading {
//                emptyStateView
//            } else {
//                VStack(spacing: 12) {
//                    ForEach(viewModel.tomorrowPickups) { item in
//                        TomorrowScheduleItemRow(item: item)
//                    }
//                }
//                .padding()
//            }
//        }
//        .background(Color.gray.opacity(0.05))
//        .task {
//            await viewModel.fetchTomorrowPickups()
//        }
//        .refreshable {
//            await viewModel.fetchTomorrowPickups()
//        }
//        .overlay {
//            if viewModel.isLoading {
//                ProgressView()
//                    .scaleEffect(1.5)
//            }
//        }
//    }
//    
//    private var emptyStateView: some View {
//        VStack(spacing: 12) {
//            Image(systemName: "calendar")
//                .font(.system(size: 50))
//                .foregroundColor(.gray.opacity(0.5))
//            Text("내일 수거 예정이 없습니다")
//                .font(.system(size: 16))
//                .foregroundColor(.gray)
//        }
//        .frame(maxWidth: .infinity)
//        .padding(.top, 100)
//    }
//}
//
//struct TomorrowScheduleItemRow: View {
//    let item: TomorrowPickupItem
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 4) {
//            Text(item.labName)
//                .font(.system(size: 17, weight: .semibold))
//            
//            Text(item.labLocation)
//                .font(.system(size: 15))
//                .foregroundColor(.gray)
//            
//            Text(item.facilityAddress)
//                .font(.system(size: 14))
//                .foregroundColor(.gray)
//        }
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .padding()
//        .background(Color.white)
//        .cornerRadius(12)
//        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
//    }
//}
//
//#Preview {
//    ListTabView()
//}
