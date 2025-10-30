//
//  QRModels.swift
//  Labify
//
//  Created by F_S on 10/30/25.
//

import Foundation
import UIKit

// MARK: - Request Models

/// QR 코드 생성 Request
struct CreateQRRequest: Codable {
    let disposalItemId: Int
}

// MARK: - Response Models

/// QR 코드 이미지 응답 (바이너리 데이터)
struct QRImageResponse {
    let disposalItemId: Int
    let imageData: Data
    
    /// Data를 UIImage로 변환
    var image: UIImage? {
        UIImage(data: imageData)
    }
}

// MARK: - QR 코드 아이템 (UI용)
struct QRCodeItem: Identifiable {
    let id: Int // disposalItemId
    let wasteTypeName: String
    let weight: Double
    let unit: String
    let imageData: Data?
    
    var image: UIImage? {
        guard let data = imageData else { return nil }
        return UIImage(data: data)
    }
    
    var displayWeight: String {
        "\(weight) \(unit)"
    }
}
