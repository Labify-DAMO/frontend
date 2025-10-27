//
//  AIResultSection.swift
//  Labify
//
//  Created by F_S on 10/27/25.
//

import SwiftUI

struct AIResultSection: View {
    let result: AIClassifyResponse
    let isImageExpanded: Bool
    let onCollapseImage: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.green)
                
                Text("AI 분류 완료")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                if isImageExpanded {
                    Button(action: onCollapseImage) {
                        HStack(spacing: 6) {
                            Text("이미지 접기")
                                .font(.system(size: 14))
                                .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
                            
                            Image(systemName: "chevron.up")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(red: 30/255, green: 59/255, blue: 207/255).opacity(0.1))
                        )
                    }
                }
            }
            
            VStack(spacing: 16) {
                ClassificationRow(
                    icon: "square.grid.2x2",
                    title: "대분류",
                    value: result.displayCoarse,
                    color: Color(red: 30/255, green: 59/255, blue: 207/255)
                )
                
                Divider()
                    .padding(.horizontal, 8)
                
                ClassificationRow(
                    icon: "list.bullet.rectangle",
                    title: "세분류",
                    value: result.displayFine,
                    color: Color(red: 113/255, green: 100/255, blue: 230/255)
                )
                
                Divider()
                    .padding(.horizontal, 8)
                
                ClassificationRow(
                    icon: result.is_bio ? "cross.circle.fill" : "cross.circle",
                    title: "생물학적 위험",
                    value: result.is_bio ? "예" : "아니오",
                    color: result.is_bio ? .red : .gray
                )
                
                if result.is_ocr, let ocrText = result.ocr_text, !ocrText.isEmpty {
                    Divider()
                        .padding(.horizontal, 8)
                    
                    OCRTextView(text: ocrText)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
            )
        }
    }
}

struct OCRTextView: View {
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
                
                Text("감지된 텍스트")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.primary)
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
        .padding(.top, 4)
    }
}

struct ClassificationRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                
                Text(value)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
    }
}
