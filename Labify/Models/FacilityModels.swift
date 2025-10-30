//
//  FacilityModels.swift
//  Labify
//
//  Created by KITS on 10/30/25.
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
    let relationId: Int
    let userId: Int
    let facilityId: Int
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
