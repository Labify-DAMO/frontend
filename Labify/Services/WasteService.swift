//
//  WasteService.swift
//  Labify
//
//  Created by F_S on 10/15/25.
//

import Foundation

// MARK: - Waste Service
struct WasteService {
    static let networkManager = NetworkManager.shared
    
    // MARK: - ✅ AI 폐기물 분류
    static func classifyWaste(imageData: Data, token: String) async throws -> AIClassifyResponse {
        guard let url = URL(string: networkManager.baseURLString + "/ai-predict") else {
            print("❌ Invalid URL: \(networkManager.baseURLString)/ai-predict")
            throw NetworkError.invalidURL
        }
        
        print("📡 Request URL: \(url)")
        print("📦 Image size: \(imageData.count) bytes")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // 이미지 파일 추가
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"waste.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        print("📤 Sending request...")
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Invalid response type")
            throw NetworkError.invalidResponse
        }
        
        print("📥 Response status: \(httpResponse.statusCode)")
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("📄 Response body: \(responseString)")
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            print("❌ HTTP Error: \(httpResponse.statusCode)")
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        let result = try decoder.decode(AIClassifyResponse.self, from: data)
        print("✅ Decoded successfully")
        return result
    }
    
    // MARK: - ✅ 폐기물 등록 (상세 정보 포함)
    static func registerWasteDetail(request: RegisterWasteDetailRequest, token: String) async throws -> DisposalDetail {
        return try await networkManager.request(
            endpoint: "/disposals",
            method: "POST",
            body: request,
            token: token
        )
    }
    
    // MARK: - ✅ 폐기물 정보 수정 (부분 수정 지원)
    static func updateWasteDetail(disposalItemId: Int, request: UpdateWasteDetailRequest, token: String) async throws -> DisposalDetail {
        return try await networkManager.request(
            endpoint: "/disposals/\(disposalItemId)",
            method: "PATCH",
            body: request,
            token: token
        )
    }
    
    // MARK: - ✅ 폐기물 카테고리 목록 조회
    static func fetchWasteCategories(token: String) async throws -> [WasteCategory] {
        return try await networkManager.request(
            endpoint: "/waste-categories",
            method: "GET",
            token: token
        )
    }
    
    // MARK: - ✅ 특정 카테고리의 폐기물 타입 조회
    static func fetchWasteTypes(categoryName: String, token: String) async throws -> [WasteType] {
        return try await networkManager.request(
            endpoint: "/waste-categories/\(categoryName)/types",
            method: "GET",
            token: token
        )
    }
    
    // MARK: - ✅ 폐기물 목록 조회 (상태별 필터링)
    static func fetchDisposalItems(labId: Int? = nil, status: DisposalStatus? = nil, token: String) async throws -> DisposalListResponse {
        var endpoint = "/disposals"
        var queryParams: [String] = []
        
        if let labId = labId {
            queryParams.append("labId=\(labId)")
        }
        
        if let status = status {
            queryParams.append("status=\(status.rawValue)")
        }
        
        if !queryParams.isEmpty {
            endpoint += "?" + queryParams.joined(separator: "&")
        }
        
        print("📡 Fetching disposals: \(endpoint)")
        
        return try await networkManager.request(
            endpoint: endpoint,
            method: "GET",
            token: token
        )
    }
    
    // MARK: - ✅ 특정 폐기물 상세 조회
    static func fetchDisposalDetail(disposalItemId: Int, token: String) async throws -> DisposalDetail {
        return try await networkManager.request(
            endpoint: "/disposals/\(disposalItemId)",
            method: "GET",
            token: token
        )
    }
    
    // MARK: - 폐기물 삭제
    // TODO: API 개발 대기 중
    static func deleteWaste(wasteId: Int, token: String) async throws {
        // API 개발 대기
        throw NetworkError.notImplemented
    }
}

// MARK: - Network Error Extension
extension NetworkError {
    static let notImplemented = NetworkError.invalidResponse
}
