//
//  SignUpInfoSteps.swift
//  Labify
//
//  Created by F_s on 9/22/25.
//

import SwiftUI

// MARK: - Step 4: 이름 입력
struct Step4NameInput: View {
    @ObservedObject var vm: AuthViewModel
    let canProceed: Bool
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Text("이름을 입력하세요")
                .font(.system(size: 24, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 8)
            
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("이름")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    TextField("이름을 입력해주세요.", text: $vm.name)
                        .padding()
                        .background(Color(white: 0.96))
                        .cornerRadius(10)
                        .autocapitalization(.words)
                }
                
                DisabledSecureField(label: "비밀번호 확인", value: vm.password)
                DisabledSecureField(label: "비밀번호", value: vm.password)
                DisabledTextField(label: "이메일", value: vm.email)
                
                TermsCheckbox(isChecked: $vm.agreeTerms)
            }
            
            Spacer()
                .frame(height: 50)
            
            Button(action: onNext) {
                Text("다음")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(canProceed ? Color.black : Color(white: 0.85))
                    .cornerRadius(10)
            }
            .disabled(!canProceed)
            .animation(.easeInOut(duration: 0.2), value: canProceed)
        }
    }
}

// MARK: - Step 5: 역할 선택
struct Step5RoleSelection: View {
    @Binding var selectedRole: UserRole?
    let canProceed: Bool
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Text("역할을 선택하세요")
                .font(.system(size: 24, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 32)
            
            VStack(spacing: 16) {
                ForEach(UserRole.allCases, id: \.self) { role in
                    Button(action: {
                        selectedRole = role
                    }) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(role.rawValue)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text(role.description)
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(selectedRole == role ? Color(red: 177/255, green: 189/255, blue: 255/255) : Color(white: 0.96))
                        .cornerRadius(12)
                        .shadow(
                            color: selectedRole == role ? Color(red: 177/255, green: 189/255, blue: 255/255).opacity(0.4) : Color.clear,
                            radius: selectedRole == role ? 8 : 0,
                            x: 0,
                            y: selectedRole == role ? 4 : 0
                        )
                    }
                    .animation(.easeInOut(duration: 0.2), value: selectedRole)
                }
            }
            
            Spacer()
                .frame(height: 100)
            
            Button(action: onNext) {
                Text("다음")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(canProceed ? Color.black : Color(white: 0.85))
                    .cornerRadius(10)
            }
            .disabled(!canProceed)
            .animation(.easeInOut(duration: 0.2), value: canProceed)
        }
    }
}

// MARK: - Step 6: 소속 입력 + 회원가입
struct Step6AffiliationInput: View {
    @ObservedObject var vm: AuthViewModel
    let selectedRole: UserRole?
    let canProceed: Bool
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Text("소속을 입력하세요")
                .font(.system(size: 24, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 8)
            
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("소속")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    TextField("소속을 입력해주세요 (예: 00실험실, 00업체)", text: $vm.affiliation)
                        .padding()
                        .background(Color(white: 0.96))
                        .cornerRadius(10)
                }
                
                DisabledTextField(label: "역할", value: selectedRole?.rawValue ?? "")
                DisabledTextField(label: "이름", value: vm.name)
                DisabledTextField(label: "이메일", value: vm.email)
            }
            
            if let error = vm.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.footnote)
            }
            
            Spacer()
                .frame(height: 50)
            
            Button(action: onNext) {
                Text(vm.isLoading ? "가입 중..." : "회원가입")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(canProceed ? Color.black : Color(white: 0.85))
                    .cornerRadius(10)
            }
            .disabled(!canProceed || vm.isLoading)
            .animation(.easeInOut(duration: 0.2), value: canProceed)
        }
    }
}

// MARK: - Step 8: 회원가입 완료
struct Step8SignupComplete: View {
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
                .frame(height: 100)
            
            // 체크 아이콘
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Circle()
                    .stroke(Color.green, lineWidth: 2)
                    .frame(width: 120, height: 120)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 50, weight: .semibold))
                    .foregroundColor(.green)
            }
            
            VStack(spacing: 12) {
                Text("회원가입이 완료되었습니다")
                    .font(.system(size: 24, weight: .bold))
                
                Text("역할을 선택해 시작해보세요")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: onNext) {
                Text("시작하기")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(red: 30/255, green: 59/255, blue: 207/255),
                                Color(red: 113/255, green: 100/255, blue: 230/255)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(10)
            }
            .padding(.bottom, 32)
        }
    }
}

// MARK: - Step 9: 앱 접근 권한 안내
struct Step9PermissionRequest: View {
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 100)
            
            Text("앱 접근 권한 안내")
                .font(.system(size: 24, weight: .bold))
                .padding(.bottom, 48)
            
            VStack(alignment: .leading, spacing: 32) {
                HStack(alignment: .top, spacing: 16) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.primary)
                        .frame(width: 40)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("카메라 촬영")
                            .font(.system(size: 18, weight: .semibold))
                        
                        Text("카메라 촬영을 통한 성분 분석 및 QR코드 인식")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 32)
            
            Spacer()
            
            Button(action: onDismiss) {
                Text("확인")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.black)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
    }
}
