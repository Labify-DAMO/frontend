//
//  SchedulePickupCard.swift
//  Labify
//
//  Created by F_S on 10/30/25.
//


import SwiftUI

struct SchedulePickupCard: View {
    let item: TomorrowPickupItem
    let filter: ScheduleFilter
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.labName)
                        .font(.system(size: 17, weight: .semibold))
                    Text(item.labLocation)
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text(dateLabel)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(dateColor)
                    Text(dateValue)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(dateColor.opacity(0.1))
                .cornerRadius(8)
            }
            
            HStack(spacing: 6) {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(.blue)
                Text(item.facilityAddress)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            HStack(spacing: 12) {
                Label("2건", systemImage: "shippingbox.fill")
                    .font(.system(size: 13))
                    .foregroundColor(.orange)
                
                Label("예상 30분", systemImage: "clock")
                    .font(.system(size: 13))
                    .foregroundColor(.green)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private var dateLabel: String {
        switch filter {
        case .today: return "오늘"
        case .tomorrow: return "내일"
        case .thisWeek: return "이번주"
        case .nextWeek: return "다음주"
        case .all: return "예정"
        }
    }
    
    private var dateValue: String {
        switch filter {
        case .today: return "10/30"
        case .tomorrow: return "10/31"
        case .thisWeek: return "11/01"
        case .nextWeek: return "11/08"
        case .all: return "10/31"
        }
    }
    
    private var dateColor: Color {
        switch filter {
        case .today: return .orange
        case .tomorrow: return .blue
        case .thisWeek: return .green
        case .nextWeek: return .purple
        case .all: return .gray
        }
    }
}
