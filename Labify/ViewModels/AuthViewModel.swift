//
//  AuthViewModel.swift
//  Labify
//
//  Created by F_s on 9/22/25.
//

import Foundation
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isAuthenticated = false
    @Published var userInfo: UserInfo?
    
    // 이메일 인증 코드 전송 성공 여부
    @Published var isVerificationCodeSent = false
    
    // UI에서 바인딩할 프로퍼티들
    @Published var email = ""
    @Published var password = ""
    @Published var name = ""
    @Published var role = ""
    @Published var affiliation = ""
    @Published var agreeTerms = false
    
    private var accessToken: String?
    private var refreshToken: String?
    
    init() {
        loadTokens()
    }
    
    // MARK: - 회원가입
    func signup() async -> Bool {
        isLoading = true
        errorMessage = nil
        
        let request = SignupRequest(
            name: name,
            email: email,
            password: password,
            role: role,
            affiliation: affiliation,
            agreeTerms: agreeTerms
        )
        
        do {
            try await AuthService.signup(request: request)
            isLoading = false
            return true
        } catch let error as NetworkError {
            isLoading = false
            
            // 404 에러 처리: 이미 가입된 이메일
            if case .httpError(let statusCode) = error, statusCode == 404 {
                errorMessage = "이미 가입된 이메일입니다. 로그인을 시도해주세요."
            } else {
                errorMessage = error.localizedDescription
            }
            return false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    // MARK: - 이메일 인증 코드 전송
    func sendVerificationCode() async -> Bool {
        isLoading = true
        errorMessage = nil
        isVerificationCodeSent = false
        
        do {
            try await AuthService.sendVerificationCode(email: email)
            isLoading = false
            isVerificationCodeSent = true
            return true
        } catch let error as NetworkError {
            isLoading = false
            
            // 404 에러 처리: 이미 인증 코드가 전송됨
            if case .httpError(let statusCode) = error, statusCode == 404 {
                errorMessage = "인증 코드가 이미 전송되었습니다.\n아래 '코드 재전송' 버튼을 눌러주세요."
                // 404여도 일단 다음 단계로 진행 가능하게
                isVerificationCodeSent = true
                return true
            } else {
                errorMessage = error.localizedDescription
            }
            return false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    // MARK: - 이메일 인증 코드 확인
    func verifyCode(code: Int) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        let request = VerifyCodeRequest(email: email, code: code)
        
        do {
            try await AuthService.verifyCode(request: request)
            isLoading = false
            return true
        } catch let error as NetworkError {
            isLoading = false
            
            // 400 에러: 코드 불일치
            if case .httpError(let statusCode) = error, statusCode == 400 {
                errorMessage = "인증 코드가 일치하지 않습니다.\n다시 확인해주세요."
            } else {
                errorMessage = error.localizedDescription
            }
            return false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    // MARK: - 로그인
    func login() async -> Bool {
        isLoading = true
        errorMessage = nil
        
        let request = LoginRequest(email: email, password: password)
        
        do {
            let response = try await AuthService.login(request: request)
            accessToken = response.accessToken
            refreshToken = response.refreshToken
            saveTokens()
            isAuthenticated = true
            
            // 로그인 후 사용자 정보 가져오기
            try await fetchUserInfo()
            
            // ✅ userId 저장 추가
            if let userId = userInfo?.userId {
                UserDefaults.standard.set(userId, forKey: "userId")
                print("✅ userId 저장 완료: \(userId)")
            }
            
            isLoading = false
            return true
        } catch let error as NetworkError {
            isLoading = false
            
            // 401 에러: 인증 실패
            if case .httpError(let statusCode) = error, statusCode == 401 {
                errorMessage = "이메일 또는 비밀번호가 일치하지 않습니다."
            } else {
                errorMessage = error.localizedDescription
            }
            return false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    // MARK: - 사용자 정보 조회
    func fetchUserInfo() async throws {
        guard let token = accessToken else {
            errorMessage = "로그인이 필요합니다."
            return
        }
        
        do {
            let info = try await AuthService.getUserInfo(token: token)
            userInfo = info
            role = info.role
            name = info.name
            affiliation = info.affiliation
            
            // ✅ 사용자 정보 로드 시 userId도 저장
            UserDefaults.standard.set(info.userId, forKey: "userId")
        } catch {
            // 토큰 만료 시 재발급
            if await refreshAccessToken() {
                try await fetchUserInfo()
            } else {
                logout()
                throw error
            }
        }
    }
    
    // MARK: - 토큰 재발급
    func refreshAccessToken() async -> Bool {
        guard let refreshToken = refreshToken else { return false }
        let request = RefreshTokenRequest(refresh_token: refreshToken)
        
        do {
            let response = try await AuthService.refreshToken(request)
            accessToken = response.accessToken
            self.refreshToken = response.refreshToken
            saveTokens()
            return true
        } catch {
            return false
        }
    }
    
    // MARK: - 로그아웃
    func logout() {
        accessToken = nil
        refreshToken = nil
        userInfo = nil
        isAuthenticated = false
        clearTokens()
        
        // ✅ userId도 함께 삭제
        UserDefaults.standard.removeObject(forKey: "userId")
        print("✅ userId 삭제 완료")
    }
    
    // MARK: - 토큰 저장/로드
    private func saveTokens() {
        if let token = accessToken {
            UserDefaults.standard.set(token, forKey: "accessToken")
        }
        if let token = refreshToken {
            UserDefaults.standard.set(token, forKey: "refreshToken")
        }
    }
    
    private func loadTokens() {
        accessToken = UserDefaults.standard.string(forKey: "accessToken")
        refreshToken = UserDefaults.standard.string(forKey: "refreshToken")
        
        if accessToken != nil {
            isAuthenticated = true
            Task {
                try? await fetchUserInfo()
                
                // ✅ 사용자 정보를 불러온 후 userId 동기화
                if let userId = userInfo?.userId {
                    UserDefaults.standard.set(userId, forKey: "userId")
                }
            }
        }
    }
    
    private func clearTokens() {
        UserDefaults.standard.removeObject(forKey: "accessToken")
        UserDefaults.standard.removeObject(forKey: "refreshToken")
    }
}


// MARK: - Models
struct SignupRequest: Codable {
    let name: String
    let email: String
    let password: String
    let role: String
    let affiliation: String
    let agreeTerms: Bool
}

struct EmailRequest: Codable {
    let email: String
}

struct VerifyCodeRequest: Codable {
    let email: String
    let code: Int
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct RefreshTokenRequest: Codable {
    let refresh_token: String
}

// TokenResponse와 UserInfo는 Models.swift에 정의되어 있음
