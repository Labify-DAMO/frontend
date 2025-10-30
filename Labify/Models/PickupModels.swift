//
//  PickupModels.swift
//  Labify
//
//  Created by F_S on 10/30/25.
//

import Foundation

struct CreatePickupRequest: Codable {
    let labId: Int
    let requesterId: Int
    let requestDate: String
    let disposalItemIds: [Int]
}

struct CreatePickupResponse: Codable {
    let pickupRequestId: Int
    let labId: Int
    let labName: String
    let pickupId: Int
    let collectorId: Int
    let collectorName: String
    let status: String
    let requestDate: String
    let createdAt: String
}

struct CancelPickupResponse: Codable {
    let pickupRequestId: Int
    let labId: Int
    let requestDate: String
    let status: String
}

struct PickupRequestItem: Identifiable, Codable {
    var id: Int { requestId }
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
    
    var totalWeight: Double {
        disposalItems.reduce(0) { $0 + $1.weight }
    }
}

struct PickupRequestDetail: Codable {
    let requestId: Int
    let requestDate: String
    let status: String
    let disposalItems: [PickupDisposalItem]
}

struct PickupDisposalItem: Identifiable, Codable {
    var id: Int { disposalId }
    let disposalId: Int
    let wasteTypeName: String
    let weight: Double
    let unit: String
}

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
}

struct QRScanRequest: Codable { let code: String }
struct QRScanResponse: Codable { let disposalId: Int; let status: String; let processedAt: String }

struct TodayPickupItem: Identifiable, Codable {
    let pickupId: Int
    let labName: String
    let labLocation: String
    let facilityAddress: String
    let status: String
    var id: Int { pickupId }
}

struct TomorrowPickupItem: Identifiable, Codable {
    let pickupId: Int
    let labName: String
    let labLocation: String
    let facilityAddress: String
    let status: String
    var id: Int { pickupId }
}

struct PickupHistoryItem: Identifiable, Codable {
    let pickupId: Int
    let labName: String
    let labLocation: String
    let facilityAddress: String
    let status: String
    
    var id: Int { pickupId }
    var name: String { "\(labName) · \(labLocation)" }
    var location: String { facilityAddress }
}

struct UpdatePickupStatusRequest: Codable {
    let status: String
}

//enum PickupItemStatus: String {
//    case requested = "REQUESTED"
//    case processing = "PROCESSING"
//    case completed = "COMPLETED"
//    case canceled = "CANCELED"
//}

enum PickupItemStatus: String, CaseIterable {
    case requested = "REQUESTED"
    case processing = "PROCESSING"
    case completed = "COMPLETED"
    case canceled = "CANCELED"
    
    var displayText: String {
        switch self {
        case .requested:
            return "요청됨"
        case .processing:
            return "수거 중"
        case .completed:
            return "완료"
        case .canceled:
            return "취소"
        }
    }
}
