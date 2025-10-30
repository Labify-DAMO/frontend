//
//  WasteModels.swift
//  Labify
//
//  Created by F_S on 10/30/25.
//

import Foundation

// MARK: - Waste Category
struct WasteCategory: Identifiable, Codable {
    let id: Int
    let name: String
    let description: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "categoryId", name, description
    }
}

// MARK: - Waste Type
struct WasteType: Identifiable, Codable {
    let id: Int
    let name: String
    let categoryId: Int?
    let categoryName: String?
    let unit: String
    let description: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "typeId", name, categoryId, categoryName, unit, description
    }
}

// MARK: - Waste Unit Enum
enum WasteUnit: String, CaseIterable, Identifiable {
    case kg = "kg"
    case g = "g"
    case liter = "L"
    case mL = "mL"
    case piece = "piece"
    
    var id: String { rawValue }
}

// MARK: - Disposal Status Enum
enum DisposalStatus: String, Codable, CaseIterable {
    case stored = "STORED"
    case requested = "REQUESTED"
    case pickedUp = "PICKED_UP"
    
    var displayName: String {
        switch self {
        case .stored: return "보관 중"
        case .requested: return "수거 요청됨"
        case .pickedUp: return "수거 완료"
        }
    }
    
    var color: String {
        switch self {
        case .stored: return "blue"
        case .requested: return "orange"
        case .pickedUp: return "green"
        }
    }
}

// MARK: - AI Classification
struct AIClassifyResponse: Codable {
    let coarse: String
    let fine: String
    let unit: String?
    let is_bio: Bool
    let is_ocr: Bool
    let ocr_text: String?
}

// MARK: - Request Models
struct RegisterWasteDetailRequest: Codable {
    let labId: Int
    let wasteTypeName: String
    let weight: Double
    let unit: String
    let memo: String?
    let availableUntil: String
}

struct UpdateWasteDetailRequest: Codable {
    let weight: Double?
    let unit: String?
    let memo: String?
    let status: String?
    let availableUntil: String?
    
    init(weight: Double? = nil, unit: String? = nil, memo: String? = nil, status: String? = nil, availableUntil: String? = nil) {
        self.weight = weight
        self.unit = unit
        self.memo = memo
        self.status = status
        self.availableUntil = availableUntil
    }
}

// MARK: - Response Models
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
    
    var statusEnum: DisposalStatus? {
        DisposalStatus(rawValue: status)
    }
    
    var createdDate: Date? {
        ISO8601DateFormatter().date(from: createdAt)
    }
    
    var availableUntilDate: Date? {
        guard let availableUntil = availableUntil else { return nil }
        return ISO8601DateFormatter().date(from: availableUntil)
    }
}

struct DisposalListResponse: Codable {
    let totalCount: Int
    let disposalItems: [DisposalItemData]
}

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
    
    // Computed Properties
    var displayName: String { wasteTypeName }
    
    var statusEnum: DisposalStatus? {
        DisposalStatus(rawValue: status)
    }
    
    var createdDate: Date? {
        ISO8601DateFormatter().date(from: createdAt)
    }
    
    var availableUntilDate: Date? {
        guard let availableUntil = availableUntil else { return nil }
        return ISO8601DateFormatter().date(from: availableUntil)
    }
    
    var formattedCreatedAt: String {
        guard let date = createdDate else { return createdAt }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
}

// Type Alias
typealias Waste = DisposalItemData
