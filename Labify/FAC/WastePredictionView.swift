//
//  WastePredictionView.swift
//  Labify
//
//  Created by F_S on 10/29/25.
//

import SwiftUI
import Charts

struct WastePredictionView: View {
    @State private var selectedTab = 0
    @State private var selectedCategory = 0
    @State private var animateChart = false
    
    let predictionData: [WastePrediction] = [
        WastePrediction(week: "1주", amount: 45, isActual: true),
        WastePrediction(week: "2주", amount: 52, isActual: true),
        WastePrediction(week: "3주", amount: 48, isActual: true),
        WastePrediction(week: "4주", amount: 58, isActual: false),
        WastePrediction(week: "5주", amount: 62, isActual: false)
    ]
    
    let labPredictions = [
        LabPrediction(name: "세포배양실", predicted: 28, cost: 320000, alert: true),
        LabPrediction(name: "분자실", predicted: 22, cost: 250000, alert: false),
        LabPrediction(name: "공용실", predicted: 12, cost: 140000, alert: false)
    ]
    
    var totalPredicted: Double {
        labPredictions.reduce(0) { $0 + $1.predicted }
    }
    
    var totalCost: Int {
        labPredictions.reduce(0) { $0 + $1.cost }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 상단 탭
                    HStack(spacing: 12) {
                        WTabButton(title: "전체 날짜", isSelected: selectedTab == 0) {
                            withAnimation(.spring(response: 0.3)) { selectedTab = 0 }
                        }
                        
                        WTabButton(title: "전체 시설", isSelected: selectedTab == 1) {
                            withAnimation(.spring(response: 0.3)) { selectedTab = 1 }
                        }
                        
                        Spacer()
                        
                        Button(action: { withAnimation(.spring(response: 0.3)) { selectedTab = 2 } }) {
                            Text("설명 보기")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 11)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(red: 99/255, green: 102/255, blue: 241/255))
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    if selectedTab == 2 {
                        // 설명 보기 화면
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack(spacing: 8) {
                                    Image(systemName: "chart.line.uptrend.xyaxis")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(Color(red: 99/255, green: 102/255, blue: 241/255))
                                    Text("예측 가이드")
                                        .font(.system(size: 18, weight: .bold))
                                }
                                
                                Divider()
                                    .padding(.vertical, 4)
                                
                                VStack(alignment: .leading, spacing: 14) {
                                    InfoBullet(icon: "calendar", text: "지난 12개월 데이터 기반 생물 예측(근사)", color: Color(red: 99/255, green: 102/255, blue: 241/255))
                                    InfoBullet(icon: "chart.bar.fill", text: "실제 모델 연장 전과지 UI 검증용", color: Color(red: 59/255, green: 130/255, blue: 246/255))
                                }
                            }
                            .padding(24)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
                            )
                        }
                        .padding(.horizontal, 20)
                    } else {
                        // 차트 카드
                        VStack(alignment: .leading, spacing: 0) {
                            Text("월별 발생량(예측)")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.gray)
                                .padding(.horizontal, 20)
                                .padding(.top, 18)
                                .padding(.bottom, 6)
                            
                            // 차트 영역
                            ZStack(alignment: .topTrailing) {
                                // 그래프
                                Chart {
                                    ForEach(predictionData) { data in
                                        LineMark(
                                            x: .value("Week", data.week),
                                            y: .value("Amount", animateChart ? data.amount : 0)
                                        )
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: data.isActual ?
                                                    [Color(red: 99/255, green: 102/255, blue: 241/255)] :
                                                    [Color(red: 139/255, green: 92/255, blue: 246/255)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round))
                                        
                                        AreaMark(
                                            x: .value("Week", data.week),
                                            y: .value("Amount", animateChart ? data.amount : 0)
                                        )
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: data.isActual ?
                                                    [Color(red: 99/255, green: 102/255, blue: 241/255).opacity(0.15), Color.clear] :
                                                    [Color(red: 139/255, green: 92/255, blue: 246/255).opacity(0.15), Color.clear],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        
                                        PointMark(
                                            x: .value("Week", data.week),
                                            y: .value("Amount", animateChart ? data.amount : 0)
                                        )
                                        .foregroundStyle(data.isActual ?
                                            Color(red: 99/255, green: 102/255, blue: 241/255) :
                                            Color(red: 139/255, green: 92/255, blue: 246/255))
                                        .symbolSize(80)
                                    }
                                }
                                .frame(height: 200)
                                .chartYScale(domain: 0...70)
                                .chartXAxis {
                                    AxisMarks(values: .automatic) { _ in
                                        AxisValueLabel()
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundStyle(Color.gray)
                                    }
                                }
                                .chartYAxis {
                                    AxisMarks(position: .leading, values: [0, 20, 40, 60]) { _ in
                                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                                            .foregroundStyle(Color.gray.opacity(0.15))
                                        AxisValueLabel()
                                            .font(.system(size: 10, weight: .medium))
                                            .foregroundStyle(Color.gray)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.bottom, 12)
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(red: 250/255, green: 250/255, blue: 255/255), Color.white],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
                        )
                        .padding(.horizontal, 20)
                        
                        // 카테고리 필터
                        HStack(spacing: 12) {
                            CategoryButton(title: "감염성", isSelected: selectedCategory == 0) {
                                selectedCategory = 0
                            }
                            CategoryButton(title: "화학", isSelected: selectedCategory == 1) {
                                selectedCategory = 1
                            }
                            CategoryButton(title: "일반", isSelected: selectedCategory == 2) {
                                selectedCategory = 2
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // 예측 가이드
                        VStack(alignment: .leading, spacing: 12) {
                            Text("예측 가이드")
                                .font(.system(size: 16, weight: .bold))
                            
                            VStack(spacing: 10) {
                                GuideBullet(text: "지난 12개월 데이터 기반 생물 예측(근사)")
                                GuideBullet(text: "실제 모델 연장 전과지 UI 검증용")
                            }
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
                        )
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 100)
            }
            .background(Color(red: 249/255, green: 250/255, blue: 251/255))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("발생량 예측")
                        .font(.system(size: 17, weight: .bold))
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 1.2).delay(0.2)) {
                    animateChart = true
                }
            }
        }
    }
}

// MARK: - Tab Button
struct WTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isSelected ? .white : Color.gray)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? Color(red: 229/255, green: 231/255, blue: 235/255) : Color.white)
                )
        }
    }
}

// MARK: - Category Button
struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .semibold : .medium))
                .foregroundColor(isSelected ? Color(red: 99/255, green: 102/255, blue: 241/255) : Color.gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color(red: 99/255, green: 102/255, blue: 241/255).opacity(0.08) : Color.white)
                )
        }
    }
}

// MARK: - Info Bullet
struct InfoBullet: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(red: 71/255, green: 85/255, blue: 105/255))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Guide Bullet
struct GuideBullet: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(Color(red: 99/255, green: 102/255, blue: 241/255))
                .frame(width: 6, height: 6)
                .padding(.top, 6)
            
            Text(text)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color(red: 100/255, green: 116/255, blue: 139/255))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - 데이터 모델
struct WastePrediction: Identifiable {
    let id = UUID()
    let week: String
    let amount: Double
    let isActual: Bool
}

struct LabPrediction: Identifiable {
    let id = UUID()
    let name: String
    let predicted: Double
    let cost: Int
    let alert: Bool
}

// MARK: - Preview
#Preview {
    WastePredictionView()
}
