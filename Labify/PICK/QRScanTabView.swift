//
//  QRScanTabView.swift
//  Labify
//
//  Created by F_S on 10/30/25.
//

import SwiftUI

struct QRScanTabView: View {
    @State private var showScanner = false
    @State private var useMockData = true
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                infoHeader
                recentScansSection
            }
            .background(Color(red: 0.98, green: 0.98, blue: 0.98))
            .navigationTitle("QR 스캔")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        useMockData.toggle()
                    }) {
                        Image(systemName: useMockData ? "eye.fill" : "eye.slash.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
            .fullScreenCover(isPresented: $showScanner) {
                QRScannerView()
            }
        }
    }
    
    private var infoHeader: some View {
        VStack(spacing: 20) {
            ZStack {
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
                    .frame(width: 120, height: 120)
                
                Image(systemName: "qrcode")
                    .font(.system(size: 60))
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
            }
            .padding(.top, 40)
            
            VStack(spacing: 8) {
                Text("폐기물 QR 코드 스캔")
                    .font(.system(size: 20, weight: .bold))
                
                Text("수거 완료 처리를 위해\nQR 코드를 스캔해주세요")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                showScanner = true
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 20))
                    Text("스캔 시작")
                        .font(.system(size: 18, weight: .semibold))
                }
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
                .shadow(color: Color(red: 30/255, green: 59/255, blue: 207/255).opacity(0.3), radius: 12, y: 6)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
    }
    
    private var recentScansSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("최근 스캔")
                    .font(.system(size: 18, weight: .bold))
                Spacer()
                if useMockData && !MockScanHistory.mockData.isEmpty {
                    Button(action: {}) {
                        Text("전체보기")
                            .font(.system(size: 14))
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            if useMockData && !MockScanHistory.mockData.isEmpty {
                VStack(spacing: 12) {
                    ForEach(MockScanHistory.mockData) { item in
                        ScanHistoryCard(history: item)
                    }
                }
                .padding(.horizontal)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 40))
                        .foregroundColor(.gray.opacity(0.4))
                    Text("최근 스캔 내역이 없습니다")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 60)
            }
        }
    }
}
