//
//  SignUpView.swift
//  Labify
//
//  Created by F_s on 9/22/25.
//

import SwiftUI

struct SignupView: View {
    @StateObject private var vm = AuthViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var currentStep = 1
    @State private var verificationCode = ""
    @State private var confirmPassword = ""
    @State private var selectedRole: UserRole? = nil
    @State private var showPassword1 = false
    @State private var showPassword2 = false
    @FocusState private var isCodeFieldFocused: Bool
    
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
                    
                    // 로고 (센터) - Step 6 이후에는 숨김
                    if currentStep < 6 {
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
                        step1EmailInput
                    } else if currentStep == 2 {
                        step2VerificationCode
                    } else if currentStep == 3 {
                        step3PasswordInput
                    } else if currentStep == 4 {
                        step4PasswordConfirm
                    } else if currentStep == 5 {
                        step5NameInput
                    } else if currentStep == 6 {
                        step6RoleSelection
                    } else if currentStep == 7 {
                        step7AffiliationInput
                    } else if currentStep == 8 {
                        step8SignupComplete
                    } else if currentStep == 9 {
                        step9PermissionRequest
                    }
                }
                .padding(.horizontal, 32)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - Step 1: 이메일 입력
    private var step1EmailInput: some View {
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
            
            Button(action: {
                vm.agreeTerms.toggle()
            }) {
                HStack(spacing: 6) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1.5)
                            .frame(width: 20, height: 20)
                        
                        if vm.agreeTerms {
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
            
            Button(action: {
                Task {
                    if await vm.sendVerificationCode() {
                        currentStep = 2
                    }
                }
            }) {
                Text(vm.isLoading ? "전송 중..." : "다음")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(canProceedStep1 ? Color.black : Color(white: 0.85))
                    .cornerRadius(10)
            }
            .disabled(!canProceedStep1 || vm.isLoading)
            .animation(.easeInOut(duration: 0.2), value: canProceedStep1)
            .padding(.top, 24)
        }
    }
    
    // MARK: - Step 2: 인증 코드 입력
    private var step2VerificationCode: some View {
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
                    Text("남은 시간 02:43")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Button(action: {
                        Task {
                            await vm.sendVerificationCode()
                        }
                    }) {
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
            
            // 다음 버튼
            Button(action: {
                Task {
                    if let code = Int(verificationCode) {
                        let success = await vm.verifyCode(code: code)
                        if success {
                            currentStep = 3
                        }
                    }
                }
            }) {
                Text(vm.isLoading ? "확인 중..." : "다음")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(canProceedStep2 ? Color.black : Color(white: 0.85))
                    .cornerRadius(10)
            }
            .disabled(!canProceedStep2 || vm.isLoading)
            .animation(.easeInOut(duration: 0.2), value: canProceedStep2)
        }
    }
    
    // MARK: - Step 3: 비밀번호 입력
    private var step3PasswordInput: some View {
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
                        if showPassword1 {
                            TextField("비밀번호를 입력해주세요.", text: $vm.password)
                        } else {
                            SecureField("비밀번호를 입력해주세요.", text: $vm.password)
                        }
                        
                        Button(action: {
                            showPassword1.toggle()
                        }) {
                            Image(systemName: showPassword1 ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color(white: 0.96))
                    .cornerRadius(10)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("이메일")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    TextField("", text: .constant(vm.email))
                        .disabled(true)
                        .padding()
                        .background(Color(white: 0.96))
                        .cornerRadius(10)
                }
                
                Button(action: {
                    vm.agreeTerms.toggle()
                }) {
                    HStack(spacing: 6) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1.5)
                                .frame(width: 20, height: 20)
                            
                            if vm.agreeTerms {
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
            
            Spacer()
                .frame(height: 50)
            
            // 다음 버튼
            Button(action: {
                currentStep = 4
            }) {
                Text("다음")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(canProceedStep3 ? Color.black : Color(white: 0.85))
                    .cornerRadius(10)
            }
            .disabled(!canProceedStep3)
            .animation(.easeInOut(duration: 0.2), value: canProceedStep3)
        }
    }
    
    // MARK: - Step 4: 비밀번호 확인
    private var step4PasswordConfirm: some View {
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
                        if showPassword2 {
                            TextField("비밀번호를 다시 입력해주세요.", text: $confirmPassword)
                        } else {
                            SecureField("비밀번호를 다시 입력해주세요.", text: $confirmPassword)
                        }
                        
                        Button(action: {
                            showPassword2.toggle()
                        }) {
                            Image(systemName: showPassword2 ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color(white: 0.96))
                    .cornerRadius(10)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("이메일")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    TextField("", text: .constant(vm.email))
                        .disabled(true)
                        .padding()
                        .background(Color(white: 0.96))
                        .cornerRadius(10)
                }
                
                Button(action: {
                    vm.agreeTerms.toggle()
                }) {
                    HStack(spacing: 6) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1.5)
                                .frame(width: 20, height: 20)
                            
                            if vm.agreeTerms {
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
            
            Spacer()
                .frame(height: 50)
            
            // 다음 버튼
            Button(action: {
                currentStep = 5
            }) {
                Text("다음")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(canProceedStep4 ? Color.black : Color(white: 0.85))
                    .cornerRadius(10)
            }
            .disabled(!canProceedStep4)
            .animation(.easeInOut(duration: 0.2), value: canProceedStep4)
        }
    }
    
    // MARK: - Step 5: 이름 입력
    private var step5NameInput: some View {
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
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("비밀번호 확인")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    HStack {
                        SecureField("", text: .constant(vm.password))
                            .disabled(true)
                        
                        Image(systemName: "eye.slash")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color(white: 0.96))
                    .cornerRadius(10)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("비밀번호")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    HStack {
                        SecureField("", text: .constant(vm.password))
                            .disabled(true)
                        
                        Image(systemName: "eye.slash")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color(white: 0.96))
                    .cornerRadius(10)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("이메일")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    TextField("", text: .constant(vm.email))
                        .disabled(true)
                        .padding()
                        .background(Color(white: 0.96))
                        .cornerRadius(10)
                }
                
                Button(action: {
                    vm.agreeTerms.toggle()
                }) {
                    HStack(spacing: 6) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1.5)
                                .frame(width: 20, height: 20)
                            
                            if vm.agreeTerms {
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
            
            Spacer()
                .frame(height: 50)
            
            // 다음 버튼
            Button(action: {
                currentStep = 6
            }) {
                Text("다음")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(canProceedStep5 ? Color.black : Color(white: 0.85))
                    .cornerRadius(10)
            }
            .disabled(!canProceedStep5)
            .animation(.easeInOut(duration: 0.2), value: canProceedStep5)
        }
    }
    
    // MARK: - Step 6: 역할 선택
    private var step6RoleSelection: some View {
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
            
            // 다음 버튼
            Button(action: {
                currentStep = 7
            }) {
                Text("다음")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(canProceedStep6 ? Color.black : Color(white: 0.85))
                    .cornerRadius(10)
            }
            .disabled(!canProceedStep6)
            .animation(.easeInOut(duration: 0.2), value: canProceedStep6)
        }
    }
    
    // MARK: - Step 7: 소속 입력
    private var step7AffiliationInput: some View {
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
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("역할")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    TextField("", text: .constant(selectedRole?.rawValue ?? ""))
                        .disabled(true)
                        .padding()
                        .background(Color(white: 0.96))
                        .cornerRadius(10)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("이름")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    TextField("", text: .constant(vm.name))
                        .disabled(true)
                        .padding()
                        .background(Color(white: 0.96))
                        .cornerRadius(10)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("이메일")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    TextField("", text: .constant(vm.email))
                        .disabled(true)
                        .padding()
                        .background(Color(white: 0.96))
                        .cornerRadius(10)
                }
            }
            
            if let error = vm.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.footnote)
            }
            
            Spacer()
                .frame(height: 50)
            
            // 회원가입 완료 버튼
            Button(action: {
                Task {
                    // ViewModel에 역할 저장
                    vm.role = selectedRole?.apiValue ?? ""
                    
                    let success = await vm.signup()
                    if success {
                        currentStep = 8
                    }
                }
            }) {
                Text(vm.isLoading ? "가입 중..." : "회원가입 완료")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(canProceedStep7 ? Color.black : Color(white: 0.85))
                    .cornerRadius(10)
            }
            .disabled(!canProceedStep7 || vm.isLoading)
            .animation(.easeInOut(duration: 0.2), value: canProceedStep7)
        }
    }
    
    // MARK: - Step 8: 회원가입 완료
    private var step8SignupComplete: some View {
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
            
            // 시작하기 버튼
            Button(action: {
                currentStep = 9
            }) {
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
    
    // MARK: - Step 9: 앱 접근 권한 안내
    private var step9PermissionRequest: some View {
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
            
            // 확인 버튼
            Button(action: {
                dismiss()
            }) {
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
    
    // MARK: - Validation
    private var canProceedStep1: Bool {
        !vm.email.isEmpty && vm.agreeTerms && vm.email.contains("@")
    }
    
    private var canProceedStep2: Bool {
        verificationCode.count == 6
    }
    
    private var canProceedStep3: Bool {
        !vm.password.isEmpty && vm.password.count >= 6 && vm.agreeTerms
    }
    
    private var canProceedStep4: Bool {
        !confirmPassword.isEmpty && confirmPassword == vm.password && vm.agreeTerms
    }
    
    private var canProceedStep5: Bool {
        !vm.name.isEmpty && vm.agreeTerms
    }
    
    private var canProceedStep6: Bool {
        selectedRole != nil
    }
    
    private var canProceedStep7: Bool {
        !vm.affiliation.isEmpty
    }
}

#Preview {
    NavigationStack {
        SignupView()
    }
}
