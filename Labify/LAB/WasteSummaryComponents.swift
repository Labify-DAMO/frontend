//
//  WasteSummaryComponents.swift
//  Labify
//
//  Created by F_S on 10/28/25.
//

import SwiftUI

// MARK: - AI Info Row Component
struct AIInfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .frame(width: 70, alignment: .leading)
            
            Text(value)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Editable Row Component
struct EditableRow<Content: View>: View {
    let icon: String
    let title: String
    var isFirst: Bool = false
    var isLast: Bool = false
    let content: Content
    
    init(
        icon: String,
        title: String,
        isFirst: Bool = false,
        isLast: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.icon = icon
        self.title = title
        self.isFirst = isFirst
        self.isLast = isLast
        self.content = content()
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .frame(width: 60, alignment: .leading)
            
            Spacer()
            
            content
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

// MARK: - Quick Add Button Component
struct QuickAddButton: View {
    let value: Double
    @Binding var tempWeight: String
    
    var body: some View {
        Button(action: {
            let current = Double(tempWeight) ?? 0.0
            let new = current + value
            tempWeight = String(format: "%.1f", new)
        }) {
            HStack {
                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .semibold))
                Text(String(format: "%.1f", value))
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(red: 30/255, green: 59/255, blue: 207/255).opacity(0.1))
            )
        }
    }
}

// MARK: - Preview
#Preview("AI Info Row") {
    VStack(spacing: 0) {
        AIInfoRow(title: "대분류", value: "sharps")
        Divider()
        AIInfoRow(title: "세분류", value: "syringe")
    }
    .background(Color.white)
    .cornerRadius(12)
    .padding()
}

#Preview("Editable Row") {
    VStack(spacing: 0) {
        EditableRow(icon: "square.grid.2x2", title: "카테고리", isFirst: true) {
            Text("선택")
                .font(.system(size: 15))
                .foregroundColor(.secondary)
        }
        Divider()
        EditableRow(icon: "scalemass", title: "무게", isLast: true) {
            Text("2.5 kg")
                .font(.system(size: 15, weight: .medium))
        }
    }
    .background(Color.white)
    .cornerRadius(12)
    .padding()
}
