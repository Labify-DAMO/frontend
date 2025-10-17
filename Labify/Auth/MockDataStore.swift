//
//  MockDataStore.swift
//  Labify
//
//  Created by F_S on 10/13/25.
//

import Foundation

// MARK: - Mock Data Store
class MockDataStore {
    static let shared = MockDataStore()
    
    private var mockUsers: [String: (password: String, user: UserInfo)] = [:]
    private var verificationCodes: [String: Int] = [:]
    private var tokens: [String: String] = [:] // accessToken -> email
    
    private init() {
        // 테스트용 계정 추가
        let testUser = UserInfo(
            userId: 1,
            name: "홍길동",
            email: "test@example.com",
            role: "LAB_MANAGER",
            affiliation: "테스트실험실"
        )
        mockUsers["test@example.com"] = ("password123", testUser)
    }
    
    // MARK: - 회원가입
    func signup(request: SignupRequest) async throws {
        // 이메일 중복 체크
        if mockUsers.keys.contains(request.email) {
            throw NSError(domain: "", code: 409, userInfo: [NSLocalizedDescriptionKey: "이미 존재하는 이메일입니다."])
        }
        
        // 사용자 저장
        let userInfo = UserInfo(
            userId: mockUsers.count + 1,
            name: request.name,
            email: request.email,
            role: request.role,
            affiliation: request.affiliation
        )
        mockUsers[request.email] = (request.password, userInfo)
        print("✅ 회원가입 완료: \(request.email)")
    }
    
    // MARK: - 인증 코드 확인
    func verifyCode(email: String, code: Int) async throws {
        guard let savedCode = verificationCodes[email] else {
            throw NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "인증 코드를 먼저 요청해주세요."])
        }
        
        guard savedCode == code else {
            throw NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "인증 코드가 일치하지 않습니다. 입력: \(code), 실제: \(savedCode)"])
        }
        
        verificationCodes.removeValue(forKey: email)
        print("✅ 인증 코드 확인 완료: \(email)")
    }
    
    // MARK: - 로그인
    func login(email: String, password: String) async throws -> TokenResponse {
        guard let user = mockUsers[email] else {
            throw NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "등록되지 않은 이메일입니다."])
        }
        
        guard user.password == password else {
            throw NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "비밀번호가 일치하지 않습니다."])
        }
        
        let accessToken = "mock.access.token.\(email).\(UUID().uuidString)"
        let refreshToken = "mock.refresh.token.\(email).\(UUID().uuidString)"
        
        tokens[accessToken] = email
        
        print("✅ 로그인 완료: \(email)")
        print("🔑 Access Token: \(accessToken)")
        
        return TokenResponse(
            accessToken: accessToken,
            refreshToken: refreshToken
        )
    }
    
    // MARK: - 토큰 재발급
    func refreshToken(refreshToken: String) async throws -> TokenResponse {
        // refreshToken에서 이메일 추출
        let components = refreshToken.split(separator: ".")
        guard components.count >= 4 else {
            throw NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "유효하지 않은 리프레시 토큰입니다."])
        }
        
        let email = String(components[2])
        
        guard mockUsers[email] != nil else {
            throw NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "유효하지 않은 토큰입니다."])
        }
        
        let newAccessToken = "mock.access.token.\(email).\(UUID().uuidString)"
        
        tokens[newAccessToken] = email
        
        print("✅ 토큰 재발급 완료: \(email)")
        print("🔑 New Access Token: \(newAccessToken)")
        
        return TokenResponse(
            accessToken: newAccessToken,
            refreshToken: refreshToken
        )
    }
    
    // MARK: - 사용자 정보 조회
    func getUserInfo(token: String) async throws -> UserInfo {
        guard let email = tokens[token] else {
            throw NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "유효하지 않은 액세스 토큰입니다."])
        }
        
        guard let user = mockUsers[email] else {
            throw NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "사용자 정보를 찾을 수 없습니다."])
        }
        
        print("✅ 사용자 정보 조회: \(email)")
        print("👤 사용자: \(user.user.name) (\(user.user.role))")
        
        return user.user
    }
    
    // MARK: - Debug: 현재 저장된 모든 사용자 출력
    func printAllUsers() {
        print("\n=== 저장된 사용자 목록 ===")
        for (email, data) in mockUsers {
            print("📧 \(email)")
            print("   이름: \(data.user.name)")
            print("   역할: \(data.user.role)")
            print("   소속: \(data.user.affiliation)")
            print("   비밀번호: \(data.password)")
            print("")
        }
        print("======================\n")
    }
    
    // MARK: - Debug: 현재 인증 코드 출력
    func printVerificationCodes() {
        print("\n=== 활성 인증 코드 ===")
        for (email, code) in verificationCodes {
            print("📧 \(email): \(code)")
        }
        if verificationCodes.isEmpty {
            print("(없음)")
        }
        print("===================\n")
    }
}
