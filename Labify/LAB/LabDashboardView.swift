//
//  LabDashboardView.swift
//  Labify
//
//  Created by F_s on 9/22/25.
//

import SwiftUI

struct LabDashboardView: View {
    @State private var todayPickupCount = 3
    @State private var previewCount = 2
    @State private var estimatedRoute = "35분"
    @State private var showingWasteRegistration = false
    @State private var showingPickupRequest = false
    @State private var recentItems: [WasteItem] = [
        WasteItem(name: "감염성", weight: 1.2, time: "10:12"),
        WasteItem(name: "화학", weight: 2.6, time: "10:01"),
        WasteItem(name: "감염성", weight: 1.2, time: "09:12"),
        WasteItem(name: "감염성", weight: 1.2, time: "08:12"),
        WasteItem(name: "감염성", weight: 1.2, time: "08:00")
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 오늘 수거 예정 카드
                    VStack(spacing: 16) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("오늘 수거 예정")
                                    .font(.system(size: 15))
                                    .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
                                Text("\(todayPickupCount)건")
                                    .font(.system(size: 32, weight: .bold))
                            }
                            Spacer()
                            Button(action: {
                                showingPickupRequest = true
                            }) {
                                Text("수거 요청")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 28)
                                    .padding(.vertical, 14)
                                    .background(
                                        LinearGradient(
                                            colors: [Color(red: 30/255, green: 59/255, blue: 207/255),
                                                     Color(red: 113/255, green: 100/255, blue: 230/255)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .cornerRadius(24)
                            }
                        }
                    }
                    .padding(20)
                    .background(Color(red: 244/255, green: 247/255, blue: 255/255))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(red: 30/255, green: 59/255, blue: 207/255).opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 2)
                    
                    // 내일 미리보기 카드
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("내일 미리보기")
                                    .font(.system(size: 15))
                                    .foregroundColor(.gray)
                                Text("\(previewCount)건")
                                    .font(.system(size: 32, weight: .bold))
                            }
                            Spacer()
                            Text("루트 예측 \(estimatedRoute)")
                                .font(.system(size: 15))
                                .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
                        }
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                    
                    // 폐기물 등록 및 등록 이력 버튼
                    HStack(spacing: 12) {
                        Button(action: {
                            showingWasteRegistration = true
                        }) {
                            Text("폐기물 등록")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(
                                    LinearGradient(
                                        colors: [Color(red: 30/255, green: 59/255, blue: 207/255),
                                                 Color(red: 113/255, green: 100/255, blue: 230/255)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .cornerRadius(16)
                                .shadow(color: Color(red: 30/255, green: 59/255, blue: 207/255).opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        
                        Button(action: {}) {
                            Text("등록 이력")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(Color.white)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.gray.opacity(0.25), lineWidth: 1.5)
                                )
                                .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 2)
                        }
                    }
                    
                    // 보관 기한 임박 경고
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                            .font(.system(size: 16))
                        Text("보관 기한 임박 항목 1건 (D-1)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.red)
                        Spacer()
                    }
                    .padding(.vertical, 4)
                    
                    // 오늘 등록된 항목
                    VStack(alignment: .center, spacing: 16) {
                        Text("오늘 등록된 항목")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color(red: 244/255, green: 247/255, blue: 255/255))
                            .cornerRadius(12)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ], spacing: 12) {
                            ForEach(recentItems) { item in
                                VStack(spacing: 8) {
                                    Text(item.name)
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("\(String(format: "%.1f", item.weight))kg")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                    Text(item.time)
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .background(Color.white)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
                            }
                        }
                    }
                }
                .padding(20)
                .padding(.bottom, 100)
            }
            .background(Color.white)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("대시보드")
                        .font(.system(size: 17, weight: .semibold))
                }
            }
            .sheet(isPresented: $showingWasteRegistration) {
                LabRegistrationView()
            }
            .sheet(isPresented: $showingPickupRequest) {
                PickupRequestView()
            }
        }
    }
}

struct WasteItem: Identifiable {
    let id = UUID()
    let name: String
    let weight: Double
    let time: String
}

#Preview {
    LabDashboardView()
}
