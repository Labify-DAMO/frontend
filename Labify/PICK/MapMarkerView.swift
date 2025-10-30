//
//  MapMarkerView.swift
//  Labify
//
//  Created by F_S on 10/30/25.
//

import SwiftUI

struct MapMarkerView: View {
    let number: Int
    let status: String
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            if isSelected {
                Circle()
                    .fill(markerColor.opacity(0.2))
                    .frame(width: 70, height: 70)
            }
            
            ZStack {
                Circle()
                    .fill(markerColor)
                    .frame(width: 50, height: 50)
                
                if status == "COMPLETED" {
                    Image(systemName: "checkmark")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Text("\(number)")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .shadow(color: markerColor.opacity(0.4), radius: 8, y: 4)
            .scaleEffect(isSelected ? 1.2 : 1.0)
        }
    }
    
    private var markerColor: Color {
        switch status {
        case "COMPLETED": return .green
        case "PROCESSING": return Color(red: 30/255, green: 59/255, blue: 207/255)
        case "REQUESTED": return .orange
        case "CANCELED": return .red
        default: return .gray
        }
    }
}
