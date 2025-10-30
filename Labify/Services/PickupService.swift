//
//  PickupService.swift
//  Labify
//
//  Created by F_S on 10/29/25.
//

import Foundation

struct PickupService {
    static let networkManager = NetworkManager.shared
    
    // MARK: - ✅ QR 스캔 처리 (수거 완료) - 문자열 방식
    /// POST /pickups/scan
    /// Body: { "code": "QRCODE_SCAN_TEST" }
    /// Response: { "disposalId": 201, "status": "PICKED_UP", "processedAt": "2025-10-18T16:54:30.1477808" }
    static func scanQRCode(
        code: String,
        token: String
    ) async throws -> QRScanResponse {
        let request = QRScanRequest(code: code)
        return try await networkManager.request(
            endpoint: "/pickups/scan",
            method: "POST",
            body: request,
            token: token
        )
    }
    
    // MARK: - ✅ QR 스캔 처리 (수거 완료) - 이미지 업로드 방식
    /// POST /pickups/scan
    /// Body: multipart/form-data with "file" (QR 이미지)
    /// Response: { "disposalId": 201, "status": "PICKED_UP", "processedAt": "2025-10-18T16:54:30.1477808" }
    static func scanQRCode(
        imageData: Data,
        token: String
    ) async throws -> QRScanResponse {
        guard let url = URL(string: networkManager.baseURLString + "/pickups/scan") else {
            print("❌ Invalid URL: \(networkManager.baseURLString)/pickups/scan")
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
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"qr_scan.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        print("📤 Sending QR scan request...")
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
        let result = try decoder.decode(QRScanResponse.self, from: data)
        print("✅ QR scan successful: disposalId=\(result.disposalId)")
        return result
    }
    
    // MARK: - ✅ 오늘 진행 현황
    /// GET /pickups/today
    /// Response: [{ "pickupId": 3, "labName": "분자생물학 연구실", "labLocation": "A동 101호",
    ///             "facilityAddress": "서울특별시 강남구 테헤란로 427", "status": "REQUESTED" }]
    static func fetchTodayPickups(token: String) async throws -> [TodayPickupItem] {
        return try await networkManager.request(
            endpoint: "/pickups/today",
            method: "GET",
            token: token
        )
    }
    
    // MARK: - ✅ 오늘 진행 현황 업데이트
    /// PATCH /pickups/{pickupId}/status
    /// Body: { "status": "COMPLETED" }
    static func updatePickupStatus(
        pickupId: Int,
        status: String,
        token: String
    ) async throws {
        let request = UpdatePickupStatusRequest(status: status)
        let _: EmptyResponse = try await networkManager.request(
            endpoint: "/pickups/\(pickupId)/status",
            method: "PATCH",
            body: request,
            token: token
        )
    }
    
    // MARK: - ✅ 내일 수거 예정 목록 조회
    /// GET /pickups/tomorrow
    /// Response: [{ "pickupId": 5, "labName": "분자생물학 연구실", "labLocation": "A동 101호",
    ///             "facilityAddress": "서울특별시 강남구 테헤란로 427", "status": "REQUESTED" }]
    static func fetchTomorrowPickups(token: String) async throws -> [TomorrowPickupItem] {
        return try await networkManager.request(
            endpoint: "/pickups/tomorrow",
            method: "GET",
            token: token
        )
    }
    
    // MARK: - ⚠️ 내일 수거 목록 지역별 보기 (아직 미구현)
    /// GET /pickups/tomorrow?region={region}
    /// TODO: 백엔드 API 개발 대기 중
    static func fetchTomorrowPickups(region: String, token: String) async throws -> [TomorrowPickupItem] {
        print("⚠️ TODO: 지역별 내일 수거 목록 API 개발 대기 중")
        // 임시로 전체 목록 반환
        return try await fetchTomorrowPickups(token: token)
    }
    
    // MARK: - ✅ 내 처리 이력 전체 조회
    /// GET /pickups
    /// Response: [{ "pickupId": 4, "labName": "분자생물학 연구실", "labLocation": "A동 101호",
    ///             "facilityAddress": "서울특별시 강남구 테헤란로 427", "status": "COMPLETED" }]
    static func fetchPickupHistory(token: String) async throws -> [PickupHistoryItem] {
        return try await networkManager.request(
            endpoint: "/pickups",
            method: "GET",
            token: token
        )
    }
}
