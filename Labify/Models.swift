//
//  Models.swift
//  Labify
//
//  Created by F_S on 10/15/25.
//

import Foundation

// MARK: - ========== USER MODELS ==========

struct UserInfo: Codable {
    let userId: Int
    let name: String
    let email: String
    let role: String
    //let affiliation: String?
    
    enum CodingKeys: String, CodingKey {
        case userId, name, email, role
    }
    
    // ✅ 일반 이니셜라이저 추가
    init(userId: Int, name: String, email: String, role: String) {
        self.userId = userId
        self.name = name
        self.email = email
        self.role = role
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userId = try container.decode(Int.self, forKey: .userId)
        name = try container.decode(String.self, forKey: .name)
        email = try container.decode(String.self, forKey: .email)
        role = try container.decode(String.self, forKey: .role)
        //affiliation = try container.decodeIfPresent(String.self, forKey: .affiliation)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try container.encode(name, forKey: .name)
        try container.encode(email, forKey: .email)
        try container.encode(role, forKey: .role)
        //try container.encodeIfPresent(affiliation, forKey: .affiliation)
    }
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

// MARK: - ========== WASTE CATEGORY & TYPE MODELS ==========

// 폐기물 카테고리 (coarse)
struct WasteCategory: Identifiable, Codable {
    let id: Int
    let name: String
    let description: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "categoryId"
        case name
        case description
    }
}

// 폐기물 타입 (fine)
struct WasteType: Identifiable, Codable {
    let id: Int
    let name: String
    let categoryId: Int?
    let categoryName: String?
    let unit: String
    let description: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "typeId"
        case name
        case categoryId
        case categoryName
        case unit
        case description
    }
}

// 단위 목록
enum WasteUnit: String, CaseIterable, Identifiable {
    case kg = "kg"
    case g = "g"           // ✅ 추가
    case liter = "L"
    case mL = "mL"         // ✅ 추가
    case piece = "piece"
    
    var id: String { rawValue }
}

// AI 분류 응답
struct AIClassifyResponse: Codable {
    let coarse: String
    let fine: String
    let unit: String?
    let is_bio: Bool
    let is_ocr: Bool
    let ocr_text: String?
}

// 폐기물 등록 요청
struct RegisterWasteDetailRequest: Codable {
    let labId: Int
    let wasteTypeName: String
    let weight: Double
    let unit: String
    let memo: String?
    let availableUntil: String
}

// 폐기물 등록 응답
struct DisposalDetail: Codable {
    let id: Int
    let labName: String
    let wasteTypeName: String
    let weight: Double
    let unit: String
    let memo: String?
    let status: String
    let createdAt: String
    let availableUntil: String?
}

// 폐기물 목록 조회 응답
struct DisposalListResponse: Codable {
    let totalCount: Int
    let disposalItems: [DisposalItemData]
}

// 폐기물 목록의 개별 아이템 (Waste로 사용)
struct DisposalItemData: Identifiable, Codable {
    let id: Int
    let labName: String
    let wasteTypeName: String
    let weight: Double
    let unit: String
    let memo: String?
    let status: String
    let createdAt: String
    let availableUntil: String?
    
    // UI용 computed properties
    var name: String { wasteTypeName }
    var labId: Int { 0 } // TODO: API 응답에 labId가 없으면 임시값
}

// PickupRequestView에서 사용하는 Waste 타입
typealias Waste = DisposalItemData

// MARK: - ========== PICKUP REQUEST MODELS (수거 요청) ==========

// 수거 요청 생성 Request
struct CreatePickupRequest: Codable {
    let labId: Int
    let requesterId: Int
    let requestDate: String  // "2025-10-24T10:00:00"
    let disposalItemIds: [Int]
}

// 수거 요청 생성 Response
struct CreatePickupResponse: Codable {
    let pickupRequestId: Int
    let labId: Int
    let labName: String
    let pickupId: Int
    let collectorId: Int
    let collectorName: String
    let status: String
    let requestDate: String  // "2025-10-24"
    let createdAt: String
}

// 수거 요청 취소 Response
struct CancelPickupResponse: Codable {
    let pickupRequestId: Int
    let labId: Int
    let requestDate: String
    let status: String
}

// 수거 요청 목록 아이템
struct PickupRequestItem: Identifiable, Codable {
    var id: Int { requestId }
    let requestId: Int
    let requestDate: String
    let status: String
    let disposalItems: [PickupDisposalItem]
    
    // UI용 computed properties
    var displayStatus: String {
        switch status {
        case "REQUESTED": return "요청됨"
        case "SCHEDULED": return "수거 예정"
        case "COMPLETED": return "완료"
        case "CANCELED": return "취소"
        default: return status
        }
    }
    
    var statusColor: String {
        switch status {
        case "REQUESTED": return "orange"
        case "SCHEDULED": return "blue"
        case "COMPLETED": return "green"
        case "CANCELED": return "gray"
        default: return "gray"
        }
    }
    
    var totalWeight: Double {
        disposalItems.reduce(0) { $0 + $1.weight }
    }
    
    var itemCount: Int {
        disposalItems.count
    }
}

// 수거 요청 상세 조회 Response
struct PickupRequestDetail: Codable {
    let requestId: Int
    let requestDate: String
    let status: String
    let disposalItems: [PickupDisposalItem]
    
    var displayStatus: String {
        switch status {
        case "REQUESTED": return "요청됨"
        case "SCHEDULED": return "수거 예정"
        case "COMPLETED": return "완료"
        case "CANCELED": return "취소"
        default: return status
        }
    }
    
    var statusColor: String {
        switch status {
        case "REQUESTED": return "orange"
        case "SCHEDULED": return "blue"
        case "COMPLETED": return "green"
        case "CANCELED": return "gray"
        default: return "gray"
        }
    }
    
    var totalWeight: Double {
        disposalItems.reduce(0) { $0 + $1.weight }
    }
}

// 수거 요청의 폐기물 아이템
struct PickupDisposalItem: Identifiable, Codable {
    var id: Int { disposalId }
    let disposalId: Int
    let wasteTypeName: String
    let weight: Double
    let unit: String
}

// 수거 요청 상태 필터
enum PickupRequestStatus: String, CaseIterable {
    case all = "전체"
    case requested = "REQUESTED"
    case scheduled = "SCHEDULED"
    case completed = "COMPLETED"
    case canceled = "CANCELED"
    
    var displayName: String {
        switch self {
        case .all: return "전체"
        case .requested: return "요청됨"
        case .scheduled: return "수거 예정"
        case .completed: return "완료"
        case .canceled: return "취소"
        }
    }
    
    var apiValue: String? {
        self == .all ? nil : rawValue
    }
}

// MARK: - ========== PICKUP MODELS (기존 - 수거업체용) ==========

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

// 기존 DisposalItem (수거업체용)
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
