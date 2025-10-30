//
//  FacViewModel.swift
//  Labify
//
//  Created by F_S on 10/15/25.
//

import Foundation
import SwiftUI

@MainActor
final class FacViewModel: ObservableObject {

    // MARK: - Published Properties
    
    // 시설/연구실/관계
    @Published var facilityInfo: Facility?
    @Published var facilityId: Int?
    @Published var hasFacility = false
    
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showError = false

    @Published var facilityJoinRequests: [FacilityJoinRequestItem] = []
    @Published var labs: [Lab] = []
    @Published var labRequests: [LabRequestItem] = []
    @Published var facilityRelations: [FacilityRelation] = []
    @Published var pickupFacilities: [Facility] = []

    // ✅ 가입 요청 결과
    @Published var joinRequestId: Int?
    
    // 시설 코드로 수거업체 조회
    @Published var searchedPickupFacility: Facility?
    
    // MARK: - Token
    
    private var token: String? {
        UserDefaults.standard.string(forKey: "accessToken")
    }
    
    // MARK: - 시설 관련 함수
    
    /// ✅ 내 시설 정보(배정된 1개)를 읽어와 facilityId를 세팅
    func fetchFacilityInfo() async {
        guard let token = token, !token.isEmpty else {
            print("❌ 토큰이 없습니다.")
            return
        }
        
        print("🔍 시설 정보 조회 시작...")
        isLoading = true
        defer { isLoading = false }

        do {
            let facility = try await FacService.fetchFacilities(token: token)
            facilityInfo = facility
            facilityId = facility.id
            hasFacility = true
            print("✅ 시설 정보 로드 성공: \(facility.name) (ID: \(facility.id))")
        } catch {
            print("⚠️ 시설 정보 조회 중 에러 발생: \(error)")
            
            if let networkError = error as? NetworkError {
                switch networkError {
                case .httpError(let statusCode):
                    print("📊 HTTP 상태 코드: \(statusCode)")
                    if statusCode == 404 || statusCode == 500 {
                        print("⚠️ 아직 소속된 시설이 없습니다. (Status: \(statusCode))")
                        facilityInfo = nil
                        facilityId = nil
                        hasFacility = false
                    } else {
                        errorMessage = "시설 정보를 불러올 수 없습니다. (\(statusCode))"
                        showError = true
                        print("❌ 시설 정보 로드 실패: HTTP \(statusCode)")
                    }
                case .noData:
                    print("⚠️ 시설 데이터가 없습니다.")
                    facilityInfo = nil
                    facilityId = nil
                    hasFacility = false
                case .decodingError:
                    print("❌ 데이터 파싱 실패")
                    errorMessage = "시설 정보 형식이 올바르지 않습니다."
                    showError = true
                default:
                    print("❌ 네트워크 에러: \(networkError.localizedDescription)")
                    errorMessage = networkError.localizedDescription
                    showError = true
                }
            } else {
                print("❌ 알 수 없는 에러: \(error.localizedDescription)")
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
    
    /// ✅ 시설 등록
    func registerFacility(name: String, type: String, address: String) async -> Bool {
        guard let token = token, !token.isEmpty else {
            errorMessage = "인증 토큰이 없습니다."
            showError = true
            return false
        }
        
        isLoading = true
        defer { isLoading = false }

        do {
            let req = RegisterFacilityRequest(
                name: name,
                type: type,
                address: address
            )
            let created = try await FacService.registerFacility(request: req, token: token)
            
            self.facilityInfo = created
            self.facilityId = created.id
            self.hasFacility = true
            
            print("✅ 시설 등록 성공: \(created.name) (ID: \(created.id), Code: \(created.facilityCode))")
            return true
        } catch {
            self.errorMessage = "시설 등록 실패: \(error.localizedDescription)"
            self.showError = true
            print("❌ 시설 등록 실패: \(error)")
            return false
        }
    }
    
    /// ✅ 시설 가입 요청
    func requestFacilityJoin(userId: Int, facilityCode: String) async -> Bool {
        guard let token = token, !token.isEmpty else {
            errorMessage = "인증 토큰이 없습니다."
            showError = true
            return false
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await FacService.requestFacilityJoin(
                userId: userId,
                facilityCode: facilityCode,
                token: token
            )
            
            // ✅ 단일 객체에서 직접 requestId 추출
            self.joinRequestId = response.requestId
            print("✅ 시설 가입 요청 성공: requestId=\(response.requestId), status=\(response.status)")
            
            return true
        } catch {
            self.errorMessage = "시설 가입 요청 실패: \(error.localizedDescription)"
            self.showError = true
            print("❌ 시설 가입 요청 실패: \(error)")
            return false
        }
    }
    
    /// ✅ 시설 가입 요청 목록 조회 (status 파라미터 추가)
    func fetchFacilityJoinRequests(status: String = "PENDING") async {
        guard let token = token, !token.isEmpty else {
            errorMessage = "인증 토큰이 없습니다."
            showError = true
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        do {
            let response = try await FacService.fetchFacilityJoinRequests(
                status: status,
                token: token
            )
            facilityJoinRequests = response.requests
            print("✅ 시설 가입 요청 목록 불러오기 성공: \(response.count)건")
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            print("❌ Failed to fetch facility join requests: \(error)")
        }
        
        isLoading = false
    }
    
    /// ✅ 시설 가입 요청 수락 (응답 타입 변경)
    func confirmFacilityJoinRequest(requestId: Int) async -> Bool {
        guard let token = token, !token.isEmpty else {
            errorMessage = "인증 토큰이 없습니다."
            showError = true
            return false
        }
        
        isLoading = true
        errorMessage = ""
        
        do {
            let response = try await FacService.confirmFacilityJoinRequest(
                requestId: requestId,
                token: token
            )
            facilityJoinRequests.removeAll { $0.id == requestId }
            print("✅ Facility join request confirmed - requestId: \(response.requestId), userId: \(response.userId), facilityId: \(response.facilityId), facilityName: \(response.facilityName), status: \(response.status)")
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


    /// ✅ 시설 가입 요청 거절 (응답 타입 변경)
    func rejectFacilityJoinRequest(requestId: Int) async -> Bool {
        guard let token = token, !token.isEmpty else {
            errorMessage = "인증 토큰이 없습니다."
            showError = true
            return false
        }
        
        isLoading = true
        errorMessage = ""
        
        do {
            let response = try await FacService.rejectFacilityJoinRequest(
                requestId: requestId,
                token: token
            )
            facilityJoinRequests.removeAll { $0.id == requestId }
            print("✅ Facility join request rejected - requestId: \(response.requestId), status: \(response.status)")
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
    
    // MARK: - 실험실 관련 함수
    
    /// 실험실 목록 조회
    func fetchLabs() async {
        guard let token = token, !token.isEmpty else {
            errorMessage = "인증 토큰이 없습니다."
            showError = true
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        do {
            labs = try await FacService.fetchLabs(token: token)
            print("✅ 실험실 목록 조회 성공: \(labs.count)개")
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            print("❌ Failed to fetch labs: \(error)")
        }
        
        isLoading = false
    }
    
    /// 실험실 등록
    func registerLab(name: String, location: String, facilityId: Int) async -> Bool {
        guard let token = token, !token.isEmpty else {
            errorMessage = "인증 토큰이 없습니다."
            showError = true
            return false
        }
        
        isLoading = true
        errorMessage = ""
        
        do {
            let request = RegisterLabRequest(
                name: name,
                location: location,
                facilityId: facilityId
            )
            let newLab = try await FacService.registerLab(request: request, token: token)
            labs.append(newLab)
            print("✅ 실험실 등록 성공: \(newLab.name)")
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
    
    /// 실험실 정보 수정
    func updateLab(labId: Int, name: String, location: String) async -> Bool {
        guard let token = token, !token.isEmpty else {
            errorMessage = "인증 토큰이 없습니다."
            showError = true
            return false
        }
        
        isLoading = true
        errorMessage = ""
        
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
            print("✅ 실험실 수정 성공: \(updatedLab.name)")
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
    
    /// ✅ 실험실 개설 요청 목록 조회 (status 파라미터 추가)
    func fetchLabRequests(status: String = "PENDING") async {
        guard let token = token, !token.isEmpty else {
            errorMessage = "인증 토큰이 없습니다."
            showError = true
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        do {
            let response = try await FacService.fetchLabRequests(
                status: status,
                token: token
            )
            // ✅ 불필요한 변환 제거 - 직접 할당
            labRequests = response.requests
            print("✅ 실험실 개설 요청 목록 조회 성공: \(response.count)건")
            print("📊 요청 목록: \(labRequests.map { "[\($0.id)] \($0.labName) - \($0.status)" })")
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            print("❌ Failed to fetch lab requests: \(error)")
        }
        
        isLoading = false
    }
    
    /// ✅ 실험실 개설 요청 승인 (응답 타입 변경)
    func confirmLabRequest(requestId: Int) async -> Bool {
        guard let token = token, !token.isEmpty else {
            errorMessage = "인증 토큰이 없습니다."
            showError = true
            return false
        }
        
        isLoading = true
        errorMessage = ""
        
        do {
            let response = try await FacService.confirmLabRequest(requestId: requestId, token: token)
            // ✅ LabConfirmResponse를 Lab으로 변환
            let newLab = Lab(
                id: response.labId,
                name: response.name,
                location: response.location,
                facilityId: response.facilityId
            )
            labs.append(newLab)
            labRequests.removeAll { $0.id == requestId }
            print("✅ 실험실 개설 요청 승인 성공 - labId: \(response.labId), name: \(response.name)")
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
    
    /// ✅ 실험실 개설 요청 거절 (변경 없음)
    func rejectLabRequest(requestId: Int) async -> Bool {
        guard let token = token, !token.isEmpty else {
            errorMessage = "인증 토큰이 없습니다."
            showError = true
            return false
        }
        
        isLoading = true
        errorMessage = ""
        
        do {
            let response = try await FacService.rejectLabRequest(requestId: requestId, token: token)
            labRequests.removeAll { $0.id == requestId }
            print("✅ 실험실 개설 요청 거절 성공 - requestId: \(response.requestId), status: \(response.status)")
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
    
    /// 검색 필터링
    func filteredLabs(searchText: String) -> [Lab] {
        if searchText.isEmpty {
            return labs
        }
        return labs.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.location.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    // MARK: - 시설 관계 관련 함수
    
    /// 시설 코드로 수거업체 조회
    func searchFacilityByCode(facilityCode: String) async -> Bool {
        guard let token = token, !token.isEmpty else {
            errorMessage = "인증 토큰이 없습니다."
            showError = true
            return false
        }
        
        isLoading = true
        errorMessage = ""
        
        do {
            searchedPickupFacility = try await FacService.searchFacilityByCode(
                facilityCode: facilityCode,
                token: token
            )
            print("✅ 수거업체 조회 성공: \(searchedPickupFacility?.name ?? "")")
            isLoading = false
            return true
        } catch {
            errorMessage = "시설 코드를 찾을 수 없습니다."
            showError = true
            print("❌ Failed to search facility: \(error)")
            isLoading = false
            return false
        }
    }
    

    /// 연구소-수거업체 관계 목록
//    func fetchFacilityRelations() async {
//        guard let token = token, !token.isEmpty else {
//            errorMessage = "인증 토큰이 없습니다."
//            showError = true
//            return
//        }
//
//        isLoading = true
//        errorMessage = ""
//
//        do {
//            facilityRelations = try await FacService.fetchFacilityRelations(token: token)
//            print("✅ 시설 관계 목록 조회 성공: \(facilityRelations.count)건")
//        } catch {
//            errorMessage = error.localizedDescription
//            showError = true
//            print("❌ Failed to fetch facility relations: \(error)")
//        }
//
//        isLoading = false
//    }
    
    /// 연구소-수거업체 관계 생성
    func createFacilityRelation(labFacilityId: Int, pickupFacilityId: Int) async -> Bool {
        guard let token = token, !token.isEmpty else {
            errorMessage = "인증 토큰이 없습니다."
            showError = true
            return false
        }
        
        isLoading = true
        errorMessage = ""
        
        do {
            let request = CreateRelationRequest(
                labFacilityId: labFacilityId,
                pickupFacilityId: pickupFacilityId
            )
            let newRelation = try await FacService.createFacilityRelation(
                request: request,
                token: token
            )
            
           // await fetchFacilityRelations()
            
            print("✅ Facility relation created: relationshipId=\(newRelation.relationshipId)")
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
    
    /// 연구소-수거업체 관계 삭제
    func deleteFacilityRelation(relationshipId: Int) async -> Bool {
        guard let token = token, !token.isEmpty else {
            errorMessage = "인증 토큰이 없습니다."
            showError = true
            return false
        }
        
        isLoading = true
        errorMessage = ""
        
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
    
//    /// 수거업체 목록 조회
//    func fetchPickupFacilities() async {
//        guard let token = token, !token.isEmpty else {
//            errorMessage = "인증 토큰이 없습니다."
//            showError = true
//            return
//        }
//
//        isLoading = true
//        errorMessage = ""
//
//        do {
//            pickupFacilities = try await FacService.fetchPickupFacilities(token: token)
//            print("✅ 수거업체 목록 조회 성공: \(pickupFacilities.count)개")
//        } catch {
//            errorMessage = error.localizedDescription
//            showError = true
//            print("❌ Failed to fetch pickup facilities: \(error)")
//        }
//
//        isLoading = false
//    }
}
