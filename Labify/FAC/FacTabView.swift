//
//  FacTabView.swift
//  Labify
//
//  Created by KITS on 10/14/25.
//

import SwiftUI

// MARK: - 시설 관리자 탭뷰
struct FacTabView: View {
    let userInfo: UserInfo
    @ObservedObject var authVM: AuthViewModel
    
    var body: some View {
        TabView {
            FacManagementView(userInfo: userInfo)
                .tabItem {
                    Label("관리", systemImage: "list.bullet")
                }
            
            FacKPIView()
                .tabItem {
                    Label("KPI", systemImage: "chart.bar.fill")
                }
            
            PredictionView()
                .tabItem {
                    Label("예측", systemImage: "calendar")
                }
            
            MyPageView()
                .tabItem {
                    Label("MY", systemImage: "person.fill")
                }
        }
        .accentColor(.blue)
    }
}

// MARK: - Preview
#Preview {
    FacTabView(
        userInfo: UserInfo(
            userId: 3,
            name: "이시설",
            email: "facility@test.com",
            role: "FACILITY_MANAGER",
            affiliation: "종합관리센터"
        ),
        authVM: AuthViewModel()
    )
}
