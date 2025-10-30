//
//  UserModels.swift
//  Labify
//
//  Created by KITS on 10/30/25.
//

import Foundation

struct UserInfo: Codable {
    let userId: Int
    let name: String
    let email: String
    let role: String
    
    enum CodingKeys: String, CodingKey {
        case userId, name, email, role
    }
    
    init(userId: Int, name: String, email: String, role: String) {
        self.userId = userId
        self.name = name
        self.email = email
        self.role = role
    }
}

struct TokenResponse: Codable {
    let accessToken: String
    let refreshToken: String
}

struct EmptyResponse: Codable {}
