//
//  FilterChip.swift
//  Labify
//
//  Created by F_S on 10/30/25.
//


import SwiftUI

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                
                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(isSelected ? .white : .blue)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(isSelected ? Color.white.opacity(0.3) : Color.blue.opacity(0.1))
                                                .cornerRadius(8)
                                        }
                                    }
                                    .foregroundColor(isSelected ? .white : .primary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(
                                        isSelected ?
                                        LinearGradient(
                                            colors: [
                                                Color(red: 30/255, green: 59/255, blue: 207/255),
                                                Color(red: 113/255, green: 100/255, blue: 230/255)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ) :
                                        LinearGradient(colors: [Color.white], startPoint: .leading, endPoint: .trailing)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                                    .cornerRadius(20)
                                    .shadow(color: isSelected ? Color(red: 30/255, green: 59/255, blue: 207/255).opacity(0.3) : .clear, radius: 8, y: 4)
                                }
                            }
                        }
