//
//  WasteViewModel.swift
//  Labify
//
//  Created by KITS on 10/15/25.
//

import Foundation
import SwiftUI

// MARK: - Waste ViewModel (LAB, FAC가 사용)
@MainActor
class WasteViewModel: ObservableObject {
    @Published var wastes: [Waste] = []
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage: String?
    
    // AI 분류 결과
    @Published var aiClassifyResult: AIClassifyResponse?
    @Published var isClassifying = false
    
    private var token: String? {
        UserDefaults.standard.string(forKey: "accessToken")
    }
    
    // MARK: - ✅ AI 폐기물 분류 (LAB)
    func classifyWasteWithAI(imageData: Data) async -> AIClassifyResponse? {
        guard let token = token else {
            handleError(NetworkError.unauthorized)
            return nil
        }
        
        isClassifying = true
        defer { isClassifying = false }
        
        do {
            let result = try await WasteService.classifyWaste(
                imageData: imageData,
                token: token
            )
            aiClassifyResult = result
            return result
        } catch {
            handleError(error)
            return nil
        }
    }
    
    // MARK: - ✅ 폐기물 등록 (LAB)
    func registerWaste(
        labId: Int,
        wasteTypeId: Int,
        weight: Double,
        unit: String,
        memo: String?,
        createdBy: Int
    ) async -> DisposalResponse? {
        guard let token = token else {
            handleError(NetworkError.unauthorized)
            return nil
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let request = RegisterWasteRequest(
                lab_id: labId,
                waste_type_id: wasteTypeId,
                weight: weight,
                unit: unit,
                memo: memo,
                created_by: createdBy
            )
            
            let response = try await WasteService.registerWaste(
                request: request,
                token: token
            )
            return response
        } catch {
            handleError(error)
            return nil
        }
    }
    
    // MARK: - 폐기물 목록 조회
    // TODO: API 개발 대기 중
    func fetchWastes(labId: Int? = nil) async {
        guard let token = token else {
            handleError(NetworkError.unauthorized)
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        // do {
        //     wastes = try await WasteService.fetchWastes(labId: labId, token: token)
        // } catch {
        //     handleError(error)
        // }
        
        // 임시 목 데이터
        wastes = []
    }
    
    // MARK: - 폐기물 삭제
    // TODO: API 개발 대기 중
    func deleteWaste(wasteId: Int) async -> Bool {
        guard let token = token else {
            handleError(NetworkError.unauthorized)
            return false
        }
        
        isLoading = true
        defer { isLoading = false }
        
        // do {
        //     try await WasteService.deleteWaste(wasteId: wasteId, token: token)
        //     wastes.removeAll { $0.id == wasteId }
        //     return true
        // } catch {
        //     handleError(error)
        //     return false
        // }
        
        return false
    }
    
    // MARK: - 통계 계산
    var totalWastes: Int {
        wastes.count
    }
    
    // MARK: - 에러 처리
    private func handleError(_ error: Error) {
        if let networkError = error as? NetworkError {
            errorMessage = networkError.localizedDescription
        } else {
            errorMessage = error.localizedDescription
        }
        showError = true
        print("❌ WasteViewModel Error: \(errorMessage ?? "Unknown")")
    }
}

// MARK: - Waste Service
struct WasteService {
    static let networkManager = NetworkManager.shared
    
    // MARK: - ✅ AI 폐기물 분류
    static func classifyWaste(imageData: Data, token: String) async throws -> AIClassifyResponse {
        // Multipart/form-data 요청 생성
        guard let url = URL(string: networkManager.baseURLString + "/ai-predict") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // 이미지 파일 추가
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"waste.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
        
        return try JSONDecoder().decode(AIClassifyResponse.self, from: data)
    }
    
    // MARK: - ✅ 폐기물 등록
    static func registerWaste(request: RegisterWasteRequest, token: String) async throws -> DisposalResponse {
        return try await networkManager.request(
            endpoint: "/disposals",
            method: "POST",
            body: request,
            token: token
        )
    }
    
    // MARK: - 폐기물 목록 조회 (TODO)
    // static func fetchWastes(labId: Int?, token: String) async throws -> [Waste] {
    //     let endpoint = labId != nil ? "/wastes?labId=\(labId!)" : "/wastes"
    //     return try await networkManager.request(
    //         endpoint: endpoint,
    //         method: "GET",
    //         token: token
    //     )
    // }
    
    // MARK: - 폐기물 삭제 (TODO)
    // static func deleteWaste(wasteId: Int, token: String) async throws {
    //     let _: EmptyResponse = try await networkManager.request(
    //         endpoint: "/wastes/\(wasteId)",
    //         method: "DELETE",
    //         token: token
    //     )
    // }
}

// MARK: - Models
//
//// ✅ AI 분류 응답
//struct AIClassifyResponse: Codable {
//    let coarse: String      // 대분류: sharps, chemicals, etc.
//    let fine: String        // 세분류: syringe, needle, etc.
//    let is_bio: Bool        // 생물학적 폐기물 여부
//    let is_ocr: Bool        // OCR 감지 여부
//    let ocr_text: String?   // OCR 텍스트
//    
//    var displayCoarse: String {
//        switch coarse {
//        case "sharps": return "날카로운 물체"
//        case "chemicals": return "화학 물질"
//        case "biological": return "생물학적 폐기물"
//        default: return coarse
//        }
//    }
//    
//    var displayFine: String {
//        switch fine {
//        case "syringe": return "주사기"
//        case "needle": return "주사바늘"
//        case "gloves": return "장갑"
//        default: return fine
//        }
//    }
//}
//
//// ✅ 폐기물 등록 요청
//struct RegisterWasteRequest: Codable {
//    let lab_id: Int
//    let waste_type_id: Int
//    let weight: Double
//    let unit: String
//    let memo: String?
//    let created_by: Int
//}
//
//// ✅ 폐기물 등록 응답
//struct DisposalResponse: Codable {
//    let disposal_id: Int
//    let qr_code_url: String
//    let status: String      // "stored", "requested", "completed"
//    
//    enum CodingKeys: String, CodingKey {
//        case disposal_id
//        case qr_code_url
//        case status
//    }
//}
//
//// 기존 Waste 모델 (목록 조회용 - API 개발 대기)
//struct Waste: Identifiable, Codable {
//    let id: Int
//    let name: String
//    let weight: Double
//    let unit: String
//    let labId: Int
//    let status: String
//    
//    enum CodingKeys: String, CodingKey {
//        case id = "wasteId"
//        case name
//        case weight
//        case unit
//        case labId
//        case status
//    }
//}
//
//// NetworkManager에 baseURL 노출 필요
//extension NetworkManager {
//    var baseURL: String {
//        return "http://localhost:8080"
//    }
//}
