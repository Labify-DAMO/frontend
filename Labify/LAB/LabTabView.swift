//
//  LabTabView.swift
//  Labify
//
//  Created by KITS on 10/13/25.
//

import SwiftUI

struct LabTabView: View {
    var body: some View {
        TabView {
            LabDashboardView()
                .tabItem {
                    Label("대시보드", systemImage: "square.grid.2x2")
                }
            
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
    LabTabView()
}
