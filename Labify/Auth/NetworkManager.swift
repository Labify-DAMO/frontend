////
////  NetworkManager.swift
////  Labify
////
////  Created by F_s on 10/2/25.
////
//
//import Foundation
//
//class NetworkManager {
//	static let shared = NetworkManager()
//	
//	// 🔥 여기에 백엔드 개발자한테 받은 주소 입력!
//	// 예: "http://localhost:8000" 또는 "http://192.168.0.10:8000"
//	private let baseURL = "http://localhost:8000"
//	
//	private init() {}
//	
//	// 로그인 요청
//	func login(email: String, password: String) async throws -> LoginResponse {
//		// 1. URL 만들기
//		guard let url = URL(string: "\(baseURL)/api/auth/login") else {
//			throw NetworkError.invalidURL
//		}
//		
//		// 2. Request 설정
//		var request = URLRequest(url: url)
//		request.httpMethod = "POST"
//		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//		
//		// 3. Body 데이터 만들기
//		let body = LoginRequest(email: email, password: password)
//		request.httpBody = try JSONEncoder().encode(body)
//		
//		// 4. 요청 보내기
//		let (data, response) = try await URLSession.shared.data(for: request)
//		
//		// 5. 상태 코드 확인
//		guard let httpResponse = response as? HTTPURLResponse else {
//			throw NetworkError.invalidResponse
//		}
//		
//		print("📡 Status Code: \(httpResponse.statusCode)")
//		
//		guard httpResponse.statusCode == 200 else {
//			// 에러 메시지 파싱 시도
//			if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
//				throw NetworkError.serverError(errorResponse.message)
//			}
//			throw NetworkError.httpError(httpResponse.statusCode)
//		}
//		
//		// 6. 응답 데이터 파싱
//		let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
//		
//		print("✅ 로그인 성공!")
//		print("Access Token: \(loginResponse.accessToken)")
//		print("Refresh Token: \(loginResponse.refreshToken)")
//		
//		return loginResponse
//	}
//}
//
//// MARK: - Request Models
//struct LoginRequest: Codable {
//	let email: String
//	let password: String
//}
//
//// MARK: - Response Models
//struct LoginResponse: Codable {
//	let accessToken: String
//	let refreshToken: String
//	
//	enum CodingKeys: String, CodingKey {
//		case accessToken = "access_token"
//		case refreshToken = "refresh_token"
//	}
//}
//
//struct ErrorResponse: Codable {
//	let message: String
//}
//
//// MARK: - Network Errors
//enum NetworkError: LocalizedError {
//	case invalidURL
//	case invalidResponse
//	case httpError(Int)
//	case serverError(String)
//	case decodingError
//	
//	var errorDescription: String? {
//		switch self {
//			case .invalidURL:
//				return "잘못된 URL입니다."
//			case .invalidResponse:
//				return "서버 응답이 올바르지 않습니다."
//			case .httpError(let code):
//				return "HTTP 에러: \(code)"
//			case .serverError(let message):
//				return message
//			case .decodingError:
//				return "데이터 파싱에 실패했습니다."
//		}
//	}
//}

import Foundation

// MARK: - NetworkError
enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError
    case encodingError
    case noData
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "유효하지 않은 URL입니다."
        case .invalidResponse:
            return "서버 응답이 올바르지 않습니다."
        case .httpError(let statusCode):
            return "HTTP 에러: \(statusCode)"
        case .decodingError:
            return "데이터 변환에 실패했습니다."
        case .encodingError:
            return "데이터 인코딩에 실패했습니다."
        case .noData:
            return "데이터가 없습니다."
        case .unauthorized:
            return "인증이 필요합니다."
        }
    }
}

// MARK: - NetworkManager
class NetworkManager {
    static let shared = NetworkManager()
    
    // 실제 서버 URL로 변경하세요
    private let baseURL = "http://localhost:8080"
    
    // 🔥 서버 없이 테스트하려면 이 값을 true로 설정하세요
    private let useMockData = true
    
    private init() {}
    
    // MARK: - Generic Request Method
    func request<T: Decodable, B: Encodable>(
        endpoint: String,
        method: String = "GET",
        body: B? = nil,
        token: String? = nil
    ) async throws -> T {
        
        // Mock 데이터 사용
        if useMockData {
            return try await handleMockRequest(endpoint: endpoint, method: method, body: body, token: token)
        }
        
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Bearer Token 추가
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Body 추가
        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                throw NetworkError.encodingError
            }
        }
        
        // Request 수행
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Response 검증
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        // 상태 코드 체크
        guard (200...299).contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == 401 {
                throw NetworkError.unauthorized
            }
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
        
        // 빈 응답 처리
        if T.self == EmptyResponse.self {
            return EmptyResponse() as! T
        }
        
        // JSON 디코딩
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(T.self, from: data)
            return result
        } catch {
            print("Decoding error: \(error)")
            throw NetworkError.decodingError
        }
    }
    
    // MARK: - GET Request (without body)
    func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        token: String? = nil
    ) async throws -> T {
        
        // Mock 데이터 사용
        if useMockData {
            return try await handleMockRequest(endpoint: endpoint, method: method, body: EmptyBody?.none, token: token)
        }
        
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Bearer Token 추가
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Request 수행
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Response 검증
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        // 상태 코드 체크
        guard (200...299).contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == 401 {
                throw NetworkError.unauthorized
            }
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
        
        // JSON 디코딩
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(T.self, from: data)
            return result
        } catch {
            print("Decoding error: \(error)")
            throw NetworkError.decodingError
        }
    }
    
    // MARK: - Mock Request Handler
    private func handleMockRequest<T: Decodable, B: Encodable>(
        endpoint: String,
        method: String,
        body: B?,
        token: String?
    ) async throws -> T {
        
        // 네트워크 딜레이 시뮬레이션
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        switch endpoint {
        case "/api/auth/signup":
            if let signupBody = body as? SignupRequest {
                try await MockDataStore.shared.signup(request: signupBody)
                return EmptyResponse() as! T
            }
            
        case "/api/auth/send-code":
            if let emailBody = body as? EmailRequest {
                try await MockDataStore.shared.sendVerificationCode(email: emailBody.email)
                return EmptyResponse() as! T
            }
            
        case "/api/auth/verify-code":
            if let verifyBody = body as? VerifyCodeRequest {
                try await MockDataStore.shared.verifyCode(email: verifyBody.email, code: verifyBody.code)
                return EmptyResponse() as! T
            }
            
        case "/api/auth/login":
            if let loginBody = body as? LoginRequest {
                let response = try await MockDataStore.shared.login(email: loginBody.email, password: loginBody.password)
                return response as! T
            }
            
        case "/api/auth/refresh":
            if let refreshBody = body as? RefreshTokenRequest {
                let response = try await MockDataStore.shared.refreshToken(refreshToken: refreshBody.refresh_token)
                return response as! T
            }
            
        case "/api/user/me":
            if let token = token {
                let response = try await MockDataStore.shared.getUserInfo(token: token)
                return response as! T
            }
            
        default:
            break
        }
        
        throw NetworkError.invalidURL
    }
}

// MARK: - Empty Body
struct EmptyBody: Codable {}

// MARK: - Mock NetworkManager (테스트용)
class MockNetworkManager {
    static let shared = MockNetworkManager()
    
    private var mockUsers: [String: (password: String, user: UserInfo)] = [:]
    private var verificationCodes: [String: Int] = [:]
    
    private init() {}
    
    // 회원가입
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
        
        // 1초 딜레이 (실제 네트워크 시뮬레이션)
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
    
    // 인증 코드 전송
    func sendVerificationCode(email: String) async throws {
        let code = Int.random(in: 100000...999999)
        verificationCodes[email] = code
        print("📧 인증 코드 전송: \(email) -> \(code)")
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
    
    // 인증 코드 확인
    func verifyCode(email: String, code: Int) async throws {
        guard let savedCode = verificationCodes[email], savedCode == code else {
            throw NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "인증 코드가 일치하지 않습니다."])
        }
        verificationCodes.removeValue(forKey: email)
        try await Task.sleep(nanoseconds: 500_000_000)
    }
    
    // 로그인
    func login(email: String, password: String) async throws -> TokenResponse {
        guard let user = mockUsers[email], user.password == password else {
            throw NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "이메일 또는 비밀번호가 일치하지 않습니다."])
        }
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        return TokenResponse(
            access_token: "mock.access.token.\(email)",
            refresh_token: "mock.refresh.token.\(email)"
        )
    }
    
    // 사용자 정보 조회
    func getUserInfo(token: String) async throws -> UserInfo {
        let email = token.replacingOccurrences(of: "mock.access.token.", with: "")
        
        guard let user = mockUsers[email] else {
            throw NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "유효하지 않은 토큰입니다."])
        }
        
        try await Task.sleep(nanoseconds: 500_000_000)
        return user.user
    }
}
