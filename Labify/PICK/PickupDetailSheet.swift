//
//  PickupDetailSheet.swift
//  Labify
//
//  Created by F_S on 10/30/25.
//


import SwiftUI

struct PickupDetailSheet: View {
    let item: TodayPickupItem
    @ObservedObject var viewModel: PickupViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isUpdating = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        Image(systemName: "building.2")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        Text(item.labName)
                            .font(.system(size: 24, weight: .bold))
                        Text(item.labLocation)
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    VStack(spacing: 16) {
                        infoRow(icon: "mappin.circle.fill", title: "주소", value: item.facilityAddress)
                        Divider()
                        infoRow(
                            icon: "flag.circle.fill",
                            title: "상태",
                            value: statusText(item.status),
                            valueColor: statusColor(item.status)
                        )
                        Divider()
                        infoRow(icon: "shippingbox.fill", title: "폐기물", value: "2건")
                        Divider()
                        infoRow(icon: "clock.fill", title: "예상 시간", value: "30분")
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
                    
                    if item.status != "COMPLETED" && item.status != "CANCELED" {
                        statusChangeButtons
                    }
                    
                    Button(action: {}) {
                        HStack(spacing: 8) {
                            Image(systemName: "map")
                            Text("지도 앱에서 열기")
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .background(Color(red: 0.98, green: 0.98, blue: 0.98))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("닫기") { dismiss() }
                }
            }
            .overlay {
                if isUpdating {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
        }
    }
    
    private var statusChangeButtons: some View {
        HStack(spacing: 12) {
            if item.status == "REQUESTED" {
                actionButton(title: "수거 시작", icon: "play.fill", color: .blue, status: .processing)
            }
            if item.status == "PROCESSING" {
                actionButton(title: "수거 완료", icon: "checkmark.circle.fill", color: .green, status: .completed)
            }
        }
    }
    
    private func actionButton(title: String, icon: String, color: Color, status: PickupItemStatus) -> some View {
        Button(action: {
            isUpdating = true
            Task {
                let success = await viewModel.updatePickupStatus(
                    pickupId: item.pickupId,
                    status: status
                )
                isUpdating = false
                if success {
                    try? await Task.sleep(nanoseconds: 500_000_000)
                    dismiss()
                }
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                Text(title)
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(color)
            .cornerRadius(12)
            .shadow(color: color.opacity(0.3), radius: 8, y: 4)
        }
        .disabled(isUpdating)
    }
    
    private func infoRow(icon: String, title: String, value: String, valueColor: Color = .primary) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.blue)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(valueColor)
            }
            
            Spacer()
        }
    }
    
    private func statusText(_ status: String) -> String {
        switch status {
        case "REQUESTED": return "대기중"
        case "PROCESSING": return "수거중"
        case "COMPLETED": return "완료"
        case "CANCELED": return "취소"
        default: return status
        }
    }
    
    private func statusColor(_ status: String) -> Color {
        switch status {
        case "REQUESTED": return .orange
        case "PROCESSING": return .blue
        case "COMPLETED": return .green
        case "CANCELED": return .red
        default: return .gray
        }
    }
}
