//
//  PickupScannerView.swift
//  Labify
//
//  Created by F_s on 10/29/25.
//

import SwiftUI

struct PickupScannerView: View {
    @StateObject private var viewModel = PickupViewModel()
    @State private var scannedCode: String = ""
    @State private var showSuccessAlert = false
    @State private var showManualInput = false
    @State private var manualCode = ""
    
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
                        
                        Text("QR코드를\n스캔해주세요.")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.top, 8)
                    }
                }
                .padding(.bottom, 30)
                
                // 정보 영역
                if !scannedCode.isEmpty {
                    VStack(spacing: 20) {
                        HStack {
                            Text("스캔된 코드")
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        
                        HStack {
                            Text(scannedCode)
                                .font(.system(size: 16, weight: .medium))
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 40)
                }
                
                // 완료 버튼
                Button(action: {
                    Task {
                        let success = await viewModel.scanQRCode(code: scannedCode.isEmpty ? "QRCODE_SCAN_TEST" : scannedCode)
                        if success {
                            showSuccessAlert = true
                            scannedCode = ""
                        }
                    }
                }) {
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
                .disabled(viewModel.isLoading)
                
                // 하단 버튼
                HStack(spacing: 30) {
                    Button(action: {
                        showManualInput = true
                    }) {
                        Text("수동 입력")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    
                    Button(action: {
                        // TODO: 문제 신고 기능
                    }) {
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
            .alert("수거 완료", isPresented: $showSuccessAlert) {
                Button("확인", role: .cancel) {}
            } message: {
                Text("수거가 성공적으로 완료되었습니다.")
            }
            .alert("수동 입력", isPresented: $showManualInput) {
                TextField("코드 입력", text: $manualCode)
                Button("취소", role: .cancel) {
                    manualCode = ""
                }
                Button("확인") {
                    scannedCode = manualCode
                    manualCode = ""
                }
            } message: {
                Text("QR 코드를 수동으로 입력하세요")
            }
            .alert("오류", isPresented: $viewModel.showError) {
                Button("확인", role: .cancel) {}
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
        }
    }
}

#Preview {
    PickupScannerView()
}
