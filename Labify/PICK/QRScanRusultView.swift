//
//  QRScanResultView.swift
//  Labify
//
//  Created by F_S on 10/30/25.
//

import SwiftUI

struct QRScanResultView: View {
    @Environment(\.dismiss) private var dismiss
    let scanResult: QRScanResponse
    let onComplete: () -> Void
    
    @State private var showSuccessAnimation = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()
                
                // 성공 애니메이션
                successAnimation
                
                // 결과 정보
                resultInfo
                
                Spacer()
                
                // 액션 버튼
                actionButtons
            }
            .padding(20)
            .background(Color(red: 249/255, green: 250/255, blue: 252/255))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("수거 완료")
                        .font(.system(size: 17, weight: .semibold))
                }
            }
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    showSuccessAnimation = true
                }
            }
        }
        .presentationDragIndicator(.visible)
    }
    
    // MARK: - 성공 애니메이션
    private var successAnimation: some View {
        ZStack {
            // 배경 원
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 30/255, green: 59/255, blue: 207/255).opacity(0.1),
                            Color(red: 113/255, green: 100/255, blue: 230/255).opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 160, height: 160)
                .scaleEffect(showSuccessAnimation ? 1 : 0)
            
            // 체크 아이콘
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 30/255, green: 59/255, blue: 207/255),
                            Color(red: 113/255, green: 100/255, blue: 230/255)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .scaleEffect(showSuccessAnimation ? 1 : 0)
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: showSuccessAnimation)
        }
    }
    
    // MARK: - 결과 정보
    private var resultInfo: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Text("수거가 완료되었습니다")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("폐기물이 정상적으로 처리되었습니다")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
            
            // 상세 정보 카드
            VStack(spacing: 16) {
                infoRow(
                    icon: "checkmark.seal.fill",
                    title: "처리 상태",
                    value: scanResult.status == "PICKED_UP" ? "수거 완료" : scanResult.status
                )
                
                Divider()
                
                infoRow(
                    icon: "cube.box.fill",
                    title: "폐기물 ID",
                    value: "#\(scanResult.disposalId)"
                )
                
                Divider()
                
                infoRow(
                    icon: "clock.fill",
                    title: "처리 시간",
                    value: formatDateTime(scanResult.processedAt)
                )
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        }
        .opacity(showSuccessAnimation ? 1 : 0)
        .offset(y: showSuccessAnimation ? 0 : 20)
        .animation(.easeOut(duration: 0.4).delay(0.2), value: showSuccessAnimation)
    }
    
    // MARK: - 정보 Row
    private func infoRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
    }
    
    // MARK: - 액션 버튼
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: {
                dismiss()
                onComplete()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "qrcode.viewfinder")
                    Text("다음 QR 스캔")
                }
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 30/255, green: 59/255, blue: 207/255),
                            Color(red: 113/255, green: 100/255, blue: 230/255)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(14)
                .shadow(color: Color(red: 30/255, green: 59/255, blue: 207/255).opacity(0.3), radius: 8, y: 4)
            }
            
            Button(action: {
                dismiss()
            }) {
                Text("닫기")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color(red: 30/255, green: 59/255, blue: 207/255), lineWidth: 1.5)
                    )
            }
        }
        .opacity(showSuccessAnimation ? 1 : 0)
        .animation(.easeOut(duration: 0.4).delay(0.3), value: showSuccessAnimation)
    }
    
    // MARK: - Helper Functions
    private func formatDateTime(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "yyyy년 MM월 dd일 HH:mm"
        displayFormatter.locale = Locale(identifier: "ko_KR")
        return displayFormatter.string(from: date)
    }
}

#Preview {
    QRScanResultView(
        scanResult: QRScanResponse(
            disposalId: 101,
            status: "PICKED_UP",
            processedAt: ISO8601DateFormatter().string(from: Date())
        ),
        onComplete: {}
    )
}
