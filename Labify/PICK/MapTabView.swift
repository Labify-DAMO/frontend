//
//  MapTabView.swift
//  Labify
//
//  Created by F_s on 9/29/25.
//




// =========================================
// MapTabView.swift
// 지도 탭

import SwiftUI

struct MapTabView: View {
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
						
						// 마커들
						MapMarker(number: 2)
							.position(x: geometry.size.width * 0.3, y: geometry.size.height * 0.2)
						
						MapMarker(number: 1)
							.position(x: geometry.size.width * 0.7, y: geometry.size.height * 0.5)
						
						MapMarker(number: 1)
							.position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.8)
					}
				}
				.padding()
			}
		}
	}
}

struct MapMarker: View {
	let number: Int
	
	var body: some View {
		ZStack {
			Circle()
				.fill(Color.black)
				.frame(width: 44, height: 44)
			
			Text("\(number)")
				.foregroundColor(.white)
				.font(.system(size: 20, weight: .bold))
		}
	}
}
