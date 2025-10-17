//
//  QRCodeView.swift
//  Labify
//
//  Created by KITS on 10/14/25.
//

import SwiftUI

struct QRCodeView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // 요약 정보
                VStack(alignment: .leading, spacing: 8) {
                    Text("요약")
                        .font(.system(size: 16, weight: .semibold))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("유형: 감염성 / 보관: 냉장 / 중량: 12kg")
                            .font(.system(size: 14))
                        Text("위치: 냉장고 A-2 / 실험ID: CELL-0427")
                            .font(.system(size: 14))
                        Text("만료일: D-7")
                            .font(.system(size: 14))
                    }
                    .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(12)
                
                // QR 코드
                Image(systemName: "qrcode")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 280, height: 280)
                    .padding()
                
                Spacer()
                
                // 완료 버튼
                Button(action: {
                    dismiss()
                }) {
                    Text("완료")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .padding()
            .navigationTitle("확인 및 QR 발행")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.primary)
            })
        }
    }
}

#Preview {
    QRCodeView()
}
