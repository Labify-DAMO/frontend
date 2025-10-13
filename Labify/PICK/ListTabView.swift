//
//  ListTabView.swift
//  Labify
//
//  Created by F_s on 9/29/25.
//


// =========================================
// ListTabView.swift
// 목록 탭

import SwiftUI

struct ListTabView: View {
	let scheduleItems = [
		ScheduleItem(name: "A동 3층 세탁배방실", time: "08:30", weight: "321(4.2kg)"),
		ScheduleItem(name: "A동 2층 분식당", time: "09:10", weight: "12(12.1kg)"),
		ScheduleItem(name: "C동 2층 분식당", time: "09:40", weight: "12(10.7kg)"),
		ScheduleItem(name: "B동 1층 공용실", time: "10:10", weight: "12(10.7kg)")
	]
	
	var body: some View {
		ScrollView {
			VStack(spacing: 12) {
				ForEach(scheduleItems) { item in
					ScheduleItemRow(item: item)
				}
			}
			.padding()
		}
		.background(Color.gray.opacity(0.05))
	}
}

struct ScheduleItem: Identifiable {
	let id = UUID()
	let name: String
	let time: String
	let weight: String
}

struct ScheduleItemRow: View {
	let item: ScheduleItem
	
	var body: some View {
		VStack(alignment: .leading, spacing: 4) {
			Text(item.name)
				.font(.system(size: 17, weight: .semibold))
			
			Text("\(item.time) · \(item.weight)")
				.font(.system(size: 14))
				.foregroundColor(.gray)
		}
		.frame(maxWidth: .infinity, alignment: .leading)
		.padding()
		.background(Color.white)
		.cornerRadius(12)
		.shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
	}
}
