//
//  LabViewModel.swift
//  Labify
//
//  Created by F_S on 10/15/25.
//

import Foundation
import SwiftUI

// MARK: - Lab ViewModel (모든 역할이 사용)
@MainActor
class LabViewModel: ObservableObject {
    @Published var labs: [Lab] = []
    @Published var myLab: Lab?
    @Published var labRequests: [LabRequest] = []
    
    // 수거 요청 관련
    @Published var pickupRequests: [PickupRequestItem] = []
    @Published var selectedPickupDetail: PickupRequestDetail?
    @Published var selectedStatusFilter: PickupRequestStatus = .all
    
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage: String?
    
    private var token: String? {
        UserDefaults.standard.string(forKey: "accessToken")
    }
    
    // MARK: - ✅ 실험실 개설 요청 (LAB → FAC)
    func requestLabCreation(
        facilityId: Int,
        name: String,
        location: String,
        managerId: Int
    ) async -> Bool {
        guard let token = token else {
            handleError(NetworkError.unauthorized)
            return false
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await LabService.requestLabCreation(
                facilityId: facilityId,
                name: name,
                location: location,
                managerId: managerId,
                token: token
            )
            print("✅ 실험실 개설 요청 성공: requestId=\(response.requestId), status=\(response.status)")
            return true
        } catch {
            handleError(error)
            return false
        }
    }
    
    // MARK: - ✅ 실험실 목록 조회 (모든 역할)
    func fetchLabs() async {
        guard let token = token else {
            handleError(NetworkError.unauthorized)
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            labs = try await FacService.fetchLabs(token: token)
            print("✅ 실험실 목록 조회 성공: \(labs.count)개")
        } catch {
            handleError(error)
            labs = []
        }
    }
    
    // MARK: - 내 실험실/부서 조회 (LAB)
    // TODO: API 개발 대기 중
//    func fetchMyLab() async {
//        guard let token = token else {
//            handleError(NetworkError.unauthorized)
//            return
//        }
//
//        isLoading = true
//        defer { isLoading = false }
//
//        print("⚠️ TODO: 내 실험실 조회 API 개발 대기 중")
//        myLab = nil
//    }
    
//    // MARK: - ✅ 실험실 등록/개설 (FAC)
//    func registerLab(name: String, location: String, facilityId: Int) async -> Bool {
//        guard let token = token else {
//            handleError(NetworkError.unauthorized)
//            return false
//        }
//        
//        isLoading = true
//        defer { isLoading = false }
//        
//        do {
//            let request = RegisterLabRequest(
//                name: name,
//                location: location,
//                facilityId: facilityId
//            )
//            
//            let newLab = try await LabService.registerLab(request: request, token: token)
//            labs.append(newLab)
//            print("✅ 실험실 등록 성공: \(newLab.name)")
//            return true
//        } catch {
//            handleError(error)
//            return false
//        }
//    }
    
    // MARK: - ✅ 실험실 수정 (FAC)
    func updateLab(labId: Int, name: String, location: String) async -> Bool {
        guard let token = token else {
            handleError(NetworkError.unauthorized)
            return false
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let request = UpdateLabRequest(name: name, location: location)
            let updatedLab = try await LabService.updateLab(
                labId: labId,
                request: request,
                token: token
            )
            
            if let index = labs.firstIndex(where: { $0.id == labId }) {
                labs[index] = updatedLab
            }
            print("✅ 실험실 수정 성공: \(updatedLab.name)")
            return true
        } catch {
            handleError(error)
            return false
        }
    }
    
    // MARK: - ✅ 실험실 개설 요청 목록 조회 (FAC)
//    func fetchLabRequests() async {
//        guard let token = token else {
//            handleError(NetworkError.unauthorized)
//            return
//        }
//        
//        isLoading = true
//        defer { isLoading = false }
//        
//        do {
//            labRequests = try await LabService.fetchLabRequests(token: token)
//            print("✅ 실험실 개설 요청 목록 조회 성공: \(labRequests.count)개")
//        } catch {
//            handleError(error)
//        }
//    }
    
    // MARK: - ✅ 실험실 개설 요청 승인 (FAC)
//    func confirmLabRequest(requestId: Int) async {
//        guard let token = token else {
//            handleError(NetworkError.unauthorized)
//            return
//        }
//        
//        isLoading = true
//        defer { isLoading = false }
//        
//        do {
//            let approvedLab = try await LabService.confirmLabRequest(
//                requestId: requestId,
//                token: token
//            )
//            
//            labRequests.removeAll { $0.id == requestId }
//            labs.append(approvedLab)
//            print("✅ 실험실 개설 요청 승인 성공: \(approvedLab.name)")
//        } catch {
//            handleError(error)
//        }
//    }
    
    // MARK: - ✅ 실험실 개설 요청 거절 (FAC)
//    func rejectLabRequest(requestId: Int) async {
//        guard let token = token else {
//            handleError(NetworkError.unauthorized)
//            return
//        }
//        
//        isLoading = true
//        defer { isLoading = false }
//        
//        do {
//            _ = try await LabService.rejectLabRequest(
//                requestId: requestId,
//                token: token
//            )
//            
//            labRequests.removeAll { $0.id == requestId }
//            print("✅ 실험실 개설 요청 거절 성공")
//        } catch {
//            handleError(error)
//        }
//    }
//    
    // MARK: - ========== 수거 요청 관련 ==========
    
    // MARK: - ✅ 수거 요청 생성
    func createPickupRequest(
        labId: Int,
        requestDate: String,
        disposalItemIds: [Int]
    ) async -> Bool {
        guard let token = token else {
            handleError(NetworkError.unauthorized)
            return false
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await LabService.createPickupRequest(
                labId: labId,
                requesterId: 3,  // 임시로 3 사용
                requestDate: requestDate,
                disposalItemIds: disposalItemIds,
                token: token
            )
            print("✅ 수거 요청 생성 성공: pickupRequestId=\(response.pickupRequestId), status=\(response.status)")
            
            // 요청 생성 후 목록 새로고침
            await fetchMyPickupRequests()
            return true
        } catch {
            handleError(error)
            return false
        }
    }
    
    // MARK: - ✅ 수거 요청 취소
    func cancelPickupRequest(pickupRequestId: Int) async -> Bool {
        guard let token = token else {
            handleError(NetworkError.unauthorized)
            return false
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await LabService.cancelPickupRequest(
                pickupRequestId: pickupRequestId,
                token: token
            )
            print("✅ 수거 요청 취소 성공: pickupRequestId=\(response.pickupRequestId), status=\(response.status)")
            
            // 취소 후 목록 새로고침
            await fetchMyPickupRequests()
            return true
        } catch {
            handleError(error)
            return false
        }
    }
    
    // MARK: - ✅ 내 수거 요청 전체 조회
    func fetchMyPickupRequests() async {
        guard let token = token else {
            handleError(NetworkError.unauthorized)
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            pickupRequests = try await LabService.fetchMyPickupRequests(token: token)
            print("✅ 내 수거 요청 전체 조회 성공: \(pickupRequests.count)개")
        } catch {
            handleError(error)
            pickupRequests = []
        }
    }
    
    // MARK: - ✅ 내 수거 요청 상태별 필터링 조회
    func fetchMyPickupRequestsByStatus(status: PickupRequestStatus) async {
        guard let token = token else {
            handleError(NetworkError.unauthorized)
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            if status == .all {
                // 전체 조회
                pickupRequests = try await LabService.fetchMyPickupRequests(token: token)
                print("✅ 내 수거 요청 전체 조회 성공: \(pickupRequests.count)개")
            } else {
                // 상태별 조회
                pickupRequests = try await LabService.fetchMyPickupRequestsByStatus(
                    status: status.rawValue,
                    token: token
                )
                print("✅ 내 수거 요청 필터링 조회 성공 (status=\(status.rawValue)): \(pickupRequests.count)개")
            }
        } catch {
            handleError(error)
            pickupRequests = []
        }
    }
    
    // MARK: - ✅ 특정 수거 요청 상세 조회
    func fetchPickupRequestDetail(pickupRequestId: Int) async {
        guard let token = token else {
            handleError(NetworkError.unauthorized)
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            selectedPickupDetail = try await LabService.fetchPickupRequestDetail(
                pickupRequestId: pickupRequestId,
                token: token
            )
            print("✅ 수거 요청 상세 조회 성공: requestId=\(pickupRequestId)")
        } catch {
            handleError(error)
            selectedPickupDetail = nil
        }
    }
    
    // MARK: - 실험실 검색 필터링 (모든 역할)
    func filteredLabs(searchText: String) -> [Lab] {
        guard !searchText.isEmpty else { return labs }
        return labs.filter { lab in
            lab.name.localizedCaseInsensitiveContains(searchText) ||
            lab.location.localizedCaseInsensitiveContains(searchText)
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
        print("❌ LabViewModel Error: \(errorMessage ?? "Unknown")")
    }
}
