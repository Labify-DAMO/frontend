////
////  MockNetworkManager.swift
////  Labify
////
////  Created by F_S on 10/13/25.
////
//
//import Foundation
//
//// 🔥 Mock Network Manager - 서버 없이 테스트용!
//class MockNetworkManager {
//    static let shared = MockNetworkManager()
//    
//    // 가짜 사용자 데이터베이스
//    private var users: [String: String] = [
//        "test@test.com": "password123"
//    ]
//    
//    // 가짜 토큰 저장소
//    private var tokens: [String: (access: String, refresh: String)] = [:]
//    
//    private init() {}
//    
//    // 가짜 로그인
//    func login(email: String, password: String) async throws -> LoginResponse {
//        // 1초 대기 (실제 네트워크처럼)
//        try await Task.sleep(nanoseconds: 1_000_000_000)
//        
//        print("📡 Mock Login Request")
//        print("Email: \(email)")
//        print("Password: \(password)")
//        
//        // 이메일 체크
//        guard let storedPassword = users[email] else {
//            throw NetworkError.serverError("존재하지 않는 이메일입니다.")
//        }
//        
//        // 비밀번호 체크
//        guard storedPassword == password else {
//            throw NetworkError.serverError("비밀번호가 일치하지 않습니다.")
//        }
//        
//        // 토큰 생성
//        let accessToken = "mock_access_token_\(UUID().uuidString)"
//        let refreshToken = "mock_refresh_token_\(UUID().uuidString)"
//        
//        tokens[email] = (accessToken, refreshToken)
//        
//        print("✅ Mock 로그인 성공!")
//        
//        return LoginResponse(
//            accessToken: accessToken,
//            refreshToken: refreshToken
//        )
//    }
//    
//    // 가짜 회원가입
//    func signup(
//        name: String,
//        email: String,
//        password: String,
//        role: String,
//        affiliation: String,
//        agreeTerms: Bool
//    ) async throws {
//        // 1초 대기
//        try await Task.sleep(nanoseconds: 1_000_000_000)
//        
//        print("📡 Mock Signup Request")
//        print("Name: \(name)")
//        print("Email: \(email)")
//        print("Role: \(role)")
//        print("Affiliation: \(affiliation)")
//        print("Agree Terms: \(agreeTerms)")
//        
//        // 이미 존재하는 이메일 체크
//        if users[email] != nil {
//            throw NetworkError.serverError("이미 존재하는 이메일입니다.")
//        }
//        
//        // 비밀번호 길이 체크
//        guard password.count >= 8 else {
//            throw NetworkError.serverError("비밀번호는 8자 이상이어야 합니다.")
//        }
//        
//        // 이메일 형식 체크
//        guard email.contains("@") && email.contains(".") else {
//            throw NetworkError.serverError("올바른 이메일 형식이 아닙니다.")
//        }
//        
//        // 약관 동의 체크
//        guard agreeTerms else {
//            throw NetworkError.serverError("이용약관에 동의해주세요.")
//        }
//        
//        // 사용자 추가
//        users[email] = password
//        
//        print("✅ Mock 회원가입 성공!")
//        print("현재 등록된 사용자: \(users.keys.joined(separator: ", "))")
//    }
//    
//    // 가짜 인증 코드 전송
//    func sendVerificationCode(email: String) async throws {
//        try await Task.sleep(nanoseconds: 500_000_000)
//        print("📧 인증 코드 전송됨: 123456 (Mock)")
//    }
//    
//    // 가짜 인증 코드 확인
//    func verifyCode(email: String, code: String) async throws -> Bool {
//        try await Task.sleep(nanoseconds: 500_000_000)
//        // 테스트용으로 123456만 허용
//        return code == "123456"
//    }
//}
//
//// MARK: - 실제 NetworkManager 수정
//class NetworkManager {
//    static let shared = NetworkManager()
//    
//    // 🔥 개발 모드 플래그 (서버 없을 때 true로!)
//    private let useMockServer = true
//    
//    private let baseURL = "http://localhost:8000"
//    
//    private init() {}
//    
//    func login(email: String, password: String) async throws -> LoginResponse {
//        // Mock 모드면 가짜 서버 사용
//        if useMockServer {
//            return try await MockNetworkManager.shared.login(email: email, password: password)
//        }
//        
//        // 실제 서버 로직
//        guard let url = URL(string: "\(baseURL)/api/auth/login") else {
//            throw NetworkError.invalidURL
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        let body = LoginRequest(email: email, password: password)
//        request.httpBody = try JSONEncoder().encode(body)
//        
//        let (data, response) = try await URLSession.shared.data(for: request)
//        
//        guard let httpResponse = response as? HTTPURLResponse else {
//            throw NetworkError.invalidResponse
//        }
//        
//        guard httpResponse.statusCode == 200 else {
//            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
//                throw NetworkError.serverError(errorResponse.message)
//            }
//            throw NetworkError.httpError(httpResponse.statusCode)
//        }
//        
//        return try JSONDecoder().decode(LoginResponse.self, from: data)
//    }
//    
//    func signup(
//        name: String,
//        email: String,
//        password: String,
//        role: String,
//        affiliation: String,
//        agreeTerms: Bool
//    ) async throws {
//        // Mock 모드면 가짜 서버 사용
//        if useMockServer {
//            try await MockNetworkManager.shared.signup(
//                name: name,
//                email: email,
//                password: password,
//                role: role,
//                affiliation: affiliation,
//                agreeTerms: agreeTerms
//            )
//            return
//        }
//        
//        // 실제 서버 로직
//        guard let url = URL(string: "\(baseURL)/api/auth/signup") else {
//            throw NetworkError.invalidURL
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        let body = SignupRequest(
//            name: name,
//            email: email,
//            password: password,
//            role: role,
//            affiliation: affiliation,
//            agreeTerms: agreeTerms
//        )
//        request.httpBody = try JSONEncoder().encode(body)
//        
//        let (data, response) = try await URLSession.shared.data(for: request)
//        
//        guard let httpResponse = response as? HTTPURLResponse else {
//            throw NetworkError.invalidResponse
//        }
//        
//        guard (200...201).contains(httpResponse.statusCode) else {
//            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
//                throw NetworkError.serverError(errorResponse.message)
//            }
//            throw NetworkError.httpError(httpResponse.statusCode)
//        }
//    }
//}
//
//// MARK: - Models
//struct LoginRequest: Codable {
//    let email: String
//    let password: String
//}
//
//struct SignupRequest: Codable {
//    let name: String
//    let email: String
//    let password: String
//    let role: String
//    let affiliation: String
//    let agreeTerms: Bool
//}
//
//struct LoginResponse: Codable {
//    let accessToken: String
//    let refreshToken: String
//    
//    enum CodingKeys: String, CodingKey {
//        case accessToken = "access_token"
//        case refreshToken = "refresh_token"
//    }
//}
//
//struct ErrorResponse: Codable {
//    let message: String
//}
//
//enum NetworkError: LocalizedError {
//    case invalidURL
//    case invalidResponse
//    case httpError(Int)
//    case serverError(String)
//    case decodingError
//    
//    var errorDescription: String? {
//        switch self {
//        case .invalidURL:
//            return "잘못된 URL입니다."
//        case .invalidResponse:
//            return "서버 응답이 올바르지 않습니다."
//        case .httpError(let code):
//            return "HTTP 에러: \(code)"
//        case .serverError(let message):
//            return message
//        case .decodingError:
//            return "데이터 파싱에 실패했습니다."
//        }
//    }
//}
//
//// MARK: - User Role
//enum Role: String, Codable {
//    case LAB_MANAGER
//    case PICKUP_MANAGER
//    case FACILITY_MANAGER
//    
//    var displayName: String {
//        switch self {
//        case .LAB_MANAGER:
//            return "실험실 관리자"
//        case .PICKUP_MANAGER:
//            return "수거업체 관리자"
//        case .FACILITY_MANAGER:
//            return "시설 관리자"
//        }
//    }
//}
//
//// MARK: - User Response
//struct UserResponse: Codable {
//    let userId: Int
//    let name: String
//    let email: String
//    let role: Role
//    let affiliation: String
//}
