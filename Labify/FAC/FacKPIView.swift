//
//  FacKPIView.swift
//  Labify
//
//  Created by Assistant on 10/29/25.
//

import SwiftUI
import Charts

struct FacKPIView: View {
    @State private var selectedPeriod = 0 // 0: 전체 날짜, 1: 전체 지역
    @State private var selectedChartType = 0 // 0: 월별 처리량
    @State private var animateChart = false
    
    // 하드코딩된 데이터
    let monthlyData = [
        MonthlyWaste(date: "01", amount: 30),
        MonthlyWaste(date: "02", amount: 50),
        MonthlyWaste(date: "03", amount: 75),
        MonthlyWaste(date: "04", amount: 95),
        MonthlyWaste(date: "05", amount: 60),
        MonthlyWaste(date: "06", amount: 90),
        MonthlyWaste(date: "07", amount: 45),
        MonthlyWaste(date: "08", amount: 110),
        MonthlyWaste(date: "09", amount: 50),
        MonthlyWaste(date: "10", amount: 90)
    ]
    
    let labComparison = [
        LabData(name: "세포배양실", percentage: 95, cost: "0.4M"),
        LabData(name: "분자실", percentage: 90, cost: "0.5M"),
        LabData(name: "공용실", percentage: 86, cost: "0.3M")
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 상단 필터 버튼
                    HStack(spacing: 12) {
                        Button(action: {
                            withAnimation(.spring(response: 0.3)) { selectedPeriod = 0 }
                        }) {
                            Text("전체 날짜")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(selectedPeriod == 0 ? .white : Color.gray)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(selectedPeriod == 0 ? Color(red: 99/255, green: 102/255, blue: 241/255) : Color.white)
                                )
                        }
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.3)) { selectedPeriod = 1 }
                        }) {
                            Text("전체 지역")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(selectedPeriod == 1 ? .white : Color.gray)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(selectedPeriod == 1 ? Color(red: 99/255, green: 102/255, blue: 241/255) : Color.white)
                                )
                        }
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Text("CSV 내보내기")
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
                    
                    // KPI 카드
                    HStack(spacing: 12) {
                        KPICard(title: "처리율", value: "92%", trend: .up)
                        KPICard(title: "준수율", value: "88%", trend: .down)
                        KPICard(title: "비용(월)", value: "₩1.2M", trend: .neutral)
                    }
                    .padding(.horizontal, 20)
                    
                    // 월별 처리량 차트
                    VStack(alignment: .leading, spacing: 16) {
                        // 제목 박스
                        HStack {
                            Spacer()
                            Text("월별 처리량")
                                .font(.system(size: 17, weight: .semibold))
                            Spacer()
                        }
                        .padding(.vertical, 14)
                        .background(Color.white)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(red: 8/255, green: 58/255, blue: 167/255), lineWidth: 2.5)
                        )
                        .padding(.horizontal)
                        
                        ZStack {
                            // 배경 그라데이션
                            LinearGradient(
                                colors: [
                                    Color(red: 240/255, green: 242/255, blue: 255/255),
                                    Color.white
                                ],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("(kg)")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                    Spacer()
                                }
                                .padding(.top, 8)
                                .padding(.leading, 4)
                                
                                Chart {
                                    ForEach(monthlyData) { data in
                                        BarMark(
                                            x: .value("Date", data.date),
                                            y: .value("Amount", animateChart ? data.amount : 0)
                                        )
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [
                                                    Color(red: 30/255, green: 59/255, blue: 207/255),
                                                    Color(red: 113/255, green: 100/255, blue: 230/255)
                                                ],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .cornerRadius(6)
                                    }
                                }
                                .frame(height: 200)
                                .chartYScale(domain: 0...120)
                                .chartXAxis {
                                    AxisMarks(values: .automatic) { _ in
                                        AxisValueLabel()
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundStyle(Color.gray)
                                    }
                                }
                                .chartYAxis {
                                    AxisMarks(position: .leading, values: [0, 20, 40, 60, 80, 100, 120]) { _ in
                                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                                            .foregroundStyle(Color.gray.opacity(0.15))
                                        AxisValueLabel()
                                            .font(.system(size: 10, weight: .medium))
                                            .foregroundStyle(Color.gray)
                                    }
                                }
                                .padding(.top, 4)
                            }
                            .padding()
                        }
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(red: 200/255, green: 209/255, blue: 207/255), lineWidth: 2.5)
                        )
                        .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 6)
                        .padding(.horizontal)
                    }
                    
                    // 실험실별 비교
                    VStack(alignment: .leading, spacing: 16) {
                        // 제목 박스
                        HStack {
                            Spacer()
                            Text("실험실별 비교")
                                .font(.system(size: 17, weight: .semibold))
                            Spacer()
                        }
                        .padding(.vertical, 14)
                        .background(Color.white)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(red: 8/255, green: 58/255, blue: 167/255), lineWidth: 2.5)
                        )
                        .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            // 헤더
                            HStack {
                                Text("실험실")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text("처리율")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                
                                Text("비용(₩)")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color(red: 249/255, green: 250/255, blue: 251/255))
                            
                            Divider()
                            
                            // 데이터 행
                            ForEach(Array(labComparison.enumerated()), id: \.offset) { index, lab in
                                VStack(spacing: 0) {
                                    HStack {
                                        Text(lab.name)
                                            .font(.system(size: 14, weight: .medium))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        // 처리율 with 프로그레스 바
                                        HStack(spacing: 8) {
                                            Text("\(lab.percentage)%")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
                                                .frame(width: 40, alignment: .trailing)
                                            
                                            GeometryReader { geo in
                                                ZStack(alignment: .leading) {
                                                    RoundedRectangle(cornerRadius: 4)
                                                        .fill(Color(red: 30/255, green: 59/255, blue: 207/255).opacity(0.1))
                                                        .frame(height: 8)
                                                    
                                                    RoundedRectangle(cornerRadius: 4)
                                                        .fill(
                                                            LinearGradient(
                                                                colors: [
                                                                    Color(red: 30/255, green: 59/255, blue: 207/255),
                                                                    Color(red: 113/255, green: 100/255, blue: 230/255)
                                                                ],
                                                                startPoint: .leading,
                                                                endPoint: .trailing
                                                            )
                                                        )
                                                        .frame(width: animateChart ? geo.size.width * CGFloat(lab.percentage) / 100 : 0, height: 8)
                                                        .animation(.easeOut(duration: 1.0).delay(Double(index) * 0.1), value: animateChart)
                                                }
                                            }
                                            .frame(width: 60)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        
                                        Text(lab.cost)
                                            .font(.system(size: 14))
                                            .foregroundColor(.secondary)
                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 14)
                                    
                                    if index < labComparison.count - 1 {
                                        Divider()
                                            .padding(.leading, 20)
                                    }
                                }
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
                        )
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 20)
                .padding(.bottom, 100)
            }
            .background(Color(red: 249/255, green: 250/255, blue: 251/255))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("KPI 대시보드")
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

// MARK: - KPI 카드
struct KPICard: View {
    let title: String
    let value: String
    let trend: Trend
    
    enum Trend {
        case up, down, neutral
        
        var icon: String {
            switch self {
            case .up: return "▲"
            case .down: return "▼"
            case .neutral: return "–"
            }
        }
        
        var color: Color {
            switch self {
            case .up: return .red
            case .down: return .blue
            case .neutral: return .gray
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
                Spacer()
                Text(trend.icon)
                    .font(.system(size: 14))
                    .foregroundColor(trend.color)
            }
            
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color(red: 30/255, green: 41/255, blue: 59/255))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

// MARK: - 데이터 모델
struct MonthlyWaste: Identifiable {
    let id = UUID()
    let date: String
    let amount: Double
}

struct LabData: Identifiable {
    let id = UUID()
    let name: String
    let percentage: Int
    let cost: String
}

// MARK: - Preview
#Preview {
    FacKPIView()
}
