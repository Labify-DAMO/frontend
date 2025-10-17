//
//  SignUpView.swift
//  Labify
//
//  Created by F_s on 9/22/25.
//

import SwiftUI

struct SignUpView: View {
    @StateObject private var vm = AuthViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var currentStep = 1
    @State private var verificationCode = ""
    @State private var confirmPassword = ""
    @State private var selectedRole: UserRole? = nil
    @State private var showPassword1 = false
    @State private var showPassword2 = false
    @FocusState private var isCodeFieldFocused: Bool
    @State private var remainingTime = 300
    @State private var timer: Timer?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // 상단 네비게이션 + 로고
                ZStack {
                    // 뒤로가기 버튼 (왼쪽)
                    HStack {
                        Button(action: {
                            if currentStep > 1 {
                                currentStep -= 1
                            } else {
                                dismiss()
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20))
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                    }
                    
                    // 로고 (센터) - Step 5 이후에는 숨김
                    if currentStep < 5 {
                        Text("Labify")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(red: 30/255, green: 59/255, blue: 207/255),
                                        Color(red: 113/255, green: 100/255, blue: 230/255)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                }
                .padding(.horizontal, 32)
                .padding(.top, 16)
                .padding(.bottom, 40)
                
                // 단계별 컨텐츠
                VStack(spacing: 0) {
                    if currentStep == 1 {
                        Step1EmailInput(
                            vm: vm,
                            canProceed: canProceedStep1,
                            onNext: { currentStep = 2 }
                        )
                    } else if currentStep == 2 {
                        Step2PasswordInput(
                            vm: vm,
                            showPassword: $showPassword1,
                            canProceed: canProceedStep2,
                            onNext: { currentStep = 3 }
                        )
                    } else if currentStep == 3 {
                        Step3PasswordConfirm(
                            vm: vm,
                            confirmPassword: $confirmPassword,
                            showPassword: $showPassword2,
                            canProceed: canProceedStep3,
                            onNext: { currentStep = 4 }
                        )
                    } else if currentStep == 4 {
                        Step4NameInput(
                            vm: vm,
                            canProceed: canProceedStep4,
                            onNext: { currentStep = 5 }
                        )
                    } else if currentStep == 5 {
                        Step5RoleSelection(
                            selectedRole: $selectedRole,
                            canProceed: canProceedStep5,
                            onNext: { currentStep = 6 }
                        )
                    } else if currentStep == 6 {
                        Step6AffiliationInput(
                            vm: vm,
                            selectedRole: selectedRole,
                            canProceed: canProceedStep6,
                            onNext: {
                                Task {
                                    // 회원가입 API 호출 (인증 코드 자동 발송)
                                    vm.role = selectedRole?.apiValue ?? ""
                                    let success = await vm.signup()
                                    if success {
                                        remainingTime = 300
                                        startTimer()
                                        currentStep = 7
                                    }
                                }
                            }
                        )
                    } else if currentStep == 7 {
                        Step7VerificationCode(
                            vm: vm,
                            verificationCode: $verificationCode,
                            isCodeFieldFocused: $isCodeFieldFocused,
                            remainingTime: $remainingTime,
                            canProceed: canProceedStep7,
                            onResend: {
                                Task {
                                    // 재전송만 send-code 사용
                                    await vm.sendVerificationCode()
                                    remainingTime = 300
                                    startTimer()
                                }
                            },
                            onNext: {
                                Task {
                                    if let code = Int(verificationCode) {
                                        let success = await vm.verifyCode(code: code)
                                        if success {
                                            timer?.invalidate()
                                            currentStep = 8
                                        }
                                    }
                                }
                            }
                        )
                    } else if currentStep == 8 {
                        Step8SignupComplete(
                            onNext: { currentStep = 9 }
                        )
                    } else if currentStep == 9 {
                        Step9PermissionRequest(
                            onDismiss: { dismiss() }
                        )
                    }
                }
                .padding(.horizontal, 32)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - Validation
    private var canProceedStep1: Bool {
        !vm.email.isEmpty && vm.agreeTerms && vm.email.contains("@")
    }
    
    private var canProceedStep2: Bool {
        !vm.password.isEmpty && vm.password.count >= 6 && vm.agreeTerms
    }
    
    private var canProceedStep3: Bool {
        !confirmPassword.isEmpty && confirmPassword == vm.password && vm.agreeTerms
    }
    
    private var canProceedStep4: Bool {
        !vm.name.isEmpty && vm.agreeTerms
    }
    
    private var canProceedStep5: Bool {
        selectedRole != nil
    }
    
    private var canProceedStep6: Bool {
        !vm.affiliation.isEmpty
    }
    
    private var canProceedStep7: Bool {
        verificationCode.count == 6
    }
    
    // MARK: - Timer Functions
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if remainingTime > 0 {
                remainingTime -= 1
            } else {
                timer?.invalidate()
            }
        }
    }
}

#Preview {
    NavigationStack {
        SignUpView()
    }
}
