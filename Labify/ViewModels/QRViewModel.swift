//
//  QRViewModel.swift
//  Labify
//
//  Created by F_S on 10/30/25.
//

import Foundation
import SwiftUI

@MainActor
class QRViewModel: ObservableObject {
    // MARK: - Published Properties
    
    // QR 코드 캐시 (disposalItemId: imageData)
    @Published var qrCodeCache: [Int: Data] = [:]
    
    // 현재 표시 중인 QR 코드
    @Published var currentQRCode: QRCodeItem?
    
    // 로딩 상태
    @Published var isLoading = false
    @Published var isGenerating = false
    @Published var showError = false
    @Published var errorMessage: String?
    
    // 성공 메시지
    @Published var showSuccessMessage = false
    @Published var successMessage: String?
    
    // MARK: - Private Properties
    
    private var token: String? {
        UserDefaults.standard.string(forKey: "accessToken")
    }
    
    // MARK: - ✅ QR 코드 생성
    /// 특정 폐기물에 대한 QR 코드를 생성합니다.
    func generateQRCode(
        disposalItemId: Int,
        wasteTypeName: String,
        weight: Double,
        unit: String
    ) async -> Bool {
        guard let token = token else {
            handleError(NetworkError.unauthorized)
            return false
        }
        
        isGenerating = true
        defer { isGenerating = false }
        
        do {
            let imageData = try await QRService.createQRCode(
                disposalItemId: disposalItemId,
                token: token
            )
            
            print("✅ QR 코드 생성 성공: Disposal ID=\(disposalItemId), Size=\(imageData.count) bytes")
            
            // 캐시에 저장
            qrCodeCache[disposalItemId] = imageData
            
            // 현재 QR 코드 설정
            currentQRCode = QRCodeItem(
                id: disposalItemId,
                wasteTypeName: wasteTypeName,
                weight: weight,
                unit: unit,
                imageData: imageData
            )
            
            // 성공 메시지
            successMessage = "QR 코드가 생성되었습니다."
            showSuccessMessage = true
            
            return true
        } catch {
            handleError(error)
            return false
        }
    }
    
    // MARK: - ✅ QR 코드 이미지 조회
    /// 특정 폐기물의 QR 코드 이미지를 조회합니다.
    func fetchQRCodeImage(
        disposalItemId: Int,
        wasteTypeName: String,
        weight: Double,
        unit: String
    ) async -> Bool {
        guard let token = token else {
            handleError(NetworkError.unauthorized)
            return false
        }
        
        // 캐시에 있으면 캐시 사용
        if let cachedData = qrCodeCache[disposalItemId] {
            print("💾 캐시에서 QR 코드 로드: Disposal ID=\(disposalItemId)")
            currentQRCode = QRCodeItem(
                id: disposalItemId,
                wasteTypeName: wasteTypeName,
                weight: weight,
                unit: unit,
                imageData: cachedData
            )
            return true
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let imageData = try await QRService.fetchQRCodeImage(
                disposalItemId: disposalItemId,
                token: token
            )
            
            print("✅ QR 코드 조회 성공: Disposal ID=\(disposalItemId), Size=\(imageData.count) bytes")
            
            // 캐시에 저장
            qrCodeCache[disposalItemId] = imageData
            
            // 현재 QR 코드 설정
            currentQRCode = QRCodeItem(
                id: disposalItemId,
                wasteTypeName: wasteTypeName,
                weight: weight,
                unit: unit,
                imageData: imageData
            )
            
            return true
        } catch {
            handleError(error)
            return false
        }
    }
    
    // MARK: - ✅ QR 코드 생성 또는 조회
    /// QR 코드가 없으면 생성하고, 있으면 조회합니다.
    func getOrCreateQRCode(
        disposalItemId: Int,
        wasteTypeName: String,
        weight: Double,
        unit: String
    ) async -> Bool {
        // 먼저 조회 시도
        let fetchSuccess = await fetchQRCodeImage(
            disposalItemId: disposalItemId,
            wasteTypeName: wasteTypeName,
            weight: weight,
            unit: unit
        )
        
        if fetchSuccess {
            return true
        }
        
        // 조회 실패시 생성 시도
        return await generateQRCode(
            disposalItemId: disposalItemId,
            wasteTypeName: wasteTypeName,
            weight: weight,
            unit: unit
        )
    }
    
    // MARK: - 캐시 관리
    
    /// 특정 QR 코드 캐시 삭제
    func clearQRCodeCache(disposalItemId: Int) {
        qrCodeCache.removeValue(forKey: disposalItemId)
        if currentQRCode?.id == disposalItemId {
            currentQRCode = nil
        }
    }
    
    /// 모든 QR 코드 캐시 삭제
    func clearAllCache() {
        qrCodeCache.removeAll()
        currentQRCode = nil
    }
    
    /// 캐시 존재 여부 확인
    func hasCachedQRCode(disposalItemId: Int) -> Bool {
        qrCodeCache[disposalItemId] != nil
    }
    
    /// 캐시에서 QR 코드 가져오기
    func getCachedQRCode(disposalItemId: Int) -> Data? {
        qrCodeCache[disposalItemId]
    }
    
    // MARK: - 편의 메서드
    
    /// 현재 QR 코드 초기화
    func clearCurrentQRCode() {
        currentQRCode = nil
    }
    
    /// QR 코드 이미지를 사진 앱에 저장
    func saveQRCodeToPhotos() -> Bool {
        guard let imageData = currentQRCode?.imageData,
              let image = UIImage(data: imageData) else {
            errorMessage = "저장할 QR 코드가 없습니다."
            showError = true
            return false
        }
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        successMessage = "QR 코드가 사진 앱에 저장되었습니다."
        showSuccessMessage = true
        return true
    }
    
    /// QR 코드 이미지 공유를 위한 UIImage 반환
    func getShareableImage() -> UIImage? {
        guard let imageData = currentQRCode?.imageData else {
            return nil
        }
        return UIImage(data: imageData)
    }
    
    // MARK: - 에러 처리
    private func handleError(_ error: Error) {
        if let networkError = error as? NetworkError {
            errorMessage = networkError.localizedDescription
        } else {
            errorMessage = error.localizedDescription
        }
        showError = true
        print("❌ QRViewModel Error: \(errorMessage ?? "Unknown")")
    }
}

