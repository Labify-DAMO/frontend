//
//  TodayMapView.swift
//  Labify
//
//  Created by F_S on 10/30/25.
//

import SwiftUI

struct TodayMapView: View {
    @StateObject private var viewModel = PickupViewModel()
    @State private var selectedMarker: TodayPickupItem? = nil
    @State private var useMockData = true
    
    private var displayPickups: [TodayPickupItem] {
        useMockData ? TodayPickupItem.mockData : viewModel.todayPickups
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.95, green: 0.95, blue: 0.97)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    summaryHeader
                    mapArea
                }
            }
            .navigationTitle("오늘 수거")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        useMockData.toggle()
                        if !useMockData {
                            Task { await viewModel.fetchTodayPickups() }
                        }
                    }) {
                        Image(systemName: useMockData ? "eye.fill" : "eye.slash.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
            .task {
                if !useMockData {
                    await viewModel.fetchTodayPickups()
                }
            }
            .refreshable {
                await viewModel.fetchTodayPickups()
            }
            .sheet(item: $selectedMarker) { item in
                PickupDetailSheet(item: item, viewModel: viewModel)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
    
    // MARK: - Summary Header
    private var summaryHeader: some View {
        VStack(spacing: 12) {
            HStack(spacing: 20) {
                summaryItem(icon: "mappin.circle.fill", value: "\(displayPickups.count)", label: "지점", color: .blue)
                summaryItem(icon: "shippingbox.fill", value: "\(totalDisposalCount)", label: "총 건수", color: .orange)
                summaryItem(icon: "clock.fill", value: estimatedTime, label: "예상 시간", color: .green)
            }
            
            if !displayPickups.isEmpty {
                progressBar
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
    
    private func summaryItem(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 20, weight: .bold))
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var progressBar: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                Text("진행 상황")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(completedCount)/\(displayPickups.count) 완료")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.blue)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                    
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
                        .frame(width: geometry.size.width * progress)
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
            }
            .frame(height: 8)
        }
    }
    
    // MARK: - Map Area
    private var mapArea: some View {
        GeometryReader { geometry in
            ZStack {
                if displayPickups.isEmpty {
                    emptyMapView
                } else {
                    pathLines(in: geometry)
                    
                    ForEach(Array(displayPickups.enumerated()), id: \.element.id) { index, item in
                        let position = markerPosition(for: index, total: displayPickups.count, in: geometry)
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedMarker = item
                            }
                        }) {
                            MapMarkerView(
                                number: index + 1,
                                status: item.status,
                                isSelected: selectedMarker?.id == item.id
                            )
                        }
                        .position(position)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: selectedMarker?.id)
                    }
                }
            }
        }
        .padding()
    }
    
    private var emptyMapView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 60))
                .foregroundColor(.green.opacity(0.6))
            Text("오늘 수거 예정이 없습니다")
                .font(.system(size: 18, weight: .semibold))
            Text("'예정' 탭에서 다음 일정을 확인하세요")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func pathLines(in geometry: GeometryProxy) -> some View {
        Path { path in
            let positions = (0..<displayPickups.count).map { index in
                markerPosition(for: index, total: displayPickups.count, in: geometry)
            }
            guard !positions.isEmpty else { return }
            path.move(to: positions[0])
            for position in positions.dropFirst() {
                path.addLine(to: position)
            }
        }
        .stroke(
            style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round, dash: [10, 8])
        )
        .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255).opacity(0.6))
    }
    
    private func markerPosition(for index: Int, total: Int, in geometry: GeometryProxy) -> CGPoint {
        let width = geometry.size.width
        let height = geometry.size.height
        
        switch total {
        case 1:
            return CGPoint(x: width * 0.5, y: height * 0.5)
        case 2:
            let positions = [
                CGPoint(x: width * 0.3, y: height * 0.4),
                CGPoint(x: width * 0.7, y: height * 0.6)
            ]
            return positions[index]
        case 3:
            let positions = [
                CGPoint(x: width * 0.3, y: height * 0.25),
                CGPoint(x: width * 0.7, y: height * 0.5),
                CGPoint(x: width * 0.5, y: height * 0.75)
            ]
            return positions[index]
        case 4:
            let positions = [
                CGPoint(x: width * 0.25, y: height * 0.3),
                CGPoint(x: width * 0.7, y: height * 0.35),
                CGPoint(x: width * 0.6, y: height * 0.65),
                CGPoint(x: width * 0.3, y: height * 0.75)
            ]
            return positions[index]
        default:
            let angle = (2.0 * .pi / Double(total)) * Double(index) - .pi / 2
            let radius = min(width, height) * 0.32
            return CGPoint(
                x: width * 0.5 + radius * CGFloat(cos(angle)),
                y: height * 0.5 + radius * CGFloat(sin(angle))
            )
        }
    }
    
    // MARK: - Computed Properties
    private var totalDisposalCount: Int {
        displayPickups.count * 2
    }
    
    private var estimatedTime: String {
        "\(displayPickups.count * 15)분"
    }
    
    private var completedCount: Int {
        displayPickups.filter { $0.status == "COMPLETED" }.count
    }
    
    private var progress: Double {
        guard !displayPickups.isEmpty else { return 0 }
        return Double(completedCount) / Double(displayPickups.count)
    }
}
