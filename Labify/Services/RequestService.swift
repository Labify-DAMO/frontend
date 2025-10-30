//
//  RequestService.swift
//  Labify
//
//  Created by F_S on 10/30/25.
//

import Foundation

// MARK: - Request Service
struct RequestService {
    static let networkManager = NetworkManager.shared
    
    // MARK: - ✅ 수거 요청 생성
    /// 새로운 수거 요청을 생성합니다.
    /// - Parameters:
    ///   - labId: 연구실 ID
    ///   - requestDate: 수거 요청 날짜 (ISO 8601 format: "2025-10-24T10:00:00")
    ///   - disposalItemIds: 수거할 폐기물 ID 배열
    ///   - token: 사용자 인증 토큰
    /// - Returns: 생성된 수거 요청 정보
    static func createRequest(
        labId: Int,
        requestDate: String,
        disposalItemIds: [Int],
        token: String
    ) async throws -> CreateRequestResponse {
        let request = CreateRequestRequest(
            labId: labId,
            requestDate: requestDate,
            disposalItemIds: disposalItemIds
        )
        
        print("📦 수거 요청 생성:")
        print("- Lab ID: \(labId)")
        print("- Request Date: \(requestDate)")
        print("- Disposal Items: \(disposalItemIds)")
        
        return try await networkManager.request(
            endpoint: "/pickup-requests/requests",
            method: "POST",
            body: request,
            token: token
        )
    }
    
    // MARK: - ✅ 수거 요청 취소
    /// 특정 수거 요청을 취소합니다.
    /// - Parameters:
    ///   - requestId: 취소할 수거 요청 ID (pickupId)
    ///   - token: 사용자 인증 토큰
    /// - Returns: 취소된 수거 요청 정보
    static func cancelRequest(
        requestId: Int,
        token: String
    ) async throws -> CancelRequestResponse {
        print("🚫 수거 요청 취소: ID=\(requestId)")
        
        return try await networkManager.request(
            endpoint: "/pickup-requests/\(requestId)/cancel",
            method: "PATCH",
            token: token
        )
    }
    
    // MARK: - ✅ 수거 요청 목록 조회 (전체)
    /// 내 모든 수거 요청을 조회합니다.
    /// - Parameter token: 사용자 인증 토큰
    /// - Returns: 수거 요청 목록
    static func fetchRequests(token: String) async throws -> [Request] {
        print("📋 수거 요청 목록 조회 (전체)")
        
        return try await networkManager.request(
            endpoint: "/pickup-requests",
            method: "GET",
            token: token
        )
    }
    
    // MARK: - ✅ 수거 요청 목록 조회 (상태별 필터링)
    /// 특정 상태의 수거 요청을 조회합니다.
    /// - Parameters:
    ///   - status: 필터링할 상태
    ///   - token: 사용자 인증 토큰
    /// - Returns: 필터링된 수거 요청 목록
    static func fetchRequests(
        status: RequestStatus,
        token: String
    ) async throws -> [Request] {
        let endpoint = "/pickup-requests?status=\(status.rawValue)"
        print("📋 수거 요청 목록 조회 (필터: \(status.displayName))")
        
        return try await networkManager.request(
            endpoint: endpoint,
            method: "GET",
            token: token
        )
    }
    
    // MARK: - ✅ 수거 요청 상세 조회
    /// 특정 수거 요청의 상세 정보를 조회합니다.
    /// - Parameters:
    ///   - requestId: 조회할 수거 요청 ID
    ///   - token: 사용자 인증 토큰
    /// - Returns: 수거 요청 상세 정보
    static func fetchRequestDetail(
        requestId: Int,
        token: String
    ) async throws -> RequestDetail {
        print("📄 수거 요청 상세 조회: ID=\(requestId)")
        
        return try await networkManager.request(
            endpoint: "/pickup-requests/\(requestId)",
            method: "GET",
            token: token
        )
    }
}

// MARK: - Helper Extensions

extension RequestService {
    /// Date를 ISO 8601 문자열로 변환
    static func formatRequestDate(_ date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: date)
    }
    
    /// Date를 간단한 날짜 문자열로 변환 (yyyy-MM-dd)
    static func formatSimpleDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
