//
//  FacilityJoinRequestCard.swift
//  Labify
//
//  Created by F_S on 10/29/25.
//

import SwiftUI

struct FacilityJoinRequestCard: View {
    let request: FacilityJoinRequestItem
    let onConfirm: () -> Void
    let onReject: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 헤더
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(request.userName)
                        .font(.system(size: 17, weight: .semibold))
                    
//                    Text(request.userEmail)
//                        .font(.system(size: 14))
//                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // 상태 배지
                Text(statusText(request.status))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(statusColor(request.status))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(statusColor(request.status).opacity(0.1))
                    .cornerRadius(12)
            }
            
            Divider()
            
            // 요청 정보
            VStack(alignment: .leading, spacing: 8) {
//                FInfoRow(icon: "number.circle", title: "시설 코드", value: request.facilityCode)
                FInfoRow(icon: "calendar", title: "요청일", value: formatDate(request.createdAt))
            }
            
            // 액션 버튼 (PENDING 상태일 때만 표시)
            if request.status == "PENDING" {
                HStack(spacing: 12) {
                    Button(action: onReject) {
                        Text("거절")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(10)
                    }
                    
                    Button(action: onConfirm) {
                        Text("승인")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                LinearGradient(
                                    colors: [Color(red: 30/255, green: 59/255, blue: 207/255),
                                             Color(red: 113/255, green: 100/255, blue: 230/255)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .cornerRadius(10)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private func statusText(_ status: String) -> String {
        switch status {
        case "PENDING":
            return "대기중"
        case "APPROVED":
            return "승인됨"
        case "REJECTED":
            return "거절됨"
        default:
            return status
        }
    }
    
    private func statusColor(_ status: String) -> Color {
        switch status {
        case "PENDING":
            return .orange
        case "APPROVED":
            return .green
        case "REJECTED":
            return .red
        default:
            return .gray
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        displayFormatter.locale = Locale(identifier: "ko_KR")
        return displayFormatter.string(from: date)
    }
}

// MARK: - Info Row Component
private struct FInfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .frame(width: 20)
            
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .frame(width: 60, alignment: .leading)
            
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        FacilityJoinRequestCard(
            request: FacilityJoinRequestItem(
                id: 1,
                userName: "김연구",
                //userEmail: "kim@research.com",
                //facilityCode: "8XDGRA",
                createdAt: "2025-10-28T10:30:00Z",
                status: "PENDING"
            ),
            onConfirm: { print("승인") },
            onReject: { print("거절") }
        )
        
        FacilityJoinRequestCard(
            request: FacilityJoinRequestItem(
                id: 2,
                userName: "박실험",
                //userEmail: "park@lab.com",
                //facilityCode: "AB12CD",
                createdAt: "2025-10-27T14:20:00Z",
                status: "APPROVED"
            ),
            onConfirm: { print("승인") },
            onReject: { print("거절") }
        )
    }
    .padding()
    .background(Color(white: 0.95))
}
