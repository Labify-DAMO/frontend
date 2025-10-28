//
//  RoleBasedInitialView.swift
//  Labify
//
//  Created by F_S on 10/24/25.
//

import SwiftUI

struct RoleBasedInitialView: View {
    let userInfo: UserInfo
    @ObservedObject var authVM: AuthViewModel
    
    @StateObject private var facViewModel = FacViewModel()
    @State private var isCheckingFacility = true
    @State private var facilityCheckCompleted = false
    
    var body: some View {
        Group {
            if isCheckingFacility {
                // 시설 정보 확인 중
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("시설 정보를 확인하는 중...")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
            } else {
                // 시설 확인 완료 후 적절한 화면으로 이동
                destinationView
            }
        }
        .task {
            await checkFacilityStatus()
        }
    }
    
    @ViewBuilder
    private var destinationView: some View {
        switch userInfo.role {
        case "LAB_MANAGER":
            labManagerFlow
        case "FACILITY_MANAGER":
            facilityManagerFlow
        case "PICKUP_MANAGER":
            pickupManagerFlow
        default:
            Text("알 수 없는 역할입니다")
        }
    }
    
    @ViewBuilder
    private var labManagerFlow: some View {
        if facViewModel.hasFacility {
            // 시설 있음 → 메인 화면
            LabTabView(userInfo: userInfo, authVM: authVM)
        } else {
            //LabTabView(userInfo: userInfo, authVM: authVM)
            // 시설 없음 → 시설 가입 요청 화면
            InitialFacilityRequestView(userInfo: userInfo)
        }
    }
    
    @ViewBuilder
    private var facilityManagerFlow: some View {
        if facViewModel.hasFacility {
            // 시설 있음 → 메인 화면
            FacTabView(userInfo: userInfo, authVM: authVM)
        } else {
            // 시설 없음 → 시설 등록 화면
            InitialFacilityRegisterView(
                userInfo: userInfo,
                isCompleted: $facilityCheckCompleted
            )
            .onChange(of: facilityCheckCompleted) { completed in
                if completed {
                    // 등록 완료 후 다시 체크
                    Task {
                        await checkFacilityStatus()
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var pickupManagerFlow: some View {
        if facViewModel.hasFacility {
            // 시설 있음 → 메인 화면
            PickTabView(userInfo: userInfo, authVM: authVM)
        } else {
            // 시설 없음 → 시설 등록 화면
            InitialFacilityRegisterView(
                userInfo: userInfo,
                isCompleted: $facilityCheckCompleted
            )
            .onChange(of: facilityCheckCompleted) { completed in
                if completed {
                    // 등록 완료 후 다시 체크
                    Task {
                        await checkFacilityStatus()
                    }
                }
            }
        }
    }
    
    private func checkFacilityStatus() async {
        isCheckingFacility = true
        await facViewModel.fetchFacilityInfo()
        isCheckingFacility = false
        
        print("🔍 시설 확인 결과: hasFacility=\(facViewModel.hasFacility)")
    }
}

#Preview {
    RoleBasedInitialView(
        userInfo: UserInfo(
            userId: 2,
            name: "김실험",
            email: "lab@test.com",
            role: "LAB_MANAGER"
            //affiliation: "테스트 연구소"
        ),
        authVM: AuthViewModel()
    )
}
