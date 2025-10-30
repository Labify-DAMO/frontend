////
////  PickupSceduleView.swift
////  Labify
////
////  Created by F_s on 9/29/25.
////
//
//// =========================================
//// ScheduleView.swift
//// 수거 예정 화면 (지도/목록/처리이력)
//
//import SwiftUI
//
//struct PickupScheduleView: View {
//	@State private var selectedTab = 0
//	
//	var body: some View {
//		NavigationView {
//			VStack(spacing: 0) {
//				// 탭 선택
//				HStack(spacing: 0) {
//					TabButton(title: "지도", isSelected: selectedTab == 0) {
//						selectedTab = 0
//					}
//					TabButton(title: "목록", isSelected: selectedTab == 1) {
//						selectedTab = 1
//					}
//					TabButton(title: "처리 이력", isSelected: selectedTab == 2) {
//						selectedTab = 2
//					}
//				}
//				.background(Color.white)
//				
//				// 탭 콘텐츠
//				TabView(selection: $selectedTab) {
//					MapTabView()
//						.tag(0)
//					ListTabView()
//						.tag(1)
//					HistoryTabView()
//						.tag(2)
//				}
//				.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
//			}
//			.navigationTitle("수거 예정")
//			.navigationBarTitleDisplayMode(.inline)
//		}
//	}
//}
//
//struct TabButton: View {
//	let title: String
//	let isSelected: Bool
//	let action: () -> Void
//	
//	var body: some View {
//		Button(action: action) {
//			VStack(spacing: 0) {
//				Text(title)
//					.font(.system(size: 16))
//					.foregroundColor(isSelected ? .blue : .gray)
//					.frame(maxWidth: .infinity)
//					.padding(.vertical, 12)
//				
//				Rectangle()
//					.fill(isSelected ? Color.blue : Color.clear)
//					.frame(height: 2)
//			}
//		}
//	}
//}
