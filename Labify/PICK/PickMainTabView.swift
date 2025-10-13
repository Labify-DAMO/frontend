//
//  PickMainTabView.swift
//  Labify
//
//  Created by F_s on 9/29/25.
//

import SwiftUI

struct PickMainTabView: View {
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
	PickMainTabView()
}
