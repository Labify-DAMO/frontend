//
//  PickupService.swift
//  Labify
//
//  Created by F_S on 10/15/25.
//

import Foundation

// MARK: - Pickup Service
struct PickupService {
    static let networkManager = NetworkManager.shared
    
    // MARK: - ✅ QR 스캔 처리 (수거 완료)
    static func scanQRCode(
        qrCode: String,
        collectorId: Int,
        token: String
    ) async throws -> QRScanResponse {
        let request = QRScanRequest(
            qr_code: qrCode,
            collector_id: collectorId
        )
        return try await networkManager.request(
            endpoint: "/pickups/scan",
            method: "POST",
            body: request,
            token: token
        )
    }
    
    // MARK: - 오늘 진행 현황
    // TODO: API 개발 대기 중
    static func fetchTodayPickups(token: String) async throws -> [TodayPickupItem] {
        // return try await networkManager.request(
        //     endpoint: "/pickups/today",
        //     method: "GET",
        //     token: token
        // )
        
        // 임시 목 데이터
        return []
    }
    
    // MARK: - 오늘 진행 현황 업데이트
    // TODO: API 개발 대기 중
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
    
    // MARK: - 내일 수거 목록 전체 보기
    // TODO: API 개발 대기 중
    static func fetchTomorrowPickups(token: String) async throws -> [TomorrowPickupItem] {
        // return try await networkManager.request(
        //     endpoint: "/pickups/tomorrow",
        //     method: "GET",
        //     token: token
        // )
        
        // 임시 목 데이터
        return []
    }
    
    // MARK: - 내일 수거 목록 지역별 보기
    // TODO: API 개발 대기 중
    static func fetchTomorrowPickups(region: String, token: String) async throws -> [TomorrowPickupItem] {
        // return try await networkManager.request(
        //     endpoint: "/pickups/tomorrow?region=\(region)",
        //     method: "GET",
        //     token: token
        // )
        
        // 임시 목 데이터
        return []
    }
    
    // MARK: - 내 처리 이력
    // TODO: API 개발 대기 중
    static func fetchPickupHistory(token: String) async throws -> [PickupHistoryItem] {
        // return try await networkManager.request(
        //     endpoint: "/pickups",
        //     method: "GET",
        //     token: token
        // )
        
        // 임시 목 데이터
        return []
    }
}
