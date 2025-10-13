//
//  PickupScannerView.swift
//  Labify
//
//  Created by F_s on 9/22/25.
//


// =========================================
// QRScanView.swift
// QR 스캔 화면

import SwiftUI

struct PickupScannerView: View {
	var body: some View {
		NavigationView {
			VStack(spacing: 20) {
				Spacer()
				
				// QR 스캔 영역
				ZStack {
					RoundedRectangle(cornerRadius: 12)
						.stroke(style: StrokeStyle(lineWidth: 2, dash: [10]))
						.foregroundColor(.gray.opacity(0.5))
						.frame(width: 250, height: 250)
					
					VStack {
						Image(systemName: "camera.fill")
							.font(.system(size: 60))
							.foregroundColor(.blue)
						
						Text(" QR코드를\n스캔해주세요.")
							.font(.system(size: 14))
							.foregroundColor(.gray)
							.multilineTextAlignment(.center)
							.padding(.top, 8)
					}
				}
				.padding(.bottom, 30)
				
				// 정보 영역
				VStack(spacing: 20) {
					HStack {
						Text("물량")
							.foregroundColor(.gray)
						Spacer()
						Text("무게")
							.foregroundColor(.gray)
					}
					
					HStack {
						Text("갑영성 배기물")
							.font(.system(size: 16))
						Spacer()
						Text("1.2 kg")
							.font(.system(size: 16, weight: .semibold))
					}
					
					Divider()
					
					HStack {
						Text("등록자")
							.foregroundColor(.gray)
						Spacer()
						Text("등록 시간")
							.foregroundColor(.gray)
					}
					
					HStack {
						Text("김00")
							.font(.system(size: 16))
						Spacer()
						Text("10:42")
							.font(.system(size: 16))
					}
				}
				.padding(.horizontal, 40)
				
				// 완료 버튼
				Button(action: {}) {
					Text("완료 및 등록")
						.font(.system(size: 17, weight: .semibold))
						.foregroundColor(.white)
						.frame(maxWidth: .infinity)
						.padding()
						.background(Color.blue)
						.cornerRadius(12)
				}
				.padding(.horizontal, 40)
				.padding(.top, 20)
				
				// 하단 버튼
				HStack(spacing: 30) {
					Button(action: {}) {
						Text("수동 입력")
							.font(.system(size: 14))
							.foregroundColor(.gray)
					}
					
					Button(action: {}) {
						Text("문제 신고")
							.font(.system(size: 14))
							.foregroundColor(.gray)
					}
				}
				.padding(.top, 10)
				
				Spacer()
			}
			.navigationTitle("QR 스캔")
			.navigationBarTitleDisplayMode(.inline)
		}
	}
}
