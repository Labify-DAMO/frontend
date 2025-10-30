//
//  LabModels.swift
//  Labify
//
//  Created by KITS on 10/30/25.
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

struct LabRequest: Identifiable, Codable {
    let id: Int
    let labName: String
    let location: String
    let requesterName: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "requestId", labName, location, requesterName, createdAt
    }
}

struct LabRequestsResponse: Codable {
    let requests: [LabRequestItem]
    let count: Int
}

struct LabRequestItem: Identifiable, Codable {
    let id: Int
    let labName: String
    let location: String
    let requesterName: String
    let createdAt: String
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id = "requestId", labName, location, requesterName, createdAt, status
    }
}

struct LabConfirmResponse: Codable {
    let labId: Int
    let name: String
    let location: String
    let facilityId: Int
}

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
