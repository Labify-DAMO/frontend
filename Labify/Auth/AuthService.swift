//
//  AuthService.swift
//  Labify
//
//  Created by F_s on 9/22/25.
//

//import Foundation
//
//class AuthService {
//	private let baseURL = "http://localhost:8080/api/auth" // Spring Boot 서버 URL
//	
//	func login(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
//		guard let url = URL(string: "\(baseURL)/login") else { return }
//		
//		var request = URLRequest(url: url)
//		request.httpMethod = "POST"
//		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//		
//		let body: [String: Any] = ["email": email, "password": password]
//		request.httpBody = try? JSONSerialization.data(withJSONObject: body)
//		
//		URLSession.shared.dataTask(with: request) { data, response, error in
//			if let error = error {
//				completion(.failure(error))
//				return
//			}
//			guard let data = data else { return }
//			
//			do {
//				// 서버에서 JWT 토큰이나 세션 ID 반환한다고 가정
//				if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
//					let token = json["token"] as? String {
//					completion(.success(token))
//				} else {
//					completion(.failure(NSError(domain: "InvalidResponse", code: -1)))
//				}
//			} catch {
//				completion(.failure(error))
//			}
//		}.resume()
//	}
//	
//	func signup(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
//		guard let url = URL(string: "\(baseURL)/signup") else { return }
//		
//		var request = URLRequest(url: url)
//		request.httpMethod = "POST"
//		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//		
//		let body: [String: Any] = ["email": email, "password": password]
//		request.httpBody = try? JSONSerialization.data(withJSONObject: body)
//		
//		URLSession.shared.dataTask(with: request) { _, _, error in
//			if let error = error {
//				completion(.failure(error))
//			} else {
//				completion(.success(()))
//			}
//		}.resume()
//	}
//}

import Foundation

struct AuthService {
    
    static let networkManager = NetworkManager.shared
    
    // MARK: - 회원가입
    static func signup(request: SignupRequest) async throws {
        let _: EmptyResponse = try await networkManager.request(
            endpoint: "/api/auth/signup",
            method: "POST",
            body: request
        )
    }
    
    // MARK: - 로그인
    static func login(request: LoginRequest) async throws -> TokenResponse {
        let response: TokenResponse = try await networkManager.request(
            endpoint: "/api/auth/login",
            method: "POST",
            body: request
        )
        return response
    }
    
    // MARK: - 토큰 재발급
    static func refreshToken(_ request: RefreshTokenRequest) async throws -> TokenResponse {
        let response: TokenResponse = try await networkManager.request(
            endpoint: "/api/auth/refresh",
            method: "POST",
            body: request
        )
        return response
    }
    
    // MARK: - 사용자 정보 조회
    static func getUserInfo(token: String) async throws -> UserInfo {
        let response: UserInfo = try await networkManager.request(
            endpoint: "/api/user/me",
            method: "GET",
            token: token
        )
        return response
    }
    
    // MARK: - 이메일 인증 코드 전송
    static func sendVerificationCode(email: String) async throws {
        let request = EmailRequest(email: email)
        let _: EmptyResponse = try await networkManager.request(
            endpoint: "/api/auth/send-code",
            method: "POST",
            body: request
        )
    }
    
    // MARK: - 인증 코드 확인
    static func verifyCode(request: VerifyCodeRequest) async throws {
        let _: EmptyResponse = try await networkManager.request(
            endpoint: "/api/auth/verify-code",
            method: "POST",
            body: request
        )
    }
}
