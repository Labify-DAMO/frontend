//
//  SignUpModels.swift
//  Labify
//
//  Created by F_s on 9/22/25.
//

import SwiftUI

// MARK: - UserRole Enum
enum UserRole: String, CaseIterable {
    case labManager = "실험실 관리자"
    case pickupManager = "수거 업체"
    case facilityManager = "시설 관리자"
    
    var description: String {
        switch self {
        case .labManager:
            return "폐기물 등록·수거 요청"
        case .pickupManager:
            return "수거 계획·QR 스캔"
        case .facilityManager:
            return "시설 관리 및 모니터링"
        }
    }
    
    var apiValue: String {
        switch self {
        case .labManager:
            return "LAB_MANAGER"
        case .pickupManager:
            return "PICKUP_MANAGER"
        case .facilityManager:
            return "FACILITY_MANAGER"
        }
    }
}

// MARK: - Reusable Components

// 약관 동의 체크박스
struct TermsCheckbox: View {
    @Binding var isChecked: Bool
    
    var body: some View {
        Button(action: {
            isChecked.toggle()
        }) {
            HStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1.5)
                        .frame(width: 20, height: 20)
                    
                    if isChecked {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.blue)
                    }
                }
                
                Text("(필수) 이용약관 및 개인정보 처리방침 동의")
                    .font(.system(size: 14))
                    .foregroundColor(.primary)
                
                Spacer()
            }
        }
        .padding(.horizontal, 4)
    }
}

// 비활성화된 텍스트 필드
struct DisabledTextField: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.gray)
            
            TextField("", text: .constant(value))
                .disabled(true)
                .padding()
                .background(Color(white: 0.96))
                .cornerRadius(10)
        }
    }
}

// 비활성화된 보안 필드
struct DisabledSecureField: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.gray)
            
            HStack {
                SecureField("", text: .constant(value))
                    .disabled(true)
                
                Image(systemName: "eye.slash")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(white: 0.96))
            .cornerRadius(10)
        }
    }
}
