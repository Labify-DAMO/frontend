//
//  FacilityModels.swift
//  Labify
//
//  Created by F_S on 10/30/25.
//

import Foundation

// MARK: - 시설 등록 관련

struct RegisterFacilityRequest: Codable {
    let name: String
    let type: String
    let address: String
}

struct Facility: Identifiable, Codable {
    let id: Int
    let name: String
    let type: String
    let address: String
    let facilityCode: String
    
    enum CodingKeys: String, CodingKey {
        case id = "facilityId"
        case name, type, address, facilityCode
    }
}

enum FacilityType: String, Codable, CaseIterable {
    case etc = "ETC"
    case lab = "LAB"
    case pickup = "PICKUP"
    
    var displayName: String {
        switch self {
        case .etc: return "기타"
        case .lab: return "연구소"
        case .pickup: return "수거업체"
        }
    }
}

// MARK: - 시설 가입 요청 관련

struct FacilityJoinRequest: Codable {
    let userId: Int
    let facilityCode: String
}

// ✅ 시설 가입 요청 생성 응답 (단일 객체)
struct FacilityJoinRequestResponse: Codable {
    let requestId: Int
    let status: String
}

// ✅ 시설 가입 요청 목록 조회 응답 (배열)
struct FacilityJoinRequestsResponse: Codable {
    let requests: [FacilityJoinRequestItem]
    let count: Int
}

struct FacilityJoinRequestItem: Identifiable, Codable {
    let id: Int
    let userName: String
    let createdAt: String
    let status: String
}

// MARK: - 시설 가입 승인/거절 응답

struct FacilityJoinConfirmResponse: Codable {
    let userId: Int
    let requestId: Int
    let status: String
    let facilityId: Int
    let facilityName: String
}

struct FacilityJoinRejectResponse: Codable {
    let requestId: Int
    let status: String
}

// MARK: - 시설 관계(Relation) 관련

struct CreateRelationRequest: Codable {
    let labFacilityId: Int
    let pickupFacilityId: Int
}

struct RelationResponse: Codable {
    let relationshipId: Int
    let labFacilityId: Int
    let pickupFacilityId: Int
}

// MARK: - 시설 등록 응답

struct FacilityRegistrationResponse: Codable {
    let facilityId: Int
    let name: String
    let type: String
    let address: String
    let facilityCode: String
}

// MARK: - 시설 관계 정보

struct FacilityRelation: Identifiable, Codable {
    let id: Int
    let facilityId: Int
    let pickupCompanyId: Int
    let pickupCompanyName: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "relationId"
        case facilityId, pickupCompanyId, pickupCompanyName, createdAt
    }
}

// MARK: - KPI 통계 관련

struct KPIStatistics: Codable {
    let totalDisposals: Int
    let completedDisposals: Int
    let pendingDisposals: Int
    let processingRate: Double
    let monthlyTrend: [MonthlyData]
    
    var completionPercentage: Double {
        guard totalDisposals > 0 else { return 0 }
        return Double(completedDisposals) / Double(totalDisposals) * 100
    }
}

struct MonthlyData: Codable {
    let month: String
    let total: Int
    let completed: Int
}
