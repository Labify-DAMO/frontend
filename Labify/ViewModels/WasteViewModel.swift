//
//  WasteViewModel.swift (Updated with Categories & Types)
//  Labify
//

import Foundation
import SwiftUI

@MainActor
class WasteViewModel: ObservableObject {
    // Note: Waste 모델이 정의되면 주석 해제하세요
    // @Published var wastes: [Waste] = []
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage: String?
    
    // AI 분류 결과
    @Published var aiClassifyResult: AIClassifyResponse?
    @Published var isClassifying = false
    
    // 카테고리 & 타입 목록
    @Published var wasteCategories: [WasteCategory] = []
    @Published var wasteTypes: [WasteType] = []
    @Published var filteredWasteTypes: [WasteType] = []
    
    private var token: String? {
        let token = UserDefaults.standard.string(forKey: "accessToken")
        return token
    }
    
    // MARK: - ✅ 폐기물 카테고리 목록 조회
    func fetchWasteCategories() async {
        guard let token = token else {
            handleError(NetworkError.unauthorized)
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            wasteCategories = try await WasteService.fetchWasteCategories(token: token)
            print("✅ 카테고리 조회 성공: \(wasteCategories.count)개")
        } catch {
            handleError(error)
        }
    }
    
    // MARK: - ✅ 특정 카테고리의 폐기물 타입 조회
    func fetchWasteTypes(categoryName: String) async {
        guard let token = token else {
            handleError(NetworkError.unauthorized)
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            wasteTypes = try await WasteService.fetchWasteTypes(categoryName: categoryName, token: token)
            filteredWasteTypes = wasteTypes
            print("✅ '\(categoryName)' 타입 조회 성공: \(wasteTypes.count)개")
        } catch {
            handleError(error)
        }
    }
    
    // MARK: - ✅ 특정 카테고리의 타입 필터링 (로컬)
    func filterWasteTypes(byCategoryName categoryName: String) {
        if let category = wasteCategories.first(where: { $0.name == categoryName }) {
            filteredWasteTypes = wasteTypes.filter { $0.categoryName == categoryName }
            print("✅ 카테고리 '\(categoryName)' 필터링: \(filteredWasteTypes.count)개")
        } else {
            filteredWasteTypes = wasteTypes
        }
    }
    
    // MARK: - ✅ AI 폐기물 분류
    func classifyWasteWithAI(imageData: Data) async -> AIClassifyResponse? {
        print("📸 AI 분류 시작...")
        
        guard let token = token else {
            print("❌ 토큰이 없습니다!")
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
            
            print("✅ AI 분류 성공: \(result.coarse) - \(result.fine)")
            return result
        } catch {
            print("❌ AI 분류 실패: \(error)")
            handleError(error)
            return nil
        }
    }
    
    // MARK: - ✅ 폐기물 등록
    func registerWaste(
        labId: Int,
        wasteTypeName: String?,
        weight: Double,
        unit: String,
        memo: String?,
        availableUntil: String
    ) async -> DisposalDetail? {
        guard let token = token else {
            handleError(NetworkError.unauthorized)
            return nil
        }
        
        print(String(repeating: "=", count: 50))  // ✅ Swift 방식
        print("🔐 토큰 정보:")
        print("- Token: \(token.prefix(20))...")
        print("- Lab ID: \(labId)")
        print("- Waste Type: \(wasteTypeName ?? "nil")")
        print(String(repeating: "=", count: 50))
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let request = RegisterWasteDetailRequest(
                labId: labId,
                wasteTypeName: wasteTypeName ?? "미지정",
                weight: weight,
                unit: unit,
                memo: memo,
                availableUntil: availableUntil
            )
            
            let response = try await WasteService.registerWasteDetail(
                request: request,
                token: token
            )
            print("✅ 폐기물 등록 성공: ID=\(response.id)")
            return response
        } catch {
            print("❌ 에러 상세: \(error)")
            handleError(error)
            return nil
        }
    }
    
    // MARK: - ✅ 폐기물 정보 수정
    func updateWaste(
        disposalItemId: Int,
        weight: Double? = nil,
        unit: String? = nil,
        memo: String? = nil,
        status: String? = nil,
        availableUntil: String? = nil
    ) async -> DisposalDetail? {
        guard let token = token else {
            handleError(NetworkError.unauthorized)
            return nil
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let request = UpdateWasteDetailRequest(
                weight: weight,
                unit: unit,
                memo: memo,
                status: status,
                availableUntil: availableUntil
            )
            
            let response = try await WasteService.updateWasteDetail(
                disposalItemId: disposalItemId,
                request: request,
                token: token
            )
            print("✅ 폐기물 수정 성공: ID=\(response.id)")
            return response
        } catch {
            handleError(error)
            return nil
        }
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
