//
//  FacService.swift
//  Labify
//
//  Created by KITS on 10/15/25.
//

import Foundation

enum FacService {
    static let networkManager = NetworkManager.shared
    
    // MARK: - 시설 관련 API
    
    static func registerFacility(request: RegisterFacilityRequest, token: String) async throws -> Facility {
        let response: Facility = try await networkManager.request(
            endpoint: "/facilities/register",
            method: "POST",
            body: request,
            token: token
        )
        return response
    }
    
    static func fetchFacilities(token: String) async throws -> Facility {
        let response: Facility = try await networkManager.request(
            endpoint: "/facilities",
            method: "GET",
            token: token
        )
        return response
    }
    
    // MARK: - 실험실 관련 API
    
    static func fetchLabs(token: String) async throws -> [Lab] {
        let response: [Lab] = try await networkManager.request(
            endpoint: "/labs",
            method: "GET",
            token: token
        )
        return response
    }
    
    static func registerLab(request: RegisterLabRequest, token: String) async throws -> Lab {
        let response: Lab = try await networkManager.request(
            endpoint: "/labs/register",
            method: "POST",
            body: request,
            token: token
        )
        return response
    }
    
    static func updateLab(labId: Int, request: UpdateLabRequest, token: String) async throws -> Lab {
        let response: Lab = try await networkManager.request(
            endpoint: "/labs/\(labId)",
            method: "PATCH",
            body: request,
            token: token
        )
        return response
    }
    
    // ✅ 실험실 개설 요청 목록 조회 (status 파라미터 추가)
    static func fetchLabRequests(status: String, token: String) async throws -> LabRequestsResponse {
        let response: LabRequestsResponse = try await networkManager.request(
            endpoint: "/labs/requests/\(status)",
            method: "GET",
            token: token
        )
        return response
    }
    
    // ✅ 실험실 개설 요청 승인 (응답 타입 변경)
    static func confirmLabRequest(requestId: Int, token: String) async throws -> LabConfirmResponse {
        let response: LabConfirmResponse = try await networkManager.request(
            endpoint: "/labs/requests/\(requestId)/confirm",
            method: "PATCH",
            token: token
        )
        return response
    }
    
    // ✅ 실험실 개설 요청 거절
    static func rejectLabRequest(requestId: Int, token: String) async throws -> LabRequestResponse {
        let response: LabRequestResponse = try await networkManager.request(
            endpoint: "/labs/requests/\(requestId)/reject",
            method: "PATCH",
            token: token
        )
        return response
    }
    
    // MARK: - 시설 가입 요청 관련 API

//    static func fetchFacilityJoinRequests(token: String) async throws -> [FacilityJoinRequestItem] {
//            let response: [FacilityJoinRequestItem] = try await networkManager.request(
//                endpoint: "/facilities/requests",
//                method: "GET",
//                token: token
//            )
//            return response
//        }
//
//        static func requestFacilityJoin(
//            userId: Int,
//            facilityCode: String,
//            token: String
//        ) async throws -> FacilityJoinRequestResponse {
//            let request = FacilityJoinRequest(
//                userId: userId,
//                facilityCode: facilityCode
//            )
//            return try await networkManager.request(
//                endpoint: "/facilities/requests",
//                method: "POST",
//                body: request,
//                token: token
//            )
//        }
//    
    // ✅ 시설 가입 요청 목록 조회 (status 파라미터 추가)
    static func fetchFacilityJoinRequests(status: String, token: String) async throws -> FacilityJoinRequestsResponse {
        let response: FacilityJoinRequestsResponse = try await networkManager.request(
            endpoint: "/facilities/requests/\(status)",
            method: "GET",
            token: token
        )
        return response
    }
    
    static func requestFacilityJoin(
        userId: Int,
        facilityCode: String,
        token: String
    ) async throws -> FacilityJoinRequestsResponse {
        let request = FacilityJoinRequest(
            userId: userId,
            facilityCode: facilityCode
        )
        return try await networkManager.request(
            endpoint: "/facilities/requests",
            method: "POST",
            body: request,
            token: token
        )
    }
    
    // ✅ 시설 가입 요청 승인 (응답 타입 변경)
    static func confirmFacilityJoinRequest(requestId: Int, token: String) async throws -> FacilityJoinConfirmResponse {
        let response: FacilityJoinConfirmResponse = try await networkManager.request(
            endpoint: "/facilities/requests/\(requestId)/confirm",
            method: "PATCH",
            token: token
        )
        return response
    }
    
    // ✅ 시설 가입 요청 거절
    static func rejectFacilityJoinRequest(requestId: Int, token: String) async throws -> FacilityJoinRejectResponse {
        let response: FacilityJoinRejectResponse = try await networkManager.request(
            endpoint: "/facilities/requests/\(requestId)/reject",
            method: "PATCH",
            token: token
        )
        return response
    }
    
    // MARK: - 연구소-수거업체 관계 API
    
    static func createFacilityRelation(request: CreateRelationRequest, token: String) async throws -> RelationResponse {
        let response: RelationResponse = try await networkManager.request(
            endpoint: "/relation",
            method: "POST",
            body: request,
            token: token
        )
        return response
    }
    
    static func deleteFacilityRelation(relationshipId: Int, token: String) async throws {
        let _: EmptyResponse = try await networkManager.request(
            endpoint: "/relation/delete/\(relationshipId)",
            method: "DELETE",
            token: token
        )
    }
    
    // MARK: - 시설 코드로 조회
    static func searchFacilityByCode(facilityCode: String, token: String) async throws -> Facility {
        let response: Facility = try await networkManager.request(
            endpoint: "/facilities/\(facilityCode)",
            method: "GET",
            token: token
        )
        return response
    }
}
