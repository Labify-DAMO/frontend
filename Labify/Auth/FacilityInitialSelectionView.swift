//
//  FacilityInitialSelectionView.swift
//  Labify
//
//  Created by F_S on 10/29/25.
//

import SwiftUI

struct FacilityInitialSelectionView: View {
    let userInfo: UserInfo
    @ObservedObject var authVM: AuthViewModel
    
    @State private var navigateToRegister = false
    @State private var navigateToJoin = false
    @State private var navigateToMain = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // 상단 타이틀
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(red: 30/255, green: 59/255, blue: 207/255),
                                                 Color(red: 113/255, green: 100/255, blue: 230/255)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                                .shadow(color: Color(red: 30/255, green: 59/255, blue: 207/255).opacity(0.3), radius: 20, x: 0, y: 8)
                            
                            Image(systemName: "building.2.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: 8) {
                            Text("시설 설정")
                                .font(.system(size: 32, weight: .bold))
                            
                            Text("시설을 등록하거나 기존 시설에 가입하세요")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top, 60)
                    .padding(.bottom, 50)
                    
                    // 선택 버튼들
                    VStack(spacing: 16) {
                        // 시설 등록
                        Button {
                            navigateToRegister = true
                        } label: {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color(red: 244/255, green: 247/255, blue: 255/255))
                                        .frame(width: 56, height: 56)
                                    
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
                                }
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("새 시설 등록")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.primary)
                                    Text("새로운 시설을 생성하고 관리합니다")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.gray)
                            }
                            .padding(20)
                            .background(Color.white)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
                        }
                        .buttonStyle(.plain)
                        
                        // 시설 가입
                        Button {
                            navigateToJoin = true
                        } label: {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color(red: 244/255, green: 247/255, blue: 255/255))
                                        .frame(width: 56, height: 56)
                                    
                                    Image(systemName: "person.badge.plus.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
                                }
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("기존 시설 가입")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.primary)
                                    Text("시설 코드로 기존 시설에 가입 요청합니다")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.gray)
                            }
                            .padding(20)
                            .background(Color.white)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
                        }
                        .buttonStyle(.plain)
                        
                        // 구분선
                        HStack {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 1)
                            
                            Text("또는")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .padding(.horizontal, 12)
                            
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 1)
                        }
                        .padding(.vertical, 8)
                        
                        // 이미 등록되어있습니다
                        Button {
                            navigateToMain = true
                        } label: {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color.green.opacity(0.1))
                                        .frame(width: 56, height: 56)
                                    
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(.green)
                                }
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("이미 등록되어 있습니다")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.primary)
                                    Text("등록된 시설로 바로 이동합니다")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.gray)
                            }
                            .padding(20)
                            .background(Color.white)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.green.opacity(0.3), lineWidth: 1.5)
                            )
                            .shadow(color: Color.green.opacity(0.1), radius: 10, x: 0, y: 4)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer(minLength: 60)
                }
                .padding(.bottom, 40)
            }
            .background(Color(red: 249/255, green: 250/255, blue: 252/255))
            .navigationDestination(isPresented: $navigateToRegister) {
                FacilityRegisterView(userInfo: userInfo, authVM: authVM)
            }
            .navigationDestination(isPresented: $navigateToJoin) {
                FacilityJoinView(userInfo: userInfo, authVM: authVM)
            }
            .navigationDestination(isPresented: $navigateToMain) {
                destinationViewForRole
            }
        }
    }
    
    @ViewBuilder
    private var destinationViewForRole: some View {
        switch userInfo.role {
        case "FACILITY_MANAGER":
            FacTabView(userInfo: userInfo, authVM: authVM)
        case "LAB_MANAGER":
            LabTabView(userInfo: userInfo, authVM: authVM)
        case "PICKUP_MANAGER":
            PickTabView(userInfo: userInfo, authVM: authVM)
        default:
            Text("알 수 없는 역할입니다")
        }
    }
}

#Preview {
    FacilityInitialSelectionView(
        userInfo: UserInfo(
            userId: 1,
            name: "테스트",
            email: "test@test.com",
            role: "LAB_MANAGER"
        ),
        authVM: AuthViewModel()
    )
}
