//
//  PickTabView.swift
//  Labify
//
//  Created by F_S on 10/14/25.
//

import SwiftUI

struct PickTabView: View {
    let userInfo: UserInfo
    @ObservedObject var authVM: AuthViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TodayMapView()
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("오늘")
                }
                .tag(0)
            
            ScheduleListView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("예정")
                }
                .tag(1)
            
            QRScanTabView()
                .tabItem {
                    Image(systemName: "qrcode.viewfinder")
                    Text("QR")
                }
                .tag(2)
            
//            HistoryAndProfileView()
            MyPageView()
                .tabItem {
                    Label("MY", systemImage: "person.fill")
                }
                .tag(3)
        }
        .accentColor(Color(red: 30/255, green: 59/255, blue: 207/255))
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
