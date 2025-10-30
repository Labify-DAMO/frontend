//
//  WeightInputView.swift
//  Labify
//
//  Created by KITS on 10/14/25.
//

import SwiftUI

struct WeightInputView: View {
    @Environment(\.dismiss) var dismiss
    @State private var weight: Double = 0.0
    @State private var unit = "kg"
    @State private var note = ""
    @State private var navigateToSummary = false
    
    let aiResult: AIClassifyResponse?
    let manualCategory: String?
    let onComplete: () -> Void
    
    private var isWeightValid: Bool {
        weight > 0
    }
    
    private var nextButtonGradient: LinearGradient {
        if isWeightValid {
            return LinearGradient(
                colors: [
                    Color(red: 30/255, green: 59/255, blue: 207/255),
                    Color(red: 113/255, green: 100/255, blue: 230/255)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        } else {
            return LinearGradient(
                colors: [Color.gray, Color.gray],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
    
    private var weightInputCard: some View {
        VStack(spacing: 12) {
            HStack(alignment: .center) {
                Text(String(format: "%.1f", weight))
                    .font(.system(size: 56, weight: .regular))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        // 직접 입력 기능 추가 가능
                    }
                
                unitToggle
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            
            if !isWeightValid {
                errorMessage
            }
        }
        .background(Color(red: 244/255, green: 247/255, blue: 255/255))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    Color(red: 30/255, green: 59/255, blue: 207/255).opacity(0.3),
                    lineWidth: 1.5
                )
        )
    }
    
    private var unitToggle: some View {
        HStack(spacing: 0) {
            Button(action: {
                unit = "kg"
            }) {
                Text("kg")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(unit == "kg" ? .white : .primary)
                    .frame(width: 60, height: 44)
                    .background(unit == "kg" ? Color(red: 30/255, green: 59/255, blue: 207/255) : Color.clear)
                    .cornerRadius(22)
            }
            
            Button(action: {
                unit = "L"
            }) {
                Text("L")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(unit == "L" ? .white : .primary)
                    .frame(width: 60, height: 44)
                    .background(unit == "L" ? Color(red: 30/255, green: 59/255, blue: 207/255) : Color.clear)
                    .cornerRadius(22)
            }
        }
        .background(Color.white)
        .cornerRadius(22)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var errorMessage: some View {
        HStack(spacing: 6) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
                .font(.system(size: 14))
            Text("0 이상의 값을 입력해주세요.")
                .font(.system(size: 14))
                .foregroundColor(.red)
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
    }
    
    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("비고")
                .font(.system(size: 16, weight: .semibold))
            
            ZStack(alignment: .topLeading) {
                if note.isEmpty {
                    Text("특이사항 입력")
                        .foregroundColor(.gray.opacity(0.6))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                }
                
                TextEditor(text: $note)
                    .frame(height: 140)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .scrollContentBackground(.hidden)
                    .background(Color.white)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                    )
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            weightInputCard
            
            HStack(spacing: 12) {
                QuickSelectButton(value: 0.5, weight: $weight)
                QuickSelectButton(value: 1.0, weight: $weight)
                QuickSelectButton(value: 1.5, weight: $weight)
            }
            
            noteSection
            
            Spacer()
            
            Button(action: {
                navigateToSummary = true
            }) {
                Text("다음")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(nextButtonGradient)
                    .cornerRadius(16)
            }
            .disabled(!isWeightValid)
        }
        .padding(20)
        .background(Color.white)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary)
                        .font(.system(size: 17, weight: .semibold))
                }
            }
            ToolbarItem(placement: .principal) {
                Text("무게를 입력하세요")
                    .font(.system(size: 17, weight: .semibold))
            }
        }
        .navigationDestination(isPresented: $navigateToSummary) {
            WasteSummaryView(
                weight: weight,
                unit: unit,
                memo: note,
                aiResult: aiResult,
                manualCategory: manualCategory,
                onComplete: onComplete
            )
        }
    }
}

struct QuickSelectButton: View {
    let value: Double
    @Binding var weight: Double
    
    var body: some View {
        Button(action: {
            weight += value
        }) {
            Text(String(format: "%.1f", value))
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.white)
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                )
        }
    }
}

#Preview {
    NavigationStack {
        WeightInputView(
            aiResult: nil,
            manualCategory: "화학",
            onComplete: {}
        )
    }
}
