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
        
        do {
            try await AuthService.sendVerificationCode(email: email)
            isLoading = false
            return true
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
            accessToken = response.access_token
            refreshToken = response.refresh_token
            saveTokens()
            isAuthenticated = true
            
            // 로그인 후 사용자 정보 가져오기
            try await fetchUserInfo()
            isLoading = false
            return true
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
            accessToken = response.access_token
            self.refreshToken = response.refresh_token
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
            Task { try? await fetchUserInfo() }
        }
    }
    
    private func clearTokens() {
        UserDefaults.standard.removeObject(forKey: "accessToken")
        UserDefaults.standard.removeObject(forKey: "refreshToken")
    }
}

// MARK: - Models
struct EmptyResponse: Codable {}
struct SignupRequest: Codable {
    let name: String
    let email: String
    let password: String
    let role: String
    let affiliation: String
    let agreeTerms: Bool
}
struct EmailRequest: Codable { let email: String }
struct VerifyCodeRequest: Codable { let email: String; let code: Int }
struct LoginRequest: Codable { let email: String; let password: String }
struct TokenResponse: Codable { let access_token: String; let refresh_token: String }
struct RefreshTokenRequest: Codable { let refresh_token: String }
struct UserInfo: Codable {
    let userId: Int
    let name: String
    let email: String
    let role: String
    let affiliation: String
}
