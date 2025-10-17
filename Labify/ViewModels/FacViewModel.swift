//
//  FacViewModel.swift
//  Labify
//
//  Created by F_S on 10/15/25.
//

import Foundation
import SwiftUI

@MainActor
class FacViewModel: ObservableObject {
    @Published var labs: [Lab] = []
    @Published var labRequests: [LabRequest] = []
    @Published var facilities: [Facility] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    //    private var token: String {
    //        // TODO: 실제 토큰 가져오기 (KeychainHelper 등)
    //        return KeychainHelper.shared.getToken() ?? ""
    //    }
    private var token: String {
        TokenStore.read() ?? ""
    }
    
    
    // MARK: - 실험실 목록 조회
    func fetchLabs() async {
        isLoading = true
        errorMessage = nil
        
        do {
            labs = try await FacService.fetchLabs(token: token)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            print("❌ Failed to fetch labs: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - 실험실 등록
    func registerLab(name: String, location: String, facilityId: Int) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let request = RegisterLabRequest(
                name: name,
                location: location,
                facilityId: facilityId
            )
            let newLab = try await FacService.registerLab(request: request, token: token)
            labs.append(newLab)
            return true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            print("❌ Failed to register lab: \(error)")
            return false
        }
    }
    
    // MARK: - 실험실 정보 수정
    func updateLab(labId: Int, name: String, location: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let request = UpdateLabRequest(name: name, location: location)
            let updatedLab = try await FacService.updateLab(
                labId: labId,
                request: request,
                token: token
            )
            
            if let index = labs.firstIndex(where: { $0.id == labId }) {
                labs[index] = updatedLab
            }
            return true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            print("❌ Failed to update lab: \(error)")
            return false
        }
    }
    
    // MARK: - 실험실 개설 요청 목록 조회
    func fetchLabRequests() async {
        errorMessage = nil
        
        do {
            labRequests = try await FacService.fetchLabRequests(token: token)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            print("❌ Failed to fetch lab requests: \(error)")
        }
    }
    
    // MARK: - 실험실 개설 요청 승인
    func confirmLabRequest(requestId: Int) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let newLab = try await FacService.confirmLabRequest(requestId: requestId, token: token)
            labs.append(newLab)
            labRequests.removeAll { $0.id == requestId }
            return true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            print("❌ Failed to confirm lab request: \(error)")
            return false
        }
    }
    
    // MARK: - 실험실 개설 요청 거절
    func rejectLabRequest(requestId: Int) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await FacService.rejectLabRequest(requestId: requestId, token: token)
            labRequests.removeAll { $0.id == requestId }
            return true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            print("❌ Failed to reject lab request: \(error)")
            return false
        }
    }
    
    // MARK: - 시설 등록
    func registerFacility(name: String, type: String, address: String, managerId: Int) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let request = RegisterFacilityRequest(
                name: name,
                type: type,
                address: address,
                managerId: managerId
            )
            let newFacility = try await FacService.registerFacility(request: request, token: token)
            facilities.append(newFacility)
            return true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            print("❌ Failed to register facility: \(error)")
            return false
        }
    }
    
    // MARK: - 시설 목록 조회
    func fetchFacilities() async {
        isLoading = true
        errorMessage = nil
        
        do {
            facilities = try await FacService.fetchFacilities(token: token)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            print("❌ Failed to fetch facilities: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - 검색 필터링
    func filteredLabs(searchText: String) -> [Lab] {
        if searchText.isEmpty {
            return labs
        }
        return labs.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.location.localizedCaseInsensitiveContains(searchText)
        }
    }
}
