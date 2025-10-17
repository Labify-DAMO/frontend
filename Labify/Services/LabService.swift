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
    
    // MARK: - 실험실 목록 조회 (모든 역할)
    // TODO: API 개발 대기 중
    static func fetchLabs(token: String) async throws -> [Lab] {
        // return try await networkManager.request(
        //     endpoint: "/labs",
        //     method: "GET",
        //     token: token
        // )
        
        // 임시 목 데이터
        return []
    }
    
    // MARK: - 내 실험실/부서 조회 (LAB)
    // TODO: API 개발 대기 중
    static func fetchMyLab(token: String) async throws -> Lab? {
        // return try await networkManager.request(
        //     endpoint: "/labs/my",
        //     method: "GET",
        //     token: token
        // )
        
        // 임시 목 데이터
        return nil
    }
    
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
}

// MARK: - Request/Response Models
//
//// ✅ 실험실 개설 요청 (LAB)
//struct LabCreationRequest: Codable {
//    let facilityId: Int
//    let name: String
//    let location: String
//    let managerId: Int
//}
//
//struct LabCreationRequestResponse: Codable {
//    let requestId: Int
//    let status: String
//}
//
//// ✅ 실험실 등록 (FAC)
//struct RegisterLabRequest: Codable {
//    let name: String
//    let location: String
//    let facilityId: Int
//}
//
//// ✅ 실험실 수정 (FAC)
//struct UpdateLabRequest: Codable {
//    let name: String
//    let location: String
//}
//
//// ✅ 실험실 모델
//struct Lab: Identifiable, Codable {
//    let id: Int
//    let name: String
//    let location: String
//    let facilityId: Int
//    
//    enum CodingKeys: String, CodingKey {
//        case id = "labId"
//        case name
//        case location
//        case facilityId
//    }
//}
//
//// ✅ 실험실 개설 요청 모델
//struct LabRequest: Identifiable, Codable {
//    let id: Int
//    let labName: String
//    let location: String
//    let requesterName: String
//    let createdAt: String
//    
//    enum CodingKeys: String, CodingKey {
//        case id = "requestId"
//        case labName
//        case location
//        case requesterName
//        case createdAt
//    }
//}
//
//// ✅ 실험실 요청 응답
//struct LabRequestResponse: Codable {
//    let requestId: Int
//    let status: String
//}
