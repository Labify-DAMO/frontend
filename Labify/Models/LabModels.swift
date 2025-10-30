//
//  LabModels.swift
//  Labify
//
//  Created by F_S on 10/30/25.
//

import Foundation

struct Lab: Identifiable, Codable {
    let id: Int
    let name: String
    let location: String
    let facilityId: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "labId"
        case name, location, facilityId
    }
}

// ✅ View에서 사용하는 모델
struct LabRequest: Identifiable, Codable {
    let id: Int
    let labName: String
    let location: String
    let requesterName: String  // Swift 프로퍼티명
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "requestId"
        case labName, location
        case requesterName = "managerName"  // ✅ API의 "managerName"을 "requesterName"으로 매핑
        case createdAt
    }
}

// ✅ API 응답 모델
struct LabRequestsResponse: Codable {
    let requests: [LabRequestItem]
    let count: Int
}

struct LabRequestItem: Identifiable, Codable {
    let id: Int
    let labName: String
    let location: String
    let requesterName: String  // Swift 프로퍼티명
    let createdAt: String
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id = "requestId"
        case labName, location
        case requesterName = "managerName"  // ✅ API의 "managerName"을 "requesterName"으로 매핑
        case createdAt, status
    }
}

// ✅ 실험실 개설 승인 응답
struct LabConfirmResponse: Codable {
    let labId: Int
    let name: String
    let location: String
    let facilityId: Int
}

// ✅ 실험실 개설 요청 생성 (LAB → FAC)
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

// ✅ 실험실 등록 요청 (FAC)
struct RegisterLabRequest: Codable {
    let name: String
    let location: String
    let facilityId: Int
}

// ✅ 실험실 수정 요청
struct UpdateLabRequest: Codable {
    let name: String
    let location: String
}

// ✅ 실험실 개설 거절 응답
struct LabRequestResponse: Codable {
    let requestId: Int
    let status: String
}
