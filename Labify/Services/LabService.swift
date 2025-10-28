//
//  LabService.swift
//  Labify
//
//  Created by KITS on 10/15/25.
//

import Foundation

// MARK: - Lab Service
struct LabService {
    static let networkManager = NetworkManager.shared
    
    // MARK: - ✅ 실험실 개설 요청 (LAB → FAC)
    static func requestLabCreation(
        facilityId: Int,
        name: String,
        location: String,
        managerId: Int,
        token: String
    ) async throws -> LabCreationRequestResponse {
        let request = LabCreationRequest(
            facilityId: facilityId,
            name: name,
            location: location,
            managerId: managerId
        )
        return try await networkManager.request(
            endpoint: "/labs/requests",
            method: "POST",
            body: request,
            token: token
        )
    }
    
    // MARK: - ✅ 실험실 목록 조회 (모든 역할)
    static func fetchLabs(token: String) async throws -> [Lab] {
        return try await networkManager.request(
            endpoint: "/labs",
            method: "GET",
            token: token
        )
    }
    
    // MARK: - 내 실험실/부서 조회 (LAB)
    // TODO: API 개발 대기 중
//    static func fetchMyLab(token: String) async throws -> Lab? {
//        // return try await networkManager.request(
//        //     endpoint: "/labs/my",
//        //     method: "GET",
//        //     token: token
//        // )
//
//        // 임시 목 데이터
//        return nil
//    }
    
    // MARK: - ✅ 실험실 등록/개설 (FAC)
    static func registerLab(request: RegisterLabRequest, token: String) async throws -> Lab {
        return try await networkManager.request(
            endpoint: "/labs/register",
            method: "POST",
            body: request,
            token: token
        )
    }
    
    // MARK: - ✅ 실험실 수정 (FAC)
    static func updateLab(labId: Int, request: UpdateLabRequest, token: String) async throws -> Lab {
        return try await networkManager.request(
            endpoint: "/labs/\(labId)",
            method: "PATCH",
            body: request,
            token: token
        )
    }
    
    // MARK: - ✅ 실험실 개설 요청 목록 조회 (FAC)
    static func fetchLabRequests(token: String) async throws -> [LabRequest] {
        return try await networkManager.request(
            endpoint: "/labs/requests",
            method: "GET",
            token: token
        )
    }
    
    // MARK: - ✅ 실험실 개설 요청 승인 (FAC)
    static func confirmLabRequest(requestId: Int, token: String) async throws -> Lab {
        return try await networkManager.request(
            endpoint: "/labs/requests/\(requestId)/confirm",
            method: "PATCH",
            token: token
        )
    }
    
    // MARK: - ✅ 실험실 개설 요청 거절 (FAC)
    static func rejectLabRequest(requestId: Int, token: String) async throws -> LabRequestResponse {
        return try await networkManager.request(
            endpoint: "/labs/requests/\(requestId)/reject",
            method: "PATCH",
            token: token
        )
    }
    
    // MARK: - ========== 수거 요청 API ==========
    
    // MARK: - ✅ 수거 요청 생성
    static func createPickupRequest(
        labId: Int,
        requesterId: Int,
        requestDate: String,
        disposalItemIds: [Int],
        token: String
    ) async throws -> CreatePickupResponse {
        let request = CreatePickupRequest(
            labId: labId,
            requesterId: requesterId,
            requestDate: requestDate,
            disposalItemIds: disposalItemIds
        )
        return try await networkManager.request(
            endpoint: "/pickup-requests/requests",
            method: "POST",
            body: request,
            token: token
        )
    }
    
    // MARK: - ✅ 수거 요청 취소
    static func cancelPickupRequest(
        pickupRequestId: Int,
        token: String
    ) async throws -> CancelPickupResponse {
        return try await networkManager.request(
            endpoint: "/pickup-requests/\(pickupRequestId)/cancel",
            method: "PATCH",
            token: token
        )
    }
    
    // MARK: - ✅ 내 수거 요청 전체 조회
    static func fetchMyPickupRequests(token: String) async throws -> [PickupRequestItem] {
        return try await networkManager.request(
            endpoint: "/pickup-requests",
            method: "GET",
            token: token
        )
    }
    
    // MARK: - ✅ 내 수거 요청 상태별 필터링 조회
    static func fetchMyPickupRequestsByStatus(
        status: String,
        token: String
    ) async throws -> [PickupRequestItem] {
        return try await networkManager.request(
            endpoint: "/pickup-requests?status=\(status)",
            method: "GET",
            token: token
        )
    }
    
    // MARK: - ✅ 특정 수거 요청 상세 조회
    static func fetchPickupRequestDetail(
        pickupRequestId: Int,
        token: String
    ) async throws -> PickupRequestDetail {
        return try await networkManager.request(
            endpoint: "/pickup-requests/\(pickupRequestId)",
            method: "GET",
            token: token
        )
    }
}
