//
//  PickTabView.swift
//  Labify
//
//  Created by KITS on 10/14/25.
//

import SwiftUI

struct PickTabView: View {
    let userInfo: UserInfo
    @ObservedObject var authVM: AuthViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            PickupScheduleView()
                .tabItem {
                    Image(systemName: "shippingbox")
                    Text("수거예정")
                }
                .tag(0)
            
            PickupScannerView()
                .tabItem {
                    Image(systemName: "qrcode")
                    Text("QR")
                }
                .tag(1)
            
            TodayProgressView()
                .tabItem {
                    Image(systemName: "camera")
                    Text("진행")
                }
                .tag(2)
            
            MyPageView()
                .tabItem {
                    Image(systemName: "person")
                    Text("MY")
                }
                .tag(3)
        }
        .accentColor(.blue)
    }
}

#Preview {
    PickTabView(
        userInfo: UserInfo(
        userId: 2,
        name: "김수거",
        email: "pickup_user@test.com",
        role: "PICKUP_MANAGER"
        //affiliation: "햄햄수거업체"
    ),
    authVM: AuthViewModel()
    )
}
