//
//  TodayProgressView.swift
//  Labify
//
//  Created by F_s on 9/29/25.
//

// =========================================
// TodayProgressView.swift
// 오늘 진행 화면

import SwiftUI

struct TodayProgressView: View {
	@State private var selectedTab = 2 // 진행 탭이 기본 선택
	
	let progressItems = [
		ProgressItem(name: "A동 3층 세탁배방실", time: "08:30", weight: "321(4.2kg)", status: .inProgress),
		ProgressItem(name: "A동 2층 분식당", time: "09:10", weight: "12(12.1kg)", status: .waiting),
		ProgressItem(name: "C동 2층 분식당", time: "09:40", weight: "12(10.7kg)", status: .waiting),
		ProgressItem(name: "B동 1층 공용실", time: "10:10", weight: "12(10.7kg)", status: .completed)
	]
	
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
				
				// 현재 진행중 헤더
				HStack {
					Text("현재 진행중")
						.font(.system(size: 14))
						.foregroundColor(.blue)
					Spacer()
				}
				.padding()
				.background(Color.blue.opacity(0.1))
				
				// 리스트
				ScrollView {
					VStack(spacing: 12) {
						ForEach(progressItems) { item in
							ProgressItemRow(item: item)
						}
					}
					.padding()
				}
				.background(Color.gray.opacity(0.05))
			}
			.navigationTitle("오늘 진행")
			.navigationBarTitleDisplayMode(.inline)
		}
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

struct ProgressItem: Identifiable {
	let id = UUID()
	let name: String
	let time: String
	let weight: String
	let status: ProgressStatus
}

enum ProgressStatus {
	case waiting
	case inProgress
	case completed
}

struct ProgressItemRow: View {
	let item: ProgressItem
	
	var body: some View {
		HStack(alignment: .top) {
			VStack(alignment: .leading, spacing: 4) {
				Text(item.name)
					.font(.system(size: 17, weight: .semibold))
				
				Text("\(item.time) · \(item.weight)")
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
		switch item.status {
			case .waiting:
				Text("대기")
					.font(.system(size: 14))
					.foregroundColor(.gray)
					.padding(.horizontal, 16)
					.padding(.vertical, 6)
					.background(Color.gray.opacity(0.2))
					.cornerRadius(6)
			case .inProgress:
				Text("이동")
					.font(.system(size: 14))
					.foregroundColor(.white)
					.padding(.horizontal, 16)
					.padding(.vertical, 6)
					.background(Color.black)
					.cornerRadius(6)
			case .completed:
				Text("완료")
					.font(.system(size: 14))
					.foregroundColor(.white)
					.padding(.horizontal, 16)
					.padding(.vertical, 6)
					.background(Color.blue)
					.cornerRadius(6)
		}
	}
}
