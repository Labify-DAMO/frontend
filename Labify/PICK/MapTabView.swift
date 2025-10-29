//
//  MapTabView.swift
//  Labify
//
//  Created by F_s on 10/29/25.
//

import SwiftUI

struct MapTabView: View {
    @State private var selectedMarker: Int? = nil
    
    var body: some View {
        ZStack {
            // 연한 회색 배경
            Color(red: 0.95, green: 0.95, blue: 0.97)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 상단 정보 박스
                VStack(spacing: 8) {
                    Text("경로상의 지점을 누르면 상세 주소를 확인할 수 있습니다.")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 4) {
                        Text("3개 지점")
                            .foregroundColor(.blue)
                        Text("·")
                            .foregroundColor(.gray)
                        Text("총 4건")
                            .foregroundColor(.blue)
                        Text("·")
                            .foregroundColor(.gray)
                        Text("45분 예상")
                            .foregroundColor(.blue)
                    }
                    .font(.system(size: 14, weight: .medium))
                }
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                
                // 지도 영역
                GeometryReader { geometry in
                    ZStack {
                        // 점선 경로
                        Path { path in
                            let marker2 = CGPoint(x: geometry.size.width * 0.3, y: geometry.size.height * 0.2)
                            let marker1a = CGPoint(x: geometry.size.width * 0.7, y: geometry.size.height * 0.5)
                            let marker1b = CGPoint(x: geometry.size.width * 0.5, y: geometry.size.height * 0.8)
                            
                            path.move(to: marker2)
                            path.addLine(to: marker1a)
                            path.addLine(to: marker1b)
                        }
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [8, 8]))
                        .foregroundColor(.black.opacity(0.8))
                        
                        // 마커들 (위쪽 2개는 장식용, 아래 1개만 클릭 가능)
                        MapMarker(number: 2, isInteractive: false)
                            .position(x: geometry.size.width * 0.3, y: geometry.size.height * 0.2)
                        
                        MapMarker(number: 1, isInteractive: false)
                            .position(x: geometry.size.width * 0.7, y: geometry.size.height * 0.5)
                        
                        // 실제 작동하는 마커 (제일 밑)
                        Button(action: {
                            selectedMarker = 1
                        }) {
                            MapMarker(number: 1, isInteractive: true)
                        }
                        .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.8)
                    }
                }
                .padding()
            }
        }
        .alert("수거 지점 정보", isPresented: Binding(
            get: { selectedMarker != nil },
            set: { if !$0 { selectedMarker = nil } }
        )) {
            Button("확인", role: .cancel) {
                selectedMarker = nil
            }
        } message: {
            Text("서울특별시 강남구 테헤란로 427\nA동 101호 분자생물학 연구실")
        }
    }
}

struct MapMarker: View {
    let number: Int
    let isInteractive: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isInteractive ? Color.blue : Color.black)
                .frame(width: 44, height: 44)
            
            Text("\(number)")
                .foregroundColor(.white)
                .font(.system(size: 20, weight: .bold))
        }
        .opacity(isInteractive ? 1.0 : 0.6)
    }
}

#Preview {
    MapTabView()
}
