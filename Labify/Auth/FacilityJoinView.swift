//
//  FacilityJoinView.swift
//  Labify
//
//  Created by F_S on 10/29/25.
//

import SwiftUI

struct FacilityJoinView: View {
    let userInfo: UserInfo
    @ObservedObject var authVM: AuthViewModel
    
    @StateObject private var facViewModel = FacViewModel()
    @Environment(\.dismiss) private var dismiss
    
    @State private var facilityCode = ""
    @State private var showSuccessAlert = false
    @State private var requestId: Int?
    
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
                
                Text("시설 가입")
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
//                        Image("Labify_logo2")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 90, height: 90)
//                            .shadow(color: Color(red: 30/255, green: 59/255, blue: 207/255).opacity(0.3), radius: 15, x: 0, y: 8)
//                            .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 8)
                        
                        VStack(spacing: 8) {
                            Text("시설 코드를 입력하세요")
                                .font(.system(size: 24, weight: .bold))
                            
                            Text("시설 관리자에게 받은 코드를 입력하면\n가입 요청이 전송됩니다.")
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                        }
                    }
                    .padding(.top, 40)
                    
                    // 입력 필드
                    VStack(alignment: .leading, spacing: 12) {
                        Text("시설 코드")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        TextField("예) BI4C5T", text: $facilityCode)
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled(true)
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(12)
                            .font(.system(size: 18, weight: .medium, design: .monospaced))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                    
                    // 안내 박스
                    HStack(spacing: 12) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("가입 요청 후")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.primary)
                            Text("시설 관리자가 승인하면 시설을 이용할 수 있습니다.")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        Spacer()
                    }
                    .padding(16)
                    .background(Color(red: 244/255, green: 247/255, blue: 255/255))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(red: 30/255, green: 59/255, blue: 207/255).opacity(0.2), lineWidth: 1)
                    )
                }
                .padding(20)
                .padding(.bottom, 100)
            }
            .background(Color.white)
            
            // 하단 버튼
            VStack(spacing: 0) {
                Button {
                    Task {
                        await submitJoinRequest()
                    }
                } label: {
                    if facViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                    } else {
                        Text("가입 요청하기")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                    }
                }
                .background(
                    formValid && !facViewModel.isLoading ?
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
                .disabled(!formValid || facViewModel.isLoading)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: -5)
            }
        }
        .background(Color.white)
        .navigationBarBackButtonHidden(true)
        .alert("가입 요청 완료", isPresented: $showSuccessAlert) {
            Button("확인") {
                dismiss()
            }
        } message: {
            Text("시설 관리자에게 가입 요청이 전송되었습니다.\n승인을 기다려주세요.\n\n요청 ID: \(requestId ?? 0)")
        }
        .alert("요청 오류", isPresented: $facViewModel.showError) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(facViewModel.errorMessage)
        }
    }
    
    private var formValid: Bool {
        !facilityCode.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private func submitJoinRequest() async {
        let success = await facViewModel.requestFacilityJoin(
            userId: userInfo.userId,
            facilityCode: facilityCode.trimmingCharacters(in: .whitespaces)
        )
        
        if success {
            requestId = facViewModel.joinRequestId
            showSuccessAlert = true
        }
    }
}

#Preview {
    NavigationStack {
        FacilityJoinView(
            userInfo: UserInfo(
                userId: 1,
                name: "테스트",
                email: "test@test.com",
                role: "LAB_MANAGER"
            ),
            authVM: AuthViewModel()
        )
    }
}
