//
//  FacilityRegisterView.swift
//  Labify
//
//  Created by F_S on 10/29/25.
//

import SwiftUI

struct FacilityRegisterView: View {
    let userInfo: UserInfo
    @ObservedObject var authVM: AuthViewModel
    
    @StateObject private var facViewModel = FacViewModel()
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var type = ""
    @State private var address = ""
    @State private var confirmAccuracy = false
    @State private var showFinalConfirm = false
    @State private var navigateToMain = false
    
    private let facilityTypes = ["LAB", "PICKUP", "ETC"]
    
    private let typeDescriptions: [String: String] = [
        "LAB": "연구 실험실",
        "PICKUP": "수거 전용 시설",
        "ETC": "기타 시설"
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // 커스텀 네비게이션 바
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text("시설 등록")
                    .font(.system(size: 17, weight: .semibold))
                
                Spacer()
                
                // 균형을 위한 투명 버튼
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.clear)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.white)
            
            ScrollView {
                VStack(spacing: 32) {
                        
                        // 헤더 아이콘 및 타이틀
                        VStack(spacing: 24) {
//                            Image("Labify_logo")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 90, height: 90)
//                                .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 8)
                            
                            VStack(spacing: 8) {
                                Text("새 시설을 등록합니다")
                                    .font(.system(size: 24, weight: .bold))
                                
                                Text("시설 정보를 정확히 입력해주세요")
                                    .font(.system(size: 15))
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(4)
                            }
                        }
                        .padding(.top, 40)

                    
                    VStack(alignment: .leading, spacing: 24) {
                        // 시설명
                        VStack(alignment: .leading, spacing: 12) {
                            Text("시설명")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            TextField("예) 서울 바이오센터", text: $name)
                                .textInputAutocapitalization(.none)
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                        }
                        
                        // 시설 유형
                        VStack(alignment: .leading, spacing: 12) {
                            Text("시설 유형")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            VStack(spacing: 12) {
                                ForEach(facilityTypes, id: \.self) { facilityType in
                                    Button(action: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            type = facilityType
                                        }
                                    }) {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(facilityType)
                                                .font(.system(size: 18, weight: .semibold))
                                                .foregroundColor(.primary)
                                            
                                            Text(typeDescriptions[facilityType] ?? "")
                                                .font(.system(size: 14))
                                                .foregroundColor(.gray)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(20)
                                        .background(type == facilityType ? Color(red: 177/255, green: 189/255, blue: 255/255) : Color(white: 0.96))
                                        .cornerRadius(12)
                                        .shadow(
                                            color: type == facilityType ? Color(red: 177/255, green: 189/255, blue: 255/255).opacity(0.4) : Color.clear,
                                            radius: type == facilityType ? 8 : 0,
                                            x: 0,
                                            y: type == facilityType ? 4 : 0
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        
                        // 주소
                        VStack(alignment: .leading, spacing: 12) {
                            Text("주소")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            TextField("예) Seoul, Korea", text: $address)
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                        }
                        
                        // 확인 체크박스
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                confirmAccuracy.toggle()
                            }
                        }) {
                            HStack(alignment: .top, spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(confirmAccuracy ? Color(red: 30/255, green: 59/255, blue: 207/255) : Color.gray.opacity(0.3), lineWidth: 2)
                                        .frame(width: 24, height: 24)
                                    
                                    if confirmAccuracy {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
                                    }
                                }
                                
                                Text("입력한 정보가 정확하며, 등록 후 수정/삭제가 불가함을 이해했습니다.")
                                    .font(.system(size: 14))
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding(16)
                            .background(
                                confirmAccuracy ?
                                Color(red: 244/255, green: 247/255, blue: 255/255) :
                                Color(white: 0.98)
                            )
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        confirmAccuracy ?
                                        Color(red: 30/255, green: 59/255, blue: 207/255).opacity(0.3) :
                                        Color.gray.opacity(0.2),
                                        lineWidth: 1
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(20)
                .padding(.bottom, 100)
            }
            .background(Color.white)
            
            // 하단 버튼
            VStack(spacing: 0) {
                Button {
                    showFinalConfirm = true
                } label: {
                    Text("시설 등록하기")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            confirmAccuracy && formValid ?
                            LinearGradient(
                                colors: [Color(red: 30/255, green: 59/255, blue: 207/255),
                                         Color(red: 113/255, green: 100/255, blue: 230/255)],
                                startPoint: .top,
                                endPoint: .bottom
                            ) :
                            LinearGradient(
                                colors: [Color.gray.opacity(0.5), Color.gray.opacity(0.5)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(16)
                }
                .disabled(!confirmAccuracy || !formValid || facViewModel.isLoading)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: -5)
            }
        }
        .background(Color.white)
        .navigationBarBackButtonHidden(true)
        .alert("등록 최종 확인", isPresented: $showFinalConfirm) {
            Button("취소", role: .cancel) { }
            Button("등록", role: .destructive) {
                Task {
                    let success = await facViewModel.registerFacility(
                        name: name,
                        type: type,
                        address: address
                    )
                    if success {
                        navigateToMain = true
                    }
                }
            }
        } message: {
            Text("""
            아래 정보로 시설을 등록합니다. 등록 후 수정/삭제는 현재 불가합니다.
            
            • 시설명: \(name)
            • 유형: \(type)
            • 주소: \(address)
            """)
        }
        .alert("등록 오류", isPresented: $facViewModel.showError) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(facViewModel.errorMessage)
        }
        .navigationDestination(isPresented: $navigateToMain) {
            destinationViewForRole
        }
    }
    
    private var formValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !address.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    @ViewBuilder
    private var destinationViewForRole: some View {
        switch userInfo.role {
        case "FACILITY_MANAGER":
            FacTabView(userInfo: userInfo, authVM: authVM)
        case "LAB_MANAGER":
            LabTabView(userInfo: userInfo, authVM: authVM)
        case "PICKUP_MANAGER":
            PickTabView(userInfo: userInfo, authVM: authVM)
        default:
            Text("알 수 없는 역할입니다")
        }
    }
}

#Preview {
    NavigationStack {
        FacilityRegisterView(
            userInfo: UserInfo(
                userId: 1,
                name: "테스트",
                email: "test@test.com",
                role: "FACILITY_MANAGER"
            ),
            authVM: AuthViewModel()
        )
    }
}
