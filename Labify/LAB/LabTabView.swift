//
//  LabTabView.swift
//  Labify
//
//  Created by KITS on 10/13/25.
//

import SwiftUI

struct LabTabView: View {
    let userInfo: UserInfo
    @ObservedObject var authVM: AuthViewModel
    
    var body: some View {
        TabView {
            LabDashboardView()
                .tabItem {
                    Label("대시보드", systemImage: "square.grid.2x2")
                }
//            QRCodeView()
//                .tabItem {
//                    Label("QR 코드", systemImage: "qrcode")
//                }
            LabRegistrationView()
                .tabItem {
                    Label("등록", systemImage: "plus.circle")
                }
            
            LabHistoryView()
                .tabItem {
                    Label("이력", systemImage: "clock")
                }
            
            MyPageView()
                .tabItem {
                    Label("MY", systemImage: "person")
                }
        }
        .accentColor(.blue)
    }
}

#Preview {
    LabTabView(
        userInfo: UserInfo(
            userId: 2,
            name: "김실험",
            email: "facility@test.com",
            role: "LAB_MANAGER"
            //affiliation: "종합관리센터"
        ),
        authVM: AuthViewModel()
    )
}
