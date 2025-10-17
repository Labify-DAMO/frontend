//
//  SignUpAuthSteps.swift
//  Labify
//
//  Created by F_s on 9/22/25.
//

import SwiftUI

// MARK: - Step 1: 이메일 입력
struct Step1EmailInput: View {
    @ObservedObject var vm: AuthViewModel
    let canProceed: Bool
    let onNext: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("이메일을 입력하세요")
                .font(.system(size: 24, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 8)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("이메일")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                TextField("이메일을 입력해주세요.", text: $vm.email)
                    .padding()
                    .background(Color(white: 0.96))
                    .cornerRadius(10)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
            }
            
            if let error = vm.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.footnote)
            }
            
            TermsCheckbox(isChecked: $vm.agreeTerms)
            
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
            .padding(.top, 24)
        }
    }
}

// MARK: - Step 2: 비밀번호 입력
struct Step2PasswordInput: View {
    @ObservedObject var vm: AuthViewModel
    @Binding var showPassword: Bool
    let canProceed: Bool
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Text("비밀번호를 입력하세요")
                .font(.system(size: 24, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 8)
            
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("비밀번호")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    HStack {
                        if showPassword {
                            TextField("비밀번호를 입력해주세요.", text: $vm.password)
                        } else {
                            SecureField("비밀번호를 입력해주세요.", text: $vm.password)
                        }
                        
                        Button(action: {
                            showPassword.toggle()
                        }) {
                            Image(systemName: showPassword ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color(white: 0.96))
                    .cornerRadius(10)
                }
                
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

// MARK: - Step 3: 비밀번호 확인
struct Step3PasswordConfirm: View {
    @ObservedObject var vm: AuthViewModel
    @Binding var confirmPassword: String
    @Binding var showPassword: Bool
    let canProceed: Bool
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Text("비밀번호를 확인하세요")
                .font(.system(size: 24, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 8)
            
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("비밀번호 확인")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    HStack {
                        if showPassword {
                            TextField("비밀번호를 다시 입력해주세요.", text: $confirmPassword)
                        } else {
                            SecureField("비밀번호를 다시 입력해주세요.", text: $confirmPassword)
                        }
                        
                        Button(action: {
                            showPassword.toggle()
                        }) {
                            Image(systemName: showPassword ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color(white: 0.96))
                    .cornerRadius(10)
                }
                
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

// MARK: - Step 7: 인증 코드 입력 (회원가입 후)
struct Step7VerificationCode: View {
    @ObservedObject var vm: AuthViewModel
    @Binding var verificationCode: String
    @FocusState.Binding var isCodeFieldFocused: Bool
    @Binding var remainingTime: Int
    let canProceed: Bool
    let onResend: () -> Void
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Text("인증 코드를 전송했어요")
                .font(.system(size: 24, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 8)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("받은 6자리 코드를 입력하세요")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // 숨겨진 텍스트 필드
                TextField("", text: $verificationCode)
                    .keyboardType(.numberPad)
                    .focused($isCodeFieldFocused)
                    .opacity(0)
                    .frame(height: 1)
                    .onChange(of: verificationCode) { oldValue, newValue in
                        if newValue.count > 6 {
                            verificationCode = String(newValue.prefix(6))
                        }
                    }
                
                HStack(spacing: 12) {
                    ForEach(0..<6, id: \.self) { index in
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(white: 0.96))
                                .frame(width: 45, height: 56)
                            
                            if index < verificationCode.count {
                                Text(String(verificationCode[verificationCode.index(verificationCode.startIndex, offsetBy: index)]))
                                    .font(.system(size: 24, weight: .semibold))
                            }
                        }
                        .onTapGesture {
                            isCodeFieldFocused = true
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .onAppear {
                    isCodeFieldFocused = true
                }
                .padding(.vertical, 8)
                
                HStack {
                    Text("남은 시간 \(formatTime(remainingTime))")
                        .font(.system(size: 13))
                        .foregroundColor(remainingTime <= 60 ? .red : .gray)
                    
                    Spacer()
                    
                    Button(action: onResend) {
                        Text(vm.isLoading ? "전송 중..." : "코드 재전송")
                            .font(.system(size: 13))
                            .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
                    }
                    .disabled(vm.isLoading)
                }
                .padding(.horizontal, 4)
                
                if let error = vm.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.footnote)
                }
            }
            
            Spacer()
                .frame(height: 100)
            
            Button(action: onNext) {
                Text(vm.isLoading ? "확인 중..." : "다음")
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
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
