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
        let token = UserDefaults.standard.string(forKey: "accessToken")
        print("🔑 Token check: \(token != nil ? "존재함" : "없음")")
        if let t = token {
            print("🔑 Token value: \(t.prefix(20))...")
        }
        return token
    }
    
    // MARK: - ✅ AI 폐기물 분류 (LAB)
    func classifyWasteWithAI(imageData: Data) async -> AIClassifyResponse? {
        print("📸 AI 분류 시작...")
        
        guard let token = token else {
            print("❌ 토큰이 없습니다!")
            handleError(NetworkError.unauthorized)
            return nil
        }
        
        print("✅ 토큰 확인 완료, API 호출 시작")
        isClassifying = true
        defer { isClassifying = false }
        
        do {
            let result = try await WasteService.classifyWaste(
                imageData: imageData,
                token: token
            )
            aiClassifyResult = result
            print("✅ AI 분류 성공: \(result.coarse) - \(result.fine)")
            return result
        } catch {
            print("❌ AI 분류 실패: \(error)")
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
        availableUntil: String,
        createdById: Int
    ) async -> DisposalDetail? {
        guard let token = token else {
            handleError(NetworkError.unauthorized)
            return nil
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let request = RegisterWasteDetailRequest(
                labId: labId,
                wasteTypeId: wasteTypeId,
                weight: weight,
                unit: unit,
                memo: memo,
                availableUntil: availableUntil,
                createdById: createdById
            )
            
            let response = try await WasteService.registerWasteDetail(
                request: request,
                token: token
            )
            print("✅ 폐기물 등록 성공: ID=\(response.id)")
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
            print("❌ Invalid URL: \(networkManager.baseURLString)/ai-predict")
            throw NetworkError.invalidURL
        }
        
        print("📡 Request URL: \(url)")
        print("📦 Image size: \(imageData.count) bytes")
        
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
        
        print("📤 Sending request...")
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Invalid response type")
            throw NetworkError.invalidResponse
        }
        
        print("📥 Response status: \(httpResponse.statusCode)")
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("📄 Response body: \(responseString)")
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            print("❌ HTTP Error: \(httpResponse.statusCode)")
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        let result = try decoder.decode(AIClassifyResponse.self, from: data)
        print("✅ Decoded successfully")
        return result
    }
    
    // MARK: - ✅ 폐기물 등록 (상세 정보 포함)
    static func registerWasteDetail(request: RegisterWasteDetailRequest, token: String) async throws -> DisposalDetail {
        return try await networkManager.request(
            endpoint: "/disposals",
            method: "POST",
            body: request,
            token: token
        )
    }
}
