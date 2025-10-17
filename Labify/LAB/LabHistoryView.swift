//
//  LabHistoryView.swift
//  Labify
//
//  Created by KITS on 10/13/25.
//

import SwiftUI

struct LabHistoryView: View {
    @State private var selectedTab = 0
    @State private var historyItems: [LHistoryItem] = [
        LHistoryItem(type: "감염성", weight: 1.2, time: "10:12", status: .waiting),
        LHistoryItem(type: "감염성", weight: 1.2, time: "10:12", status: .collecting),
        LHistoryItem(type: "감염성", weight: 1.2, time: "10:12", status: .completed)
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 탭 선택
                HStack(spacing: 0) {
                    LTabButton(title: "전체", isSelected: selectedTab == 0) {
                        selectedTab = 0
                    }
                    LTabButton(title: "대기", isSelected: selectedTab == 1) {
                        selectedTab = 1
                    }
                    LTabButton(title: "수거요청", isSelected: selectedTab == 2) {
                        selectedTab = 2
                    }
                    LTabButton(title: "완료", isSelected: selectedTab == 3) {
                        selectedTab = 3
                    }
                }
                .padding(.horizontal)
                .background(Color.white)
                
                Divider()
                
                // 이력 리스트
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(historyItems) { item in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(item.type) · \(String(format: "%.1f", item.weight))kg · \(item.time)")
                                        .font(.system(size: 16, weight: .medium))
                                }
                                Spacer()
                                
                                Text(item.status.rawValue)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(item.status.color)
                                    .cornerRadius(8)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                        }
                    }
                    .padding()
                }
                .background(Color(UIColor.systemGroupedBackground))
            }
            .navigationTitle("등록 이력")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct LTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .primary : .gray)
                    .padding(.vertical, 12)
                
                if isSelected {
                    Rectangle()
                        .fill(Color.primary)
                        .frame(height: 2)
                } else {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 2)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct LHistoryItem: Identifiable {
    let id = UUID()
    let type: String
    let weight: Double
    let time: String
    let status: ItemStatus
}

enum ItemStatus: String {
    case waiting = "대기"
    case collecting = "요청중"
    case completed = "완료"
    
    var color: Color {
        switch self {
        case .waiting:
            return .black
        case .collecting:
            return .gray
        case .completed:
            return .blue
        }
    }
}

#Preview {
    LabHistoryView()
}
