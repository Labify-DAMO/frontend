//
//  InitialFacilityRegisterView.swift
//  Labify
//
//  Created by F_S on 10/24/25.
//

import SwiftUI

struct InitialFacilityRegisterView: View {
    let userInfo: UserInfo
    @StateObject private var viewModel = FacViewModel()
    @Binding var isCompleted: Bool
    
    @State private var name = ""
    @State private var type = "LAB"
    @State private var address = ""
    @State private var confirmAccuracy = false
    @State private var showFinalConfirm = false
    @State private var isSubmitting = false
    
    private let facilityTypes = ["LAB", "HOSPITAL", "CLINIC", "UNIVERSITY", "PICKUP"]
    
    var body: some View {
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
                    Text("시설 등록")
                        .font(.system(size: 28, weight: .bold))
                    Text("관리할 시설 정보를 입력해주세요")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
            }
            .padding(.bottom, 40)
            
            // 입력 영역
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("시설명")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.gray)
                        
                        TextField("예) 서울 바이오센터", text: $name)
                            .font(.system(size: 17))
                            .padding(16)
                            .background(Color(red: 247/255, green: 248/255, blue: 250/255))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(name.isEmpty ? Color.clear : Color(red: 30/255, green: 59/255, blue: 207/255).opacity(0.3), lineWidth: 1.5)
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("시설 유형")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.gray)
                        
                        Picker("시설 유형", selection: $type) {
                            ForEach(facilityTypes, id: \.self) { facilityType in
                                Text(facilityType).tag(facilityType)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("주소")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.gray)
                        
                        TextField("예) Seoul, Korea", text: $address)
                            .font(.system(size: 17))
                            .padding(16)
                            .background(Color(red: 247/255, green: 248/255, blue: 250/255))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(address.isEmpty ? Color.clear : Color(red: 30/255, green: 59/255, blue: 207/255).opacity(0.3), lineWidth: 1.5)
                            )
                    }
                    
                    // 정확성 확인
                    Toggle(isOn: $confirmAccuracy) {
                        Text("입력한 정보가 정확하며, 등록 후 수정/삭제가 불가함을 이해했습니다.")
                            .font(.system(size: 14))
                            .foregroundColor(.primary)
                    }
                    .tint(Color(red: 30/255, green: 59/255, blue: 207/255))
                    .padding(.top, 8)
                    
                    // 안내 메시지
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
                        Text("시설 등록 후 고유 코드가 발급됩니다")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding(.horizontal, 4)
                }
                .padding(.horizontal, 28)
            }
            
            Spacer()
            
            // 하단 버튼
            VStack(spacing: 16) {
                Button(action: {
                    showFinalConfirm = true
                }) {
                    HStack {
                        if isSubmitting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("시설 등록하기")
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
                .disabled(!formValid || !confirmAccuracy || isSubmitting)
                .opacity(!formValid || !confirmAccuracy || isSubmitting ? 0.5 : 1)
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 40)
        }
        .background(Color.white)
        .alert("등록 최종 확인", isPresented: $showFinalConfirm) {
            Button("취소", role: .cancel) { }
            Button("등록", role: .destructive) {
                Task {
                    await submitRegistration()
                }
            }
        } message: {
            Text("""
                아래 정보로 시설을 등록합니다. 등록 후 수정/삭제는 현재 불가합니다.
                
                • 시설명: \(name)
                • 유형: \(type)
                • 주소: \(address)
                • 관리자 ID: \(userInfo.userId)
                """)
        }
        .alert("오류", isPresented: $viewModel.showError) {
            Button("확인", role: .cancel) {}
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    private var formValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !address.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private func submitRegistration() async {
        isSubmitting = true
        
        let success = await viewModel.registerFacility(
            name: name,
            type: type,
            address: address,
            managerId: userInfo.userId
        )
        
        isSubmitting = false
        
        if success {
            // 시설 정보 다시 로드
            await viewModel.fetchFacilityInfo()
            // 완료 플래그 설정
            isCompleted = true
        }
    }
}

#Preview {
    InitialFacilityRegisterView(
        userInfo: UserInfo(
            userId: 3,
            name: "이시설",
            email: "facility@test.com",
            role: "FACILITY_MANAGER"
            //affiliation: "종합관리센터"
        ),
        isCompleted: .constant(false)
    )
}
