//
//  RequestModels.swift
//  Labify
//
//  Created by F_S on 10/30/25.
//

import Foundation

// MARK: - Request Status Enum
enum RequestStatus: String, Codable, CaseIterable {
    case requested = "REQUESTED"      // 요청됨
    case scheduled = "SCHEDULED"      // 수거 예정됨
    case completed = "COMPLETED"      // 완료
    case canceled = "CANCELED"        // 취소
    
    var displayName: String {
        switch self {
        case .requested: return "요청됨"
        case .scheduled: return "수거 예정"
        case .completed: return "완료"
        case .canceled: return "취소됨"
        }
    }
    
    var color: String {
        switch self {
        case .requested: return "orange"
        case .scheduled: return "blue"
        case .completed: return "green"
        case .canceled: return "gray"
        }
    }
    
    var systemImage: String {
        switch self {
        case .requested: return "clock.fill"
        case .scheduled: return "calendar.badge.clock"
        case .completed: return "checkmark.circle.fill"
        case .canceled: return "xmark.circle.fill"
        }
    }
}

// MARK: - Request Models

/// 수거 요청 생성 Request
struct CreateRequestRequest: Codable {
    let labId: Int
    let requestDate: String           // ISO 8601 format: "2025-10-24T10:00:00"
    let disposalItemIds: [Int]
}

// MARK: - Response Models

/// 수거 요청 생성 Response
struct CreateRequestResponse: Codable {
    let pickupRequestId: Int
    let labId: Int
    let labName: String
    let pickupId: Int
    let collectorId: Int
    let collectorName: String
    let status: String
    let requestDate: String
    let createdAt: String
    
    var statusEnum: RequestStatus? {
        RequestStatus(rawValue: status)
    }
    
    var requestDateFormatted: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: requestDate)
    }
    
    var createdAtDate: Date? {
        ISO8601DateFormatter().date(from: createdAt)
    }
}

/// 수거 요청 취소 Response
struct CancelRequestResponse: Codable {
    let pickupRequestId: Int
    let labId: Int
    let requestDate: String
    let status: String
    
    var statusEnum: RequestStatus? {
        RequestStatus(rawValue: status)
    }
}

/// 수거 요청 목록의 폐기물 항목
struct RequestDisposalItem: Identifiable, Codable {
    let disposalId: Int
    let wasteTypeName: String
    let weight: Double
    let unit: String
    
    var id: Int { disposalId }
    
    var displayWeight: String {
        "\(weight) \(unit)"
    }
}

/// 수거 요청 항목
struct Request: Identifiable, Codable {
    let requestId: Int
    let requestDate: String
    let status: String
    let disposalItems: [RequestDisposalItem]
    
    var id: Int { requestId }
    
    var statusEnum: RequestStatus? {
        RequestStatus(rawValue: status)
    }
    
    var requestDateFormatted: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: requestDate)
    }
    
    var displayDate: String {
        guard let date = requestDateFormatted else { return requestDate }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    var totalWeight: Double {
        disposalItems.reduce(0) { $0 + $1.weight }
    }
    
    var itemCount: Int {
        disposalItems.count
    }
    
    var canCancel: Bool {
        statusEnum == .requested || statusEnum == .scheduled
    }
}

/// 수거 요청 상세
struct RequestDetail: Identifiable, Codable {
    let requestId: Int
    let requestDate: String
    let status: String
    let disposalItems: [RequestDisposalItem]
    
    var id: Int { requestId }
    
    var statusEnum: RequestStatus? {
        RequestStatus(rawValue: status)
    }
    
    var requestDateFormatted: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: requestDate)
    }
    
    var displayDate: String {
        guard let date = requestDateFormatted else { return requestDate }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일 (E)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    var totalWeight: Double {
        disposalItems.reduce(0) { $0 + $1.weight }
    }
    
    var canCancel: Bool {
        statusEnum == .requested || statusEnum == .scheduled
    }
}

// MARK: - Type Aliases
typealias RequestList = [Request]
