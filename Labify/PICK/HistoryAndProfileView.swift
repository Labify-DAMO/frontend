//
//  HistoryAndProfileView.swift
//  Labify
//
//  Created by F_S on 10/30/25.
//

import SwiftUI

struct HistoryAndProfileView: View {
    @State private var selectedSegment = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("", selection: $selectedSegment) {
                    Text("처리 이력").tag(0)
                    Text("설정").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .background(Color.white)
                
                if selectedSegment == 0 {
                    HistoryTabView()
                } else {
                    MyPageView()
                }
            }
            .navigationTitle("MY")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
