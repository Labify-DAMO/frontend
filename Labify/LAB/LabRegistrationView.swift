//
//  LabRegistrationView.swift
//  Labify
//
//  Created by KITS on 10/13/25.
//

import SwiftUI

struct LabRegistrationView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedCategory = "감염성"
    @State private var manualCategory = ""
    @State private var confidence = 82
    @State private var showingCamera = false
    @State private var navigateToWeight = false
    
    let categories = ["감염성", "화학", "일반"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 카메라 영역
                cameraSection
                
                ScrollView {
                    VStack(spacing: 24) {
                        // AI 분류 결과
                        aiClassificationSection
                        
                        // 수동 분류
                        manualClassificationSection
                    }
                    .padding(20)
                    .padding(.bottom, 100)
                }
            }
            .background(Color.white)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.primary)
                            .font(.system(size: 17, weight: .semibold))
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("폐기물을 촬영하세요")
                        .font(.system(size: 17, weight: .semibold))
                }
            }
            .safeAreaInset(edge: .bottom) {
                nextButton
            }
            .navigationDestination(isPresented: $navigateToWeight) {
                WeightInputView()
            }
        }
    }
    
    private var cameraSection: some View {
            GeometryReader { geometry in
                let size = min(geometry.size.width - 40, geometry.size.height - 40)
                
                ZStack {
                    // 배경 그라데이션
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 255/255, green: 255/255, blue: 255/255).opacity(0.9),
                                    Color(red: 113/255, green: 100/255, blue: 230/255).opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: size, height: size)
                    
                    // 점선 테두리
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(style: StrokeStyle(lineWidth: 3, dash: [12, 8]))
                        .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255).opacity(0.4))
                        .frame(width: size, height: size)
                    
                    // 카메라 버튼
                    Button(action: {
                        showingCamera = true
                    }) {
                        VStack(spacing: 16) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(red: 30/255, green: 59/255, blue: 207/255).opacity(0.15))
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 36))
                                    .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(height: 400)
            .padding(.top, 20)
        }
    private var aiClassificationSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    WasteCategoryButton(
                        title: category,
                        isSelected: selectedCategory == category,
                        isGradient: true
                    ) {
                        selectedCategory = category
                    }
                }
            }
            
            Text("신뢰도 \(confidence)%")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
    }
    
    private var manualClassificationSection: some View {
        VStack(spacing: 16) {
            Text("수동 분류")
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(red: 244/255, green: 247/255, blue: 255/255))
                .cornerRadius(12)
            
            HStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    WasteCategoryButton(
                        title: category,
                        isSelected: manualCategory == category,
                        isGradient: false
                    ) {
                        manualCategory = category
                    }
                }
            }
        }
    }
    
    private var nextButton: some View {
        Button(action: {
            navigateToWeight = true
        }) {
            Text("다음")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    LinearGradient(
                        colors: [Color(red: 30/255, green: 59/255, blue: 207/255),
                                 Color(red: 113/255, green: 100/255, blue: 230/255)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(16)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white)
    }
}

struct WasteCategoryButton: View {
    let title: String
    let isSelected: Bool
    let isGradient: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isSelected ? .white : .primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(buttonBackground)
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(isSelected ? Color.clear : Color.gray.opacity(0.25), lineWidth: 1)
                )
        }
    }
    
    private var buttonBackground: some View {
        Group {
            if isSelected && isGradient {
                LinearGradient(
                    colors: [Color(red: 30/255, green: 59/255, blue: 207/255),
                             Color(red: 113/255, green: 100/255, blue: 230/255)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            } else if isSelected {
                LinearGradient(
                    colors: [Color.white, Color.white],
                    startPoint: .top,
                    endPoint: .bottom
                )
            } else {
                LinearGradient(
                    colors: [Color.white, Color.white],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
    }
}

#Preview {
    LabRegistrationView()
}
