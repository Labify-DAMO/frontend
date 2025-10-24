//
//  InitialFacilityRequestView.swift
//  Labify
//
//  Created by F_S on 10/21/25.
//

import SwiftUI

struct InitialFacilityRequestView: View {
    let userInfo: UserInfo
    @StateObject private var viewModel = FacViewModel()
    @State private var facilityCode = ""
    @State private var isSubmitting = false
    @State private var showSuccessAlert = false
    @State private var requestSubmitted = false
    
    var body: some View {
        VStack(spacing: 0) {
            if requestSubmitted {
                // ✅ 요청 제출 후 대기 화면
                waitingView
            } else {
                // 요청 입력 화면
                requestInputView
            }
        }
        .background(Color.white)
        .alert("요청 완료", isPresented: $showSuccessAlert) {
            Button("확인", role: .cancel) {
                requestSubmitted = true
            }
        } message: {
            Text("시설 관리자의 승인을 기다려주세요.\n승인 후 서비스를 이용하실 수 있습니다.")
        }
        .alert("오류", isPresented: $viewModel.showError) {
            Button("확인", role: .cancel) {}
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - 요청 입력 화면
    private var requestInputView: some View {
        VStack(spacing: 0) {
            // 헤더 영역
            VStack(spacing: 16) {
                Image(systemName: "building.2.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(red: 30/255, green: 59/255, blue: 207/255),
                                     Color(red: 113/255, green: 100/255, blue: 230/255)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .padding(.top, 60)
                
                VStack(spacing: 8) {
                    Text("시설 소속 요청")
                        .font(.system(size: 28, weight: .bold))
                    Text("소속 시설 코드를 입력해주세요")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
            }
            .padding(.bottom, 60)
            
            // 입력 영역
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("시설 코드")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.gray)
                    
                    TextField("PANGYO", text: $facilityCode)
                        .font(.system(size: 17))
                        .textInputAutocapitalization(.characters)
                        .padding(16)
                        .background(Color(red: 247/255, green: 248/255, blue: 250/255))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(facilityCode.isEmpty ? Color.clear : Color(red: 30/255, green: 59/255, blue: 207/255).opacity(0.3), lineWidth: 1.5)
                        )
                }
                
                // 안내 메시지
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
                    Text("시설 관리자에게 승인 요청이 전송됩니다")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding(.horizontal, 4)
            }
            .padding(.horizontal, 28)
            
            Spacer()
            
            // 하단 버튼
            VStack(spacing: 16) {
                Button(action: {
                    Task {
                        await submitRequest()
                    }
                }) {
                    HStack {
                        if isSubmitting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("요청 보내기")
                                .font(.system(size: 17, weight: .semibold))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 30/255, green: 59/255, blue: 207/255),
                                     Color(red: 113/255, green: 100/255, blue: 230/255)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: Color(red: 30/255, green: 59/255, blue: 207/255).opacity(0.3), radius: 12, x: 0, y: 6)
                }
                .disabled(facilityCode.isEmpty || isSubmitting)
                .opacity(facilityCode.isEmpty || isSubmitting ? 0.5 : 1)
                
                Text("시설 코드는 시설 관리자에게 문의하세요")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - 승인 대기 화면
    private var waitingView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "clock.fill")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(red: 30/255, green: 59/255, blue: 207/255),
                                 Color(red: 113/255, green: 100/255, blue: 230/255)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            VStack(spacing: 12) {
                Text("승인 대기 중")
                    .font(.system(size: 24, weight: .bold))
                
                Text("시설 관리자의 승인을 기다리고 있습니다.\n승인되면 알림으로 안내해드립니다.")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            
            Spacer()
            
            // 상태 확인 버튼
            VStack(spacing: 16) {
                Button(action: {
                    Task {
                        await checkApprovalStatus()
                    }
                }) {
                    HStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "arrow.clockwise")
                            Text("승인 상태 확인")
                                .font(.system(size: 17, weight: .semibold))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 30/255, green: 59/255, blue: 207/255),
                                     Color(red: 113/255, green: 100/255, blue: 230/255)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(16)
                }
                .disabled(viewModel.isLoading)
                
                Text("앱을 종료하셔도 승인 시 알림이 전송됩니다")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 28)
    }
    
    private func submitRequest() async {
        guard let userId = UserDefaults.standard.object(forKey: "userId") as? Int else {
            viewModel.errorMessage = "사용자 정보를 찾을 수 없습니다."
            viewModel.showError = true
            return
        }
        
        // ✅ 이미 시설이 있으면 요청 불가
        if viewModel.hasFacility {
            viewModel.errorMessage = "이미 소속된 시설이 있습니다."
            viewModel.showError = true
            return
        }
        
        isSubmitting = true
        
        let success = await viewModel.requestFacilityJoin(
            userId: userInfo.userId,
            facilityCode: facilityCode
        )
        
        isSubmitting = false
        
        if success {
            showSuccessAlert = true
        }
    }
    
    // ✅ 승인 상태 확인
    private func checkApprovalStatus() async {
        await viewModel.fetchFacilityInfo()
        
        // 시설이 생겼으면 자동으로 메인 화면으로 이동
        // RoleBasedInitialView가 자동으로 처리함
    }
}

#Preview {
    InitialFacilityRequestView(
        userInfo: UserInfo(
            userId: 2,
            name: "김실험",
            email: "lab@test.com",
            role: "LAB_MANAGER",
            affiliation: "테스트 연구소"
        )
    )
}
