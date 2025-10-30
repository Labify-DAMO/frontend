//
//  ScanHistoryCard.swift
//  Labify
//
//  Created by F_S on 10/30/25.
//


import SwiftUI

struct ScanHistoryCard: View {
    let history: MockScanHistory
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "qrcode")
                    .font(.system(size: 24))
                    .foregroundColor(.green)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(history.labName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                HStack(spacing: 8) {
                    Label("\(history.disposalCount)건", systemImage: "shippingbox.fill")
                        .font(.system(size: 13))
                        .foregroundColor(.orange)
                    
                    Text("·")
                        .foregroundColor(.gray)
                    
                    Text(history.scannedAt)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(.green)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
