//
//  AnalyzingSection.swift
//  Labify
//
//  Created by F_S on 10/27/25.
//

import SwiftUI

struct AnalyzingSection: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(Color(red: 30/255, green: 59/255, blue: 207/255))
                .padding(.bottom, 8)
            
            Text("AI가 폐기물을 분석하고 있습니다")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            Text("잠시만 기다려주세요...")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 244/255, green: 247/255, blue: 255/255))
        )
    }
}
