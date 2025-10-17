//
//  PickupViewModel.swift
//  Labify
//
//  Created by F_S on 10/15/25.
//

import Foundation

@MainActor
class PickupViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var todayPickups: [TodayPickupItem] = []
    @Published var tomorrowPickups: [TomorrowPickupItem] = []
    @Published var pickupHistory: [PickupHistoryItem] = []
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    // 필터링
    @Published var selectedRegion: String = "전체 지역"
    @Published var selectedMonth: String = "전체"
    
    // MARK: - QR 스캔 처리
    func scanQRCode(qrCode: String, collectorId: Int) async {
        isLoading = true
        errorMessage = nil
        
        do {
            guard let token = UserDefaults.standard.string(forKey: "authToken") else {
                throw NetworkError.unauthorized
            }
            
            let response = try await PickupService.scanQRCode(
                qrCode: qrCode,
                collectorId: collectorId,
                token: token
            )
            
            print("✅ QR 스캔 성공: disposal_id=\(response.disposal_id)")
            
            // 오늘 진행 현황 새로고침
            await fetchTodayPickups()
            
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    // MARK: - 오늘 진행 현황 조회
    func fetchTodayPickups() async {
        isLoading = true
        errorMessage = nil
        
        do {
            guard let token = UserDefaults.standard.string(forKey: "authToken") else {
                throw NetworkError.unauthorized
            }
            
            todayPickups = try await PickupService.fetchTodayPickups(token: token)
            print("✅ 오늘 수거 목록 조회 성공: \(todayPickups.count)건")
            
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    // MARK: - 수거 상태 업데이트
    func updatePickupStatus(pickupId: Int, status: PickupItemStatus) async {
        isLoading = true
        errorMessage = nil
        
        do {
            guard let token = UserDefaults.standard.string(forKey: "authToken") else {
                throw NetworkError.unauthorized
            }
            
            try await PickupService.updatePickupStatus(
                pickupId: pickupId,
                status: status.rawValue,
                token: token
            )
            
            print("✅ 수거 상태 업데이트 성공: \(status.displayText)")
            
            // 오늘 진행 현황 새로고침
            await fetchTodayPickups()
            
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    // MARK: - 내일 수거 목록 조회
    func fetchTomorrowPickups(region: String? = nil) async {
        isLoading = true
        errorMessage = nil
        
        do {
            guard let token = UserDefaults.standard.string(forKey: "authToken") else {
                throw NetworkError.unauthorized
            }
            
            if let region = region, region != "전체 지역" {
                tomorrowPickups = try await PickupService.fetchTomorrowPickups(
                    region: region,
                    token: token
                )
            } else {
                tomorrowPickups = try await PickupService.fetchTomorrowPickups(token: token)
            }
            
            print("✅ 내일 수거 목록 조회 성공: \(tomorrowPickups.count)건")
            
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    // MARK: - 처리 이력 조회
    func fetchPickupHistory() async {
        isLoading = true
        errorMessage = nil
        
        do {
            guard let token = UserDefaults.standard.string(forKey: "authToken") else {
                throw NetworkError.unauthorized
            }
            
            pickupHistory = try await PickupService.fetchPickupHistory(token: token)
            print("✅ 처리 이력 조회 성공: \(pickupHistory.count)건")
            
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    // MARK: - 필터링된 이력
    var filteredHistory: [PickupHistoryItem] {
        pickupHistory.filter { item in
            let regionMatch = selectedRegion == "전체 지역" || item.region.contains(selectedRegion)
            
            // 월 필터링 (날짜 문자열에서 월 추출)
            let monthMatch: Bool
            if selectedMonth == "전체" {
                monthMatch = true
            } else {
                // "9월" -> "09"로 변환
                let monthNumber = selectedMonth.replacingOccurrences(of: "월", with: "")
                if let month = Int(monthNumber) {
                    let monthString = String(format: "%02d", month)
                    monthMatch = item.date.contains("-\(monthString)-")
                } else {
                    monthMatch = true
                }
            }
            
            return regionMatch && monthMatch
        }
    }
    
    // MARK: - 상태별 필터링
    func filteredTodayPickups(by status: PickupItemStatus?) -> [TodayPickupItem] {
        guard let status = status else {
            return todayPickups
        }
        return todayPickups.filter { $0.status == status }
    }
    
    // MARK: - Error Handling
    private func handleError(_ error: Error) {
        if let networkError = error as? NetworkError {
            errorMessage = networkError.errorDescription
        } else {
            errorMessage = error.localizedDescription
        }
        showError = true
        print("❌ Error: \(errorMessage ?? "Unknown error")")
    }
}
