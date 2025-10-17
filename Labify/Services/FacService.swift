//
//  FacService.swift
//  Labify
//
//  Created by KITS on 10/15/25.
//

import Foundation

//// MARK: - Models
////struct Lab: Identifiable, Codable {
////    let id: Int
////    let name: String
////    let location: String
////    let facilityId: Int
////    
////    enum CodingKeys: String, CodingKey {
////        case id = "labId"
////        case name, location, facilityId
////    }
////}
//
//struct LabRequest: Identifiable, Codable {
//    let id: Int
//    let labName: String
//    let location: String
//    let requesterName: String
//    let requesterEmail: String
//    let status: String
//    let createdAt: String
//    
//    enum CodingKeys: String, CodingKey {
//        case id = "requestId"
//        case labName, location, requesterName, requesterEmail, status, createdAt
//    }
//}
//
//struct RegisterLabRequest: Codable {
//    let name: String
//    let location: String
//    let facilityId: Int
//}
//
//struct UpdateLabRequest: Codable {
//    let name: String
//    let location: String
//}
//
//struct LabRequestResponse: Codable {
//    let requestId: Int
//    let status: String
//}
//
//struct Facility: Identifiable, Codable {
//    let id: Int
//    let name: String
//    let type: String
//    let address: String
//    let facilityCode: String
//    
//    enum CodingKeys: String, CodingKey {
//        case id = "facilityId"
//        case name, type, address, facilityCode
//    }
//}
//
//struct RegisterFacilityRequest: Codable {
//    let name: String
//    let type: String
//    let address: String
//    let managerId: Int
//}

// MARK: - Service
struct FacService {
    
    static let networkManager = NetworkManager.shared
    
    // MARK: - 실험실 목록 조회
    static func fetchLabs(token: String) async throws -> [Lab] {
        let response: [Lab] = try await networkManager.request(
            endpoint: "/labs",
            method: "GET",
            token: token
        )
        return response
    }
    
    // MARK: - 실험실 등록
    static func registerLab(request: RegisterLabRequest, token: String) async throws -> Lab {
        let response: Lab = try await networkManager.request(
            endpoint: "/labs/register",
            method: "POST",
            body: request,
            token: token
        )
        return response
    }
    
    // MARK: - 실험실 정보 수정
    static func updateLab(labId: Int, request: UpdateLabRequest, token: String) async throws -> Lab {
        let response: Lab = try await networkManager.request(
            endpoint: "/labs/\(labId)",
            method: "PATCH",
            body: request,
            token: token
        )
        return response
    }
    
    // MARK: - 실험실 개설 요청 목록 조회
    static func fetchLabRequests(token: String) async throws -> [LabRequest] {
        let response: [LabRequest] = try await networkManager.request(
            endpoint: "/labs/requests",
            method: "GET",
            token: token
        )
        return response
    }
    
    // MARK: - 실험실 개설 요청 승인
    static func confirmLabRequest(requestId: Int, token: String) async throws -> Lab {
        let response: Lab = try await networkManager.request(
            endpoint: "/labs/requests/\(requestId)/confirm",
            method: "PATCH",
            token: token
        )
        return response
    }
    
    // MARK: - 실험실 개설 요청 거절
    static func rejectLabRequest(requestId: Int, token: String) async throws -> LabRequestResponse {
        let response: LabRequestResponse = try await networkManager.request(
            endpoint: "/labs/requests/\(requestId)/reject",
            method: "PATCH",
            token: token
        )
        return response
    }
    
    // MARK: - 시설 등록
    static func registerFacility(request: RegisterFacilityRequest, token: String) async throws -> Facility {
        let response: Facility = try await networkManager.request(
            endpoint: "/facilities/register",
            method: "POST",
            body: request,
            token: token
        )
        return response
    }
    
    // MARK: - 시설 목록 조회
    static func fetchFacilities(token: String) async throws -> [Facility] {
        let response: [Facility] = try await networkManager.request(
            endpoint: "/facilities",
            method: "GET",
            token: token
        )
        return response
    }
}
