//
//  MyPageView.swift
//  Labify
//
//  Created by F_S on 10/14/25.
//

import SwiftUI

struct MyPageView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.gray.opacity(0.4))
                    .padding()
                
                Text("마이 페이지")
                    .font(.title2)
                    .foregroundColor(.gray)
                
                Spacer()
            }
            .padding(.top, 50)
            .navigationTitle("MY")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    MyPageView()
}
