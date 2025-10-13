//
//  HistoryTabView.swift
//  Labify
//
//  Created by F_s on 9/29/25.
//

// =========================================
// HistoryTabView.swift
// 처리 이력 탭

import SwiftUI

struct HistoryTabView: View {
	@State private var selectedMonth = "9월"
	@State private var selectedRegion = "전체 지역"
	@State private var showMonthPicker = false
	@State private var showRegionPicker = false
	
	let months = ["8월", "9월", "10월", "11월", "12월"]
	let regions = ["전체 지역", "서울 영등포", "서울 강남", "서울 마포", "경기 성남"]
	
	let historyItems = [
		HistoryItem(date: "2025-09-05", name: "A동 3층", count: "3건", weight: "4.2kg", time: "이00", location: "서울 영등포"),
		HistoryItem(date: "2025-09-04", name: "A동 2층", count: "2건", weight: "2.1kg", time: "박00", location: "서울 영등포"),
		HistoryItem(date: "2025-09-03", name: "B동 1층", count: "1건", weight: "0.7kg", time: "정00", location: "서울 영등포"),
		HistoryItem(date: "2025-10-01", name: "C동 4층", count: "2건", weight: "3.5kg", time: "김00", location: "서울 강남"),
		HistoryItem(date: "2025-10-02", name: "D동 1층", count: "4건", weight: "5.8kg", time: "최00", location: "서울 마포")
	]
	
	var filteredItems: [HistoryItem] {
		historyItems.filter { item in
			let monthMatch = selectedMonth == "전체" || item.date.contains(selectedMonth == "9월" ? "09" : selectedMonth == "10월" ? "10" : selectedMonth == "8월" ? "08" : selectedMonth == "11월" ? "11" : "12")
			let regionMatch = selectedRegion == "전체 지역" || item.location.contains(selectedRegion.replacingOccurrences(of: "서울 ", with: ""))
			return monthMatch && regionMatch
		}
	}
	
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
						Text(selectedMonth)
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
						Text(selectedRegion)
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
				Button(action: {}) {
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
								selectedMonth = item
								showMonthPicker = false
							} else {
								selectedRegion = item
								showRegionPicker = false
							}
						}) {
							HStack {
								Text(item)
									.font(.system(size: 15))
									.foregroundColor(.black)
								Spacer()
								if (showMonthPicker && item == selectedMonth) || (!showMonthPicker && item == selectedRegion) {
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
			ScrollView {
				VStack(spacing: 12) {
					ForEach(filteredItems) { item in
						HistoryItemRow(item: item)
					}
					
					Button(action: {}) {
						Text("더 불러오기...")
							.font(.system(size: 14))
							.foregroundColor(.gray)
					}
					.padding(.vertical, 20)
				}
				.padding()
			}
			.background(Color(red: 0.98, green: 0.98, blue: 0.98))
		}
	}
}

struct HistoryItem: Identifiable {
	let id = UUID()
	let date: String
	let name: String
	let count: String
	let weight: String
	let time: String
	let location: String
}

struct HistoryItemRow: View {
	let item: HistoryItem
	
	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			Text("\(item.date) · \(item.name) · \(item.count)(\(item.weight))")
				.font(.system(size: 15, weight: .medium))
				.foregroundColor(.black)
			
			Text("기사: \(item.time) · \(item.location)")
				.font(.system(size: 13))
				.foregroundColor(.gray)
		}
		.frame(maxWidth: .infinity, alignment: .leading)
		.padding(.horizontal, 20)
		.padding(.vertical, 16)
		.background(Color.white)
		.cornerRadius(12)
		.shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
	}
}
