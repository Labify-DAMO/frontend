//
//  NetworkManager.swift
//  Labify
//
//  Created by F_s on 10/2/25.
//

import Foundation

class NetworkManager {
	static let shared = NetworkManager()
	
	// 🔥 여기에 백엔드 개발자한테 받은 주소 입력!
	// 예: "http://localhost:8000" 또는 "http://192.168.0.10:8000"
	private let baseURL = "http://localhost:8000"
	
	private init() {}
	
	// 로그인 요청
	func login(email: String, password: String) async throws -> LoginResponse {
		// 1. URL 만들기
		guard let url = URL(string: "\(baseURL)/api/auth/login") else {
			throw NetworkError.invalidURL
		}
		
		// 2. Request 설정
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		
		// 3. Body 데이터 만들기
		let body = LoginRequest(email: email, password: password)
		request.httpBody = try JSONEncoder().encode(body)
		
		// 4. 요청 보내기
		let (data, response) = try await URLSession.shared.data(for: request)
		
		// 5. 상태 코드 확인
		guard let httpResponse = response as? HTTPURLResponse else {
			throw NetworkError.invalidResponse
		}
		
		print("📡 Status Code: \(httpResponse.statusCode)")
		
		guard httpResponse.statusCode == 200 else {
			// 에러 메시지 파싱 시도
			if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
				throw NetworkError.serverError(errorResponse.message)
			}
			throw NetworkError.httpError(httpResponse.statusCode)
		}
		
		// 6. 응답 데이터 파싱
		let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
		
		print("✅ 로그인 성공!")
		print("Access Token: \(loginResponse.accessToken)")
		print("Refresh Token: \(loginResponse.refreshToken)")
		
		return loginResponse
	}
}

// MARK: - Request Models
struct LoginRequest: Codable {
	let email: String
	let password: String
}

// MARK: - Response Models
struct LoginResponse: Codable {
	let accessToken: String
	let refreshToken: String
	
	enum CodingKeys: String, CodingKey {
		case accessToken = "access_token"
		case refreshToken = "refresh_token"
	}
}

struct ErrorResponse: Codable {
	let message: String
}

// MARK: - Network Errors
enum NetworkError: LocalizedError {
	case invalidURL
	case invalidResponse
	case httpError(Int)
	case serverError(String)
	case decodingError
	
	var errorDescription: String? {
		switch self {
			case .invalidURL:
				return "잘못된 URL입니다."
			case .invalidResponse:
				return "서버 응답이 올바르지 않습니다."
			case .httpError(let code):
				return "HTTP 에러: \(code)"
			case .serverError(let message):
				return message
			case .decodingError:
				return "데이터 파싱에 실패했습니다."
		}
	}
}
