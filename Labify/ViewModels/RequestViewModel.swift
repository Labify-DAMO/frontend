//
//  RequestViewModel.swift
//  Labify
//
//  Created by F_S on 10/30/25.
//

import Foundation
import SwiftUI

@MainActor
class RequestViewModel: ObservableObject {
    // MARK: - Published Properties
    
    // 수거 요청 목록
    @Published var requests: [Request] = []
    @Published var currentRequestDetail: RequestDetail?
    
    // 선택된 폐기물 (수거 요청 생성용)
    @Published var selectedDisposalIds: Set<Int> = []
    
    // 로딩 상태
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage: String?
    
    // 성공 메시지
    @Published var showSuccessMessage = false
    @Published var successMessage: String?
    
    // MARK: - Private Properties
    
    private var token: String? {
        UserDefaults.standard.string(forKey: "accessToken")
    }
    
    // MARK: - ✅ 수거 요청 생성
    /// 선택한 폐기물들로 수거 요청을 생성합니다.
    func createRequest(
        labId: Int,
        requestDate: Date,
        disposalItemIds: [Int]
    ) async -> Bool {
        guard let token = token else {
            handleError(NetworkError.unauthorized)
            return false
        }
        
        guard !disposalItemIds.isEmpty else {
            errorMessage = "수거할 폐기물을 선택해주세요."
            showError = true
            return false
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let requestDateString = RequestService.formatRequestDate(requestDate)
            
            let response = try await RequestService.createRequest(
                labId: labId,
                requestDate: requestDateString,
                disposalItemIds: disposalItemIds,
                token: token
            )
            
            print("✅ 수거 요청 생성 성공: ID=\(response.pickupRequestId)")
            
            // 성공 메시지
            successMessage = "수거 요청이 생성되었습니다."
            showSuccessMessage = true
            
            // 선택 초기화
            selectedDisposalIds.removeAll()
            
            // 목록 새로고침
            await fetchRequests()
            
            return true
        } catch {
            handleError(error)
            return false
        }
    }
    
    // MARK: - ✅ 수거 요청 취소
    /// 특정 수거 요청을 취소합니다.
    func cancelRequest(requestId: Int) async -> Bool {
        guard let token = token else {
            handleError(NetworkError.unauthorized)
            return false
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await RequestService.cancelRequest(
                requestId: requestId,
                token: token
            )
            
            print("✅ 수거 요청 취소 성공: ID=\(response.pickupRequestId)")
            
            // 성공 메시지
            successMessage = "수거 요청이 취소되었습니다."
            showSuccessMessage = true
            
            // 목록 새로고침
            await fetchRequests()
            
            return true
        } catch {
            handleError(error)
            return false
        }
    }
    
    // MARK: - ✅ 수거 요청 목록 조회 (전체)
    /// 모든 수거 요청을 조회합니다.
    func fetchRequests() async {
        guard let token = token else {
            handleError(NetworkError.unauthorized)
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            requests = try await RequestService.fetchRequests(token: token)
            print("✅ 수거 요청 목록 조회 성공: \(requests.count)개")
        } catch {
            handleError(error)
        }
    }
    
    // MARK: - ✅ 수거 요청 목록 조회 (상태별 필터링)
    /// 특정 상태의 수거 요청을 조회합니다.
    func fetchRequests(status: RequestStatus) async {
        guard let token = token else {
            handleError(NetworkError.unauthorized)
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            requests = try await RequestService.fetchRequests(
                status: status,
                token: token
            )
            print("✅ 수거 요청 목록 조회 성공 (\(status.displayName)): \(requests.count)개")
        } catch {
            handleError(error)
        }
    }
    
    // MARK: - ✅ 수거 요청 상세 조회
    /// 특정 수거 요청의 상세 정보를 조회합니다.
    func fetchRequestDetail(requestId: Int) async -> RequestDetail? {
        guard let token = token else {
            handleError(NetworkError.unauthorized)
            return nil
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let detail = try await RequestService.fetchRequestDetail(
                requestId: requestId,
                token: token
            )
            currentRequestDetail = detail
            print("✅ 수거 요청 상세 조회 성공: ID=\(detail.requestId)")
            return detail
        } catch {
            handleError(error)
            return nil
        }
    }
    
    // MARK: - 선택 관리 메서드
    
    /// 폐기물 선택/해제 토글
    func toggleDisposalSelection(_ disposalId: Int) {
        if selectedDisposalIds.contains(disposalId) {
            selectedDisposalIds.remove(disposalId)
        } else {
            selectedDisposalIds.insert(disposalId)
        }
    }
    
    /// 모든 선택 해제
    func clearSelection() {
        selectedDisposalIds.removeAll()
    }
    
    /// 선택된 항목 개수
    var selectedCount: Int {
        selectedDisposalIds.count
    }
    
    /// 선택 여부 확인
    func isSelected(_ disposalId: Int) -> Bool {
        selectedDisposalIds.contains(disposalId)
    }
    
    // MARK: - 편의 메서드들
    
    /// 상태별 수거 요청 개수 조회
    func getCountByStatus(_ status: RequestStatus) -> Int {
        requests.filter { $0.statusEnum == status }.count
    }
    
    /// 특정 상태의 수거 요청 필터링
    func filterByStatus(_ status: RequestStatus) -> [Request] {
        requests.filter { $0.statusEnum == status }
    }
    
    /// 오늘 예정된 수거 요청
    func getTodayScheduledRequests() -> [Request] {
        let today = Calendar.current.startOfDay(for: Date())
        return requests.filter {
            guard let requestDate = $0.requestDateFormatted else { return false }
            let requestDay = Calendar.current.startOfDay(for: requestDate)
            return requestDay == today && $0.statusEnum == .scheduled
        }
    }
    
    /// 예정된 수거 요청 (REQUESTED + SCHEDULED)
    func getUpcomingRequests() -> [Request] {
        requests.filter {
            $0.statusEnum == .requested || $0.statusEnum == .scheduled
        }.sorted { request1, request2 in
            guard let date1 = request1.requestDateFormatted,
                  let date2 = request2.requestDateFormatted else {
                return false
            }
            return date1 < date2
        }
    }
    
    /// 완료된 수거 요청
    func getCompletedRequests() -> [Request] {
        requests.filter { $0.statusEnum == .completed }
    }
    
    /// 취소된 수거 요청
    func getCanceledRequests() -> [Request] {
        requests.filter { $0.statusEnum == .canceled }
    }
    
    /// 수거 요청 검색
    func searchRequests(query: String) -> [Request] {
        if query.isEmpty {
            return requests
        }
        return requests.filter { request in
            request.disposalItems.contains { item in
                item.wasteTypeName.localizedCaseInsensitiveContains(query)
            }
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
        print("❌ RequestViewModel Error: \(errorMessage ?? "Unknown")")
    }
}
