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
    @Published var facilityJoinRequests: [FacilityJoinRequestItem] = []
    @Published var facilityRelations: [FacilityRelation] = []
    @Published var pickupFacilities: [Facility] = []
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    
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
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            print("❌ Failed to register lab: \(error)")
            isLoading = false
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
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            print("❌ Failed to update lab: \(error)")
            isLoading = false
            return false
        }
    }
    
    // MARK: - 실험실 개설 요청 목록 조회
    func fetchLabRequests() async {
        isLoading = true
        errorMessage = nil
        
        do {
            labRequests = try await FacService.fetchLabRequests(token: token)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            print("❌ Failed to fetch lab requests: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - 실험실 개설 요청 승인
    func confirmLabRequest(requestId: Int) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let newLab = try await FacService.confirmLabRequest(requestId: requestId, token: token)
            labs.append(newLab)
            labRequests.removeAll { $0.id == requestId }
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            print("❌ Failed to confirm lab request: \(error)")
            isLoading = false
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
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            print("❌ Failed to reject lab request: \(error)")
            isLoading = false
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
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            print("❌ Failed to register facility: \(error)")
            isLoading = false
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
    
    // MARK: - 시설 가입 요청 목록 조회
//    func fetchFacilityJoinRequests() async {
//        isLoading = true
//        errorMessage = nil
//        
//        do {
//            facilityJoinRequests = try await FacService.fetchFacilityJoinRequests(token: token)
//        } catch {
//            errorMessage = error.localizedDescription
//            showError = true
//            print("❌ Failed to fetch facility join requests: \(error)")
//        }
//        
//        isLoading = false
//    }

    // MARK: - 시설 가입 요청
    func requestFacilityJoin(userId: Int, facilityCode: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await FacService.requestFacilityJoin(
                userId: userId,
                facilityCode: facilityCode,
                token: token
            )
            print("✅ 시설 가입 요청 성공: requestId=\(response.requestId), status=\(response.status)")
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            print("❌ Failed to request facility join: \(error)")
            isLoading = false
            return false
        }
    }
    
    
    
    // MARK: - 시설 가입 요청 수락
    func confirmFacilityJoinRequest(requestId: Int) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await FacService.confirmFacilityJoinRequest(
                requestId: requestId,
                token: token
            )
            facilityJoinRequests.removeAll { $0.id == requestId }
            print("✅ Facility join request confirmed: \(response)")
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            print("❌ Failed to confirm facility join request: \(error)")
            isLoading = false
            return false
        }
    }
    
    // MARK: - 시설 가입 요청 거절
    func rejectFacilityJoinRequest(requestId: Int) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await FacService.rejectFacilityJoinRequest(
                requestId: requestId,
                token: token
            )
            facilityJoinRequests.removeAll { $0.id == requestId }
            print("✅ Facility join request rejected: \(response)")
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            print("❌ Failed to reject facility join request: \(error)")
            isLoading = false
            return false
        }
    }
    
    // MARK: - 연구소-수거업체 관계 목록
    func fetchFacilityRelations() async {
        isLoading = true
        errorMessage = nil
        
        do {
            facilityRelations = try await FacService.fetchFacilityRelations(token: token)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            print("❌ Failed to fetch facility relations: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - 연구소-수거업체 관계 생성
    func createFacilityRelation(labFacilityId: Int, pickupFacilityId: Int) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let request = CreateRelationRequest(
                labFacilityId: labFacilityId,
                pickupFacilityId: pickupFacilityId
            )
            let newRelation = try await FacService.createFacilityRelation(
                request: request,
                token: token
            )
            
            // 관계 목록 새로고침
            await fetchFacilityRelations()
            
            print("✅ Facility relation created: \(newRelation)")
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            print("❌ Failed to create facility relation: \(error)")
            isLoading = false
            return false
        }
    }
    
    // MARK: - 연구소-수거업체 관계 삭제
    func deleteFacilityRelation(relationshipId: Int) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            try await FacService.deleteFacilityRelation(
                relationshipId: relationshipId,
                token: token
            )
            facilityRelations.removeAll { $0.id == relationshipId }
            print("✅ Facility relation deleted")
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            print("❌ Failed to delete facility relation: \(error)")
            isLoading = false
            return false
        }
    }
    
    // MARK: - 수거업체 목록 조회 (관계 생성용)
    func fetchPickupFacilities() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // 전체 시설 중 type이 "PICKUP"인 것만 필터링
            let allFacilities = try await FacService.fetchFacilities(token: token)
            pickupFacilities = allFacilities.filter { $0.type == "PICKUP" }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            print("❌ Failed to fetch pickup facilities: \(error)")
        }
        
        isLoading = false
    }
}
