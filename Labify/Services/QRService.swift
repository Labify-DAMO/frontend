//
//  QRService.swift
//  Labify
//
//  Created by F_S on 10/30/25.
//

import Foundation

// MARK: - QR Service
struct QRService {
    static let networkManager = NetworkManager.shared
    
    // MARK: - ✅ QR 코드 생성
    /// 특정 폐기물에 대한 QR 코드를 생성합니다.
    /// - Parameters:
    ///   - disposalItemId: 폐기물 ID
    ///   - token: 사용자 인증 토큰
    /// - Returns: QR 코드 이미지 데이터
    static func createQRCode(
        disposalItemId: Int,
        token: String
    ) async throws -> Data {
        let request = CreateQRRequest(disposalItemId: disposalItemId)
        
        print("🔲 QR 코드 생성: Disposal ID=\(disposalItemId)")
        
        // POST 요청으로 QR 코드 생성 (이미지 데이터 반환)
        return try await networkManager.requestImage(
            endpoint: "/qr",
            method: "POST",
            body: request,
            token: token
        )
    }
    
    // MARK: - ✅ QR 코드 이미지 조회
    /// 특정 폐기물의 QR 코드 이미지를 조회합니다.
    /// - Parameters:
    ///   - disposalItemId: 폐기물 ID
    ///   - token: 사용자 인증 토큰
    /// - Returns: QR 코드 이미지 데이터
    static func fetchQRCodeImage(
        disposalItemId: Int,
        token: String
    ) async throws -> Data {
        print("🔍 QR 코드 조회: Disposal ID=\(disposalItemId)")
        
        // GET 요청으로 QR 코드 이미지 조회
        return try await networkManager.requestImage(
            endpoint: "/qr/\(disposalItemId)/image",
            method: "GET",
            token: token
        )
    }
}

// MARK: - NetworkManager Extension for Image Data

extension NetworkManager {
    /// 이미지 데이터를 요청하는 메서드
    func requestImage<T: Encodable>(
        endpoint: String,
        method: String,
        body: T? = nil,
        token: String? = nil
    ) async throws -> Data {
        guard let url = URL(string: baseURLString + endpoint) else {
            print("❌ Invalid URL: \(baseURLString + endpoint)")
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("image/png", forHTTPHeaderField: "Accept")
        
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(body)
            
            if let jsonString = String(data: request.httpBody!, encoding: .utf8) {
                print("📤 Request Body: \(jsonString)")
            }
        }
        
        print("📡 QR Image Request: \(method) \(url.absoluteString)")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Invalid response type")
            throw NetworkError.invalidResponse
        }
        
        print("📥 Response Status: \(httpResponse.statusCode)")
        print("📥 Response Data Size: \(data.count) bytes")
        
        if let contentType = httpResponse.value(forHTTPHeaderField: "Content-Type") {
            print("📥 Content-Type: \(contentType)")
        }
        
        guard httpResponse.statusCode == 200 else {
            if let errorString = String(data: data, encoding: .utf8) {
                print("❌ Error Response: \(errorString)")
            }
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
        
        // Content-Type 체크는 선택적으로 (일부 서버는 헤더를 제대로 안 보낼 수 있음)
        if let contentType = httpResponse.value(forHTTPHeaderField: "Content-Type") {
            if !contentType.contains("image") {
                print("⚠️ Warning: Content-Type is not image: \(contentType)")
            }
        }
        
        return data
    }
    
    /// 이미지 데이터를 요청하는 메서드 (body 없는 버전)
    func requestImage(
        endpoint: String,
        method: String,
        token: String? = nil
    ) async throws -> Data {
        guard let url = URL(string: baseURLString + endpoint) else {
            print("❌ Invalid URL: \(baseURLString + endpoint)")
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("image/png", forHTTPHeaderField: "Accept")
        
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        print("📡 QR Image Request: \(method) \(url.absoluteString)")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Invalid response type")
            throw NetworkError.invalidResponse
        }
        
        print("📥 Response Status: \(httpResponse.statusCode)")
        print("📥 Response Data Size: \(data.count) bytes")
        
        if let contentType = httpResponse.value(forHTTPHeaderField: "Content-Type") {
            print("📥 Content-Type: \(contentType)")
        }
        
        guard httpResponse.statusCode == 200 else {
            if let errorString = String(data: data, encoding: .utf8) {
                print("❌ Error Response: \(errorString)")
            }
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
        
        return data
    }
}
