//
//  Models.swift
//  Labify
//
//  Created by F_S on 10/15/25.
//

import Foundation

// MARK: - ========== USER MODELS ==========

//struct UserInfo: Codable {
//    let userId: Int
//    let name: String
//    let email: String
//    let role: String
//    let affiliation: String
//}
//
//struct TokenResponse: Codable {
//    let accessToken: String
//    let refreshToken: String
//    
//    enum CodingKeys: String, CodingKey {
//        case accessToken = "access_token"
//        case refreshToken = "refresh_token" 
//    }
//}

// MARK: - ========== USER MODELS ==========

struct UserInfo: Codable {
    let userId: Int
    let name: String
    let email: String
    let role: String
    let affiliation: String
}

struct TokenResponse: Codable {
    let accessToken: String
    let refreshToken: String
}

// MARK: - ========== LAB MODELS ==========

struct Lab: Identifiable, Codable {
    let id: Int
    let name: String
    let location: String
    let facilityId: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "labId"
        case name
        case location
        case facilityId
    }
}

struct LabRequest: Identifiable, Codable {
    let id: Int
    let labName: String
    let location: String
    let requesterName: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "requestId"
        case labName
        case location
        case requesterName
        case createdAt
    }
}

// Lab Request/Response DTOs
struct LabCreationRequest: Codable {
    let facilityId: Int
    let name: String
    let location: String
    let managerId: Int
}

struct LabCreationRequestResponse: Codable {
    let requestId: Int
    let status: String
}

struct RegisterLabRequest: Codable {
    let name: String
    let location: String
    let facilityId: Int
}

struct UpdateLabRequest: Codable {
    let name: String
    let location: String
}

struct LabRequestResponse: Codable {
    let requestId: Int
    let status: String
}

// MARK: - ========== WASTE MODELS ==========

struct Waste: Identifiable, Codable {
    let id: Int
    let name: String
    let weight: Double
    let unit: String
    let labId: Int
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id = "wasteId"
        case name
        case weight
        case unit
        case labId
        case status
    }
}

// AI 분류 응답
struct AIClassifyResponse: Codable {
    let coarse: String
    let fine: String
    let is_bio: Bool
    let is_ocr: Bool
    let ocr_text: String?
    
    var displayCoarse: String {
        switch coarse {
        case "sharps": return "날카로운 물체"
        case "chemicals": return "화학 물질"
        case "biological": return "생물학적 폐기물"
        default: return coarse
        }
    }
    
    var displayFine: String {
        switch fine {
        case "syringe": return "주사기"
        case "needle": return "주사바늘"
        case "gloves": return "장갑"
        default: return fine
        }
    }
}

// 폐기물 등록 요청
struct RegisterWasteRequest: Codable {
    let lab_id: Int
    let waste_type_id: Int
    let weight: Double
    let unit: String
    let memo: String?
    let created_by: Int
}

// 폐기물 등록 응답
struct DisposalResponse: Codable {
    let disposal_id: Int
    let qr_code_url: String
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case disposal_id
        case qr_code_url
        case status
    }
}

// MARK: - ========== PICKUP MODELS ==========

struct PickupRequest: Identifiable, Codable {
    let id: Int
    let labName: String
    let requestDate: String
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id = "requestId"
        case labName
        case requestDate
        case status
    }
}

// 수거 요청 상세 조회 응답
struct PickupRequestDetail: Codable {
    let requestId: Int
    let requestDate: String
    let status: String
    let disposalItems: [DisposalItem]
    
    var displayStatus: String {
        switch status {
        case "REQUESTED": return "요청됨"
        case "SCHEDULED": return "수거 예정"
        case "COMPLETED": return "수거 완료"
        case "CANCELLED": return "취소됨"
        default: return status
        }
    }
    
    var statusColor: String {
        switch status {
        case "REQUESTED": return "orange"
        case "SCHEDULED": return "blue"
        case "COMPLETED": return "green"
        case "CANCELLED": return "gray"
        default: return "gray"
        }
    }
}

struct DisposalItem: Identifiable, Codable {
    var id: Int { disposalId }
    let disposalId: Int
    let wasteTypeName: String
    let weight: Double
    let unit: String
}

// QR 스캔 요청
struct QRScanRequest: Codable {
    let qr_code: String
    let collector_id: Int
}

// QR 스캔 응답
struct QRScanResponse: Codable {
    let disposal_id: Int
    let status: String
    let processed_at: String
    
    enum CodingKeys: String, CodingKey {
        case disposal_id
        case status
        case processed_at
    }
}

// 오늘 진행 현황 아이템
struct TodayPickupItem: Identifiable, Codable {
    let id: Int
    let labName: String
    let location: String
    let scheduledTime: String
    let wasteCount: Int
    let totalWeight: Double
    let status: PickupItemStatus
    
    enum CodingKeys: String, CodingKey {
        case id = "pickupId"
        case labName
        case location
        case scheduledTime
        case wasteCount
        case totalWeight
        case status
    }
}

// 수거 상태
enum PickupItemStatus: String, Codable {
    case waiting = "WAITING"
    case inProgress = "IN_PROGRESS"
    case completed = "COMPLETED"
    
    var displayText: String {
        switch self {
        case .waiting: return "대기"
        case .inProgress: return "진행중"
        case .completed: return "완료"
        }
    }
    
    var color: String {
        switch self {
        case .waiting: return "gray"
        case .inProgress: return "black"
        case .completed: return "blue"
        }
    }
}

// 수거 상태 업데이트 요청
struct UpdatePickupStatusRequest: Codable {
    let status: String
}

// 내일 수거 목록 아이템
struct TomorrowPickupItem: Identifiable, Codable {
    let id: Int
    let labName: String
    let location: String
    let region: String
    let scheduledTime: String
    let wasteCount: Int
    let totalWeight: Double
    
    enum CodingKeys: String, CodingKey {
        case id = "pickupId"
        case labName
        case location
        case region
        case scheduledTime
        case wasteCount
        case totalWeight
    }
}

// 처리 이력 아이템
struct PickupHistoryItem: Identifiable, Codable {
    let id: Int
    let date: String
    let labName: String
    let location: String
    let wasteCount: Int
    let totalWeight: Double
    let collectorName: String
    let region: String
    
    enum CodingKeys: String, CodingKey {
        case id = "pickupId"
        case date = "processedAt"
        case labName
        case location
        case wasteCount
        case totalWeight
        case collectorName
        case region
    }
}

// MARK: - ========== FACILITY MODELS ==========

//struct Facility: Identifiable, Codable {
//    let id: Int
//    let name: String
//    let type: String
//    let address: String
//    let facilityCode: String
//    
//    enum CodingKeys: String, CodingKey {
//        case id = "facilityId"
//        case name
//        case type
//        case address
//        case facilityCode
//    }
//}

//// Models.swift (필요 시)
//struct RegisterFacilityRequest: Codable {
//    let name: String
//    let type: String   // "LAB" 등
//    let address: String
//    let managerId: Int
//}

struct Facility: Identifiable, Codable {
    let id: Int        // CodingKeys에서 facilityId 매핑
    let name: String
    let type: String
    let address: String
    let facilityCode: String

    enum CodingKeys: String, CodingKey {
        case id = "facilityId"
        case name, type, address, facilityCode
    }
}





// 시설 가입 요청
struct FacilityJoinRequest: Codable {
    let userId: Int
    let facilityCode: String
}

struct FacilityJoinRequestResponse: Codable {
    let requestId: Int
    let status: String
}

// 시설 등록
struct RegisterFacilityRequest: Codable {
    let name: String
    let type: String
    let address: String
    let managerId: Int
}

// 시설 가입 요청 목록 아이템
struct FacilityJoinRequestItem: Identifiable, Codable {
    let id: Int
    let userName: String
    let userEmail: String
    let facilityCode: String
    let requestedAt: String
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id = "requestId"
        case userName
        case userEmail
        case facilityCode
        case requestedAt
        case status
    }
}






// Models.swift에 추가할 모델들

import Foundation

// MARK: - 연구소-수거업체 관계 관련

struct CreateRelationRequest: Codable {
    let labFacilityId: Int
    let pickupFacilityId: Int
}

struct RelationResponse: Codable {
    let relationshipId: Int
    let labFacilityId: Int
    let pickupFacilityId: Int
}

// MARK: - 시설 가입 요청 관련

struct FacilityJoinConfirmResponse: Codable {
    let relationId: Int
    let userId: Int
    let facilityId: Int
}

struct FacilityJoinRejectResponse: Codable {
    let requestId: Int
    let status: String
}

// MARK: - 시설 등록 응답

struct FacilityRegistrationResponse: Codable {
    let facilityId: Int
    let name: String
    let type: String
    let address: String
    let facilityCode: String
}








// 연구소-수거업체 관계
struct FacilityRelation: Identifiable, Codable {
    let id: Int
    let facilityId: Int
    let pickupCompanyId: Int
    let pickupCompanyName: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "relationId"
        case facilityId
        case pickupCompanyId
        case pickupCompanyName
        case createdAt
    }
}

// KPI 통계
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

// MARK: - ========== COMMON ==========

struct EmptyResponse: Codable {}
