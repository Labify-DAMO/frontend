//
//  NetworkManager.swift
//  Labify
//
//  Created by F_S on 10/14/25.
//

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
    
    // 🔥 실제 백엔드 서버 주소
    //private let baseURL = "http://localhost:8080"

    private let baseURL = "http://localhost:8080"
    func getBaseURL() -> String {
        return baseURL
    }

    
    var baseURLString: String {
        return baseURL
    }
    
    private init() {}
    
    // MARK: - Generic Request Method (with body)
    func request<T: Decodable, B: Encodable>(
        endpoint: String,
        method: String = "GET",
        body: B? = nil,
        token: String? = nil
    ) async throws -> T {
        
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else if let storedToken = TokenStore.read() {
            request.setValue("Bearer \(storedToken)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
                if let bodyString = String(data: request.httpBody!, encoding: .utf8) {
                    print("📤 Request to \(endpoint)")
                    print("📦 Body: \(bodyString)")
                }
            } catch {
                print("❌ Encoding error: \(error)")
                throw NetworkError.encodingError
            }
        }
        
        print("📡 \(method) \(url)")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        print("📥 Status: \(httpResponse.statusCode)")
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorString = String(data: data, encoding: .utf8) {
                print("❌ Error Response: \(errorString)")
            }
            
            if httpResponse.statusCode == 401 {
                throw NetworkError.unauthorized
            }
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
        
        // EmptyResponse 처리
        if T.self == EmptyResponse.self {
            print("✅ Success (Empty Response)")
            return EmptyResponse() as! T
        }
        
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(T.self, from: data)
            print("✅ Success")
            if let resultString = String(data: data, encoding: .utf8) {
                print("📄 Response: \(resultString)")
            }
            return result
        } catch {
            print("❌ Decoding error: \(error)")
            if let dataString = String(data: data, encoding: .utf8) {
                print("📄 Raw Response: \(dataString)")
            }
            throw NetworkError.decodingError
        }
    }
    
    // MARK: - GET Request (without body)
    func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        token: String? = nil
    ) async throws -> T {
        let emptyBody: EmptyBody? = nil
        return try await request(endpoint: endpoint, method: method, body: emptyBody, token: token)
    }
}

// MARK: - Empty Body
struct EmptyBody: Codable {}
