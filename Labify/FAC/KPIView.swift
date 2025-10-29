////
////  FacKPIView.swift
////  Labify
////
////  Created by F_s on 9/22/25.
////
//
//import SwiftUI
//import Charts
//
//struct FacKPIView: View {
//    @State private var selectedPeriod = 0 // 0: 주간, 1: 월간, 2: 연간
//    @State private var animateChart = false
//    
//    // KPI 데이터
//    let weeklyData: [KPIData] = [
//        KPIData(period: "월", value: 145, target: 150),
//        KPIData(period: "화", value: 158, target: 150),
//        KPIData(period: "수", value: 142, target: 150),
//        KPIData(period: "목", value: 167, target: 150),
//        KPIData(period: "금", value: 152, target: 150)
//    ]
//    
//    let monthlyData: [KPIData] = [
//        KPIData(period: "1월", value: 620, target: 600),
//        KPIData(period: "2월", value: 580, target: 600),
//        KPIData(period: "3월", value: 650, target: 600),
//        KPIData(period: "4월", value: 610, target: 600)
//    ]
//    
//    var currentData: [KPIData] {
//        selectedPeriod == 0 ? weeklyData : monthlyData
//    }
//    
//    var totalValue: Double {
//        currentData.reduce(0) { $0 + $1.value }
//    }
//    
//    var averageValue: Double {
//        totalValue / Double(currentData.count)
//    }
//    
//    var targetAchievement: Double {
//        let totalTarget = currentData.reduce(0) { $0 + $1.target }
//        return (totalValue / totalTarget) * 100
//    }
//    
//    var body: some View {
//        NavigationStack {
//            ScrollView {
//                VStack(spacing: 20) {
//                    // 기간 선택
//                    HStack(spacing: 12) {
//                        PeriodButton(title: "주간", isSelected: selectedPeriod == 0) {
//                            withAnimation(.spring(response: 0.3)) {
//                                selectedPeriod = 0
//                                animateChart = false
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                                    withAnimation(.easeOut(duration: 0.8)) {
//                                        animateChart = true
//                                    }
//                                }
//                            }
//                        }
//                        
//                        PeriodButton(title: "월간", isSelected: selectedPeriod == 1) {
//                            withAnimation(.spring(response: 0.3)) {
//                                selectedPeriod = 1
//                                animateChart = false
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                                    withAnimation(.easeOut(duration: 0.8)) {
//                                        animateChart = true
//                                    }
//                                }
//                            }
//                        }
//                        
//                        PeriodButton(title: "연간", isSelected: selectedPeriod == 2) {
//                            withAnimation(.spring(response: 0.3)) { selectedPeriod = 2 }
//                        }
//                        
//                        Spacer()
//                    }
//                    .padding(.horizontal, 20)
//                    .padding(.top, 8)
//                    
//                    // KPI 요약 카드
//                    HStack(spacing: 12) {
//                        KPISummaryCard(
//                            title: "평균 배출량",
//                            value: String(format: "%.0f", averageValue),
//                            unit: "kg",
//                            icon: "chart.bar.fill",
//                            color: Color(red: 99/255, green: 102/255, blue: 241/255)
//                        )
//                        
//                        KPISummaryCard(
//                            title: "목표 달성률",
//                            value: String(format: "%.0f", targetAchievement),
//                            unit: "%",
//                            icon: "target",
//                            color: targetAchievement >= 100 ? Color(red: 34/255, green: 197/255, blue: 94/255) : Color(red: 251/255, green: 146/255, blue: 60/255)
//                        )
//                    }
//                    .padding(.horizontal, 20)
//                    
//                    // 추세 분석 차트
//                    VStack(alignment: .leading, spacing: 0) {
//                        HStack {
//                            Text(selectedPeriod == 0 ? "주간 배출량 추이" : "월간 배출량 추이")
//                                .font(.system(size: 16, weight: .bold))
//                            Spacer()
//                            HStack(spacing: 12) {
//                                LegendItem(color: Color(red: 99/255, green: 102/255, blue: 241/255), label: "실제")
//                                LegendItem(color: Color(red: 248/255, green: 113/255, blue: 113/255), label: "목표")
//                            }
//                        }
//                        .padding(.horizontal, 20)
//                        .padding(.top, 20)
//                        .padding(.bottom, 16)
//                        
//                        Chart {
//                            ForEach(currentData) { data in
//                                // 목표선
//                                RuleMark(y: .value("Target", data.target))
//                                    .foregroundStyle(Color(red: 248/255, green: 113/255, blue: 113/255).opacity(0.5))
//                                    .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [5, 3]))
//                                
//                                // 실제 배출량 바
//                                BarMark(
//                                    x: .value("Period", data.period),
//                                    y: .value("Value", animateChart ? data.value : 0)
//                                )
//                                .foregroundStyle(
//                                    LinearGradient(
//                                        colors: [
//                                            Color(red: 99/255, green: 102/255, blue: 241/255),
//                                            Color(red: 139/255, green: 92/255, blue: 246/255)
//                                        ],
//                                        startPoint: .top,
//                                        endPoint: .bottom
//                                    )
//                                )
//                                .cornerRadius(8)
//                                .annotation(position: .top) {
//                                    if animateChart {
//                                        Text("\(Int(data.value))")
//                                            .font(.system(size: 11, weight: .semibold))
//                                            .foregroundColor(data.value > data.target ?
//                                                Color(red: 248/255, green: 113/255, blue: 113/255) :
//                                                Color(red: 34/255, green: 197/255, blue: 94/255))
//                                    }
//                                }
//                            }
//                        }
//                        .frame(height: 240)
//                        .chartYScale(domain: 0...(currentData.map { max($0.value, $0.target) }.max() ?? 200) * 1.2)
//                        .chartXAxis {
//                            AxisMarks(values: .automatic) { _ in
//                                AxisValueLabel()
//                                    .font(.system(size: 11, weight: .medium))
//                                    .foregroundStyle(Color.gray)
//                            }
//                        }
//                        .chartYAxis {
//                            AxisMarks(position: .leading) { _ in
//                                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
//                                    .foregroundStyle(Color.gray.opacity(0.15))
//                                AxisValueLabel()
//                                    .font(.system(size: 10, weight: .medium))
//                                    .foregroundStyle(Color.gray)
//                            }
//                        }
//                        .padding(.horizontal, 16)
//                        .padding(.bottom, 20)
//                    }
//                    .background(
//                        RoundedRectangle(cornerRadius: 20)
//                            .fill(Color.white)
//                            .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
//                    )
//                    .padding(.horizontal, 20)
//                    
//                    // 상세 데이터 테이블
//                    VStack(alignment: .leading, spacing: 0) {
//                        Text("상세 현황")
//                            .font(.system(size: 16, weight: .bold))
//                            .padding(.horizontal, 20)
//                            .padding(.top, 20)
//                            .padding(.bottom, 16)
//                        
//                        VStack(spacing: 0) {
//                            // 헤더
//                            HStack {
//                                Text("기간")
//                                    .font(.system(size: 13, weight: .semibold))
//                                    .foregroundColor(.gray)
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                
//                                Text("배출량")
//                                    .font(.system(size: 13, weight: .semibold))
//                                    .foregroundColor(.gray)
//                                    .frame(maxWidth: .infinity, alignment: .center)
//                                
//                                Text("목표")
//                                    .font(.system(size: 13, weight: .semibold))
//                                    .foregroundColor(.gray)
//                                    .frame(maxWidth: .infinity, alignment: .center)
//                                
//                                Text("달성률")
//                                    .font(.system(size: 13, weight: .semibold))
//                                    .foregroundColor(.gray)
//                                    .frame(maxWidth: .infinity, alignment: .trailing)
//                            }
//                            .padding(.horizontal, 20)
//                            .padding(.vertical, 12)
//                            .background(Color(red: 249/255, green: 250/255, blue: 251/255))
//                            
//                            Divider()
//                            
//                            // 데이터 행
//                            ForEach(Array(currentData.enumerated()), id: \.offset) { index, data in
//                                VStack(spacing: 0) {
//                                    HStack {
//                                        Text(data.period)
//                                            .font(.system(size: 14, weight: .medium))
//                                            .frame(maxWidth: .infinity, alignment: .leading)
//                                        
//                                        Text("\(Int(data.value))kg")
//                                            .font(.system(size: 14, weight: .semibold))
//                                            .foregroundColor(data.value > data.target ?
//                                                Color(red: 248/255, green: 113/255, blue: 113/255) :
//                                                Color(red: 34/255, green: 197/255, blue: 94/255))
//                                            .frame(maxWidth: .infinity, alignment: .center)
//                                        
//                                        Text("\(Int(data.target))kg")
//                                            .font(.system(size: 14))
//                                            .foregroundColor(.secondary)
//                                            .frame(maxWidth: .infinity, alignment: .center)
//                                        
//                                        let achievement = (data.value / data.target) * 100
//                                        Text(String(format: "%.0f%%", achievement))
//                                            .font(.system(size: 14, weight: .semibold))
//                                            .foregroundColor(achievement >= 100 ?
//                                                Color(red: 34/255, green: 197/255, blue: 94/255) :
//                                                Color(red: 99/255, green: 102/255, blue: 241/255))
//                                            .frame(maxWidth: .infinity, alignment: .trailing)
//                                    }
//                                    .padding(.horizontal, 20)
//                                    .padding(.vertical, 14)
//                                    
//                                    if index < currentData.count - 1 {
//                                        Divider()
//                                            .padding(.leading, 20)
//                                    }
//                                }
//                            }
//                        }
//                    }
//                    .background(
//                        RoundedRectangle(cornerRadius: 20)
//                            .fill(Color.white)
//                            .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
//                    )
//                    .padding(.horizontal, 20)
//                    
//                    // 개선 제안
//                    VStack(alignment: .leading, spacing: 16) {
//                        HStack(spacing: 8) {
//                            Image(systemName: "lightbulb.fill")
//                                .font(.system(size: 18, weight: .semibold))
//                                .foregroundColor(Color(red: 251/255, green: 146/255, blue: 60/255))
//                            Text("개선 제안")
//                                .font(.system(size: 16, weight: .bold))
//                        }
//                        
//                        VStack(spacing: 12) {
//                            SuggestionItem(
//                                icon: "arrow.down.circle.fill",
//                                title: "목표 초과 일자 감소 필요",
//                                description: "목표치를 초과한 날이 \(currentData.filter { $0.value > $0.target }.count)일 있습니다.",
//                                color: Color(red: 248/255, green: 113/255, blue: 113/255)
//                            )
//                            
//                            SuggestionItem(
//                                icon: "chart.line.uptrend.xyaxis",
//                                title: "배출량 추세 모니터링",
//                                description: "지속적인 모니터링으로 패턴을 파악하세요.",
//                                color: Color(red: 99/255, green: 102/255, blue: 241/255)
//                            )
//                        }
//                    }
//                    .padding(20)
//                    .background(
//                        RoundedRectangle(cornerRadius: 20)
//                            .fill(Color.white)
//                            .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
//                    )
//                    .padding(.horizontal, 20)
//                }
//                .padding(.bottom, 100)
//            }
//            .background(Color(red: 249/255, green: 250/255, blue: 251/255))
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .principal) {
//                    Text("시설 KPI")
//                        .font(.system(size: 17, weight: .bold))
//                }
//            }
//            .onAppear {
//                withAnimation(.easeOut(duration: 1.2).delay(0.2)) {
//                    animateChart = true
//                }
//            }
//        }
//    }
//}
//
//// MARK: - Period Button
//struct PeriodButton: View {
//    let title: String
//    let isSelected: Bool
//    let action: () -> Void
//    
//    var body: some View {
//        Button(action: action) {
//            Text(title)
//                .font(.system(size: 14, weight: .semibold))
//                .foregroundColor(isSelected ? .white : Color.gray)
//                .padding(.horizontal, 20)
//                .padding(.vertical, 10)
//                .background(
//                    RoundedRectangle(cornerRadius: 10)
//                        .fill(isSelected ? Color(red: 99/255, green: 102/255, blue: 241/255) : Color.white)
//                        .shadow(color: isSelected ? Color(red: 99/255, green: 102/255, blue: 241/255).opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
//                )
//        }
//    }
//}
//
//// MARK: - KPI Summary Card
//struct KPISummaryCard: View {
//    let title: String
//    let value: String
//    let unit: String
//    let icon: String
//    let color: Color
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            HStack {
//                Image(systemName: icon)
//                    .font(.system(size: 20, weight: .semibold))
//                    .foregroundColor(color)
//                Spacer()
//            }
//            
//            VStack(alignment: .leading, spacing: 4) {
//                Text(title)
//                    .font(.system(size: 12, weight: .medium))
//                    .foregroundColor(.gray)
//                
//                HStack(alignment: .firstTextBaseline, spacing: 2) {
//                    Text(value)
//                        .font(.system(size: 28, weight: .bold))
//                        .foregroundColor(color)
//                    Text(unit)
//                        .font(.system(size: 14, weight: .semibold))
//                        .foregroundColor(color.opacity(0.7))
//                }
//            }
//        }
//        .padding(20)
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .background(
//            RoundedRectangle(cornerRadius: 16)
//                .fill(
//                    LinearGradient(
//                        colors: [color.opacity(0.08), color.opacity(0.03)],
//                        startPoint: .topLeading,
//                        endPoint: .bottomTrailing
//                    )
//                )
//        )
//        .overlay(
//            RoundedRectangle(cornerRadius: 16)
//                .stroke(color.opacity(0.2), lineWidth: 1)
//        )
//    }
//}
//
//// MARK: - Legend Item
//struct LegendItem: View {
//    let color: Color
//    let label: String
//    
//    var body: some View {
//        HStack(spacing: 6) {
//            RoundedRectangle(cornerRadius: 3)
//                .fill(color)
//                .frame(width: 12, height: 12)
//            Text(label)
//                .font(.system(size: 11, weight: .medium))
//                .foregroundColor(.gray)
//        }
//    }
//}
//
//// MARK: - Suggestion Item
//struct SuggestionItem: View {
//    let icon: String
//    let title: String
//    let description: String
//    let color: Color
//    
//    var body: some View {
//        HStack(alignment: .top, spacing: 12) {
//            Image(systemName: icon)
//                .font(.system(size: 18, weight: .semibold))
//                .foregroundColor(color)
//                .frame(width: 24)
//            
//            VStack(alignment: .leading, spacing: 4) {
//                Text(title)
//                    .font(.system(size: 14, weight: .semibold))
//                    .foregroundColor(Color(red: 30/255, green: 41/255, blue: 59/255))
//                
//                Text(description)
//                    .font(.system(size: 12, weight: .medium))
//                    .foregroundColor(Color(red: 100/255, green: 116/255, blue: 139/255))
//                    .fixedSize(horizontal: false, vertical: true)
//            }
//        }
//        .padding(16)
//        .background(
//            RoundedRectangle(cornerRadius: 12)
//                .fill(color.opacity(0.05))
//        )
//    }
//}
//
//// MARK: - 데이터 모델
//struct KPIData: Identifiable {
//    let id = UUID()
//    let period: String
//    let value: Double
//    let target: Double
//}
//
//// MARK: - Preview
//#Preview {
//    FacKPIView()
//}
