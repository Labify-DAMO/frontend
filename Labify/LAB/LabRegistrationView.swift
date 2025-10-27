//
//  LabRegistrationView.swift
//  Labify
//
//  Created by F_S on 10/13/25.
//

import SwiftUI
import PhotosUI

struct LabRegistrationView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = WasteViewModel()
    
    @State private var selectedCategory = ""
    @State private var manualCategory = ""
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var showingActionSheet = false
    @State private var selectedImage: UIImage?
    @State private var showingImageConfirm = false
    @State private var capturedImage: UIImage?
    @State private var navigateToWeight = false
    @State private var isAnalyzing = false
    @State private var showManualClassification = false
    @State private var isImageExpanded = true
    
    let categories = ["감염성", "화학", "일반"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 카메라 영역
                WasteCameraSection(
                    selectedImage: $selectedImage,
                    isImageExpanded: $isImageExpanded,
                    showingActionSheet: $showingActionSheet,
                    onReset: resetClassification
                )
                
                ScrollView {
                    VStack(spacing: 24) {
                        // AI 분류 결과
                        if let result = viewModel.aiClassifyResult {
                            AIResultSection(
                                result: result,
                                isImageExpanded: isImageExpanded,
                                onCollapseImage: {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        isImageExpanded = false
                                    }
                                }
                            )
                        }
                        
                        // 분석 중 표시
                        if isAnalyzing {
                            AnalyzingSection()
                        }
                        
                        // AI 분류 시작 버튼
                        if selectedImage != nil && viewModel.aiClassifyResult == nil && !isAnalyzing {
                            analyzeButton
                        }
                        
                        // 수동 분류 버튼 및 섹션
                        if viewModel.aiClassifyResult != nil {
                            manualClassificationToggle
                        }
                        
                        if showManualClassification {
                            ManualClassificationSection(
                                categories: categories,
                                selectedCategory: $manualCategory
                            )
                        }
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
                    Text("폐기물 등록")
                        .font(.system(size: 17, weight: .semibold))
                }
            }
            .safeAreaInset(edge: .bottom) {
                nextButton
            }
            .navigationDestination(isPresented: $navigateToWeight) {
                WeightInputView(aiResult: viewModel.aiClassifyResult, manualCategory: manualCategory)
            }
            .sheet(isPresented: $showingActionSheet) {
                ImageSourceSheet(
                    showingCamera: $showingCamera,
                    showingImagePicker: $showingImagePicker,
                    isPresented: $showingActionSheet
                )
                .presentationDetents([.height(200)])
                .presentationDragIndicator(.visible)
            }
            .fullScreenCover(isPresented: $showingCamera) {
                CameraView(capturedImage: $capturedImage)
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage)
            }
            .fullScreenCover(isPresented: $showingImageConfirm) {
                if let image = capturedImage {
                    ImageConfirmView(
                        image: image,
                        onConfirm: {
                            selectedImage = image
                            showingImageConfirm = false
                            capturedImage = nil
                        },
                        onRetake: {
                            showingImageConfirm = false
                            capturedImage = nil
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                showingCamera = true
                            }
                        },
                        onCancel: {
                            showingImageConfirm = false
                            capturedImage = nil
                        }
                    )
                }
            }
            .onChange(of: capturedImage) { newImage in
                if newImage != nil {
                    showingImageConfirm = true
                }
            }
            .alert("오류", isPresented: $viewModel.showError) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "알 수 없는 오류가 발생했습니다.")
            }
        }
    }
    
    private var analyzeButton: some View {
        Button(action: {
            if let image = selectedImage {
                classifyImage(image)
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.system(size: 18, weight: .semibold))
                Text("AI로 폐기물 분류하기")
                    .font(.system(size: 17, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    colors: [Color(red: 30/255, green: 59/255, blue: 207/255),
                             Color(red: 113/255, green: 100/255, blue: 230/255)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
        }
    }
    
    private var manualClassificationToggle: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                showManualClassification.toggle()
            }
        }) {
            HStack {
                Image(systemName: "hand.tap")
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
                
                Text("수동으로 분류 변경하기")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: showManualClassification ? "chevron.up" : "chevron.down")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 244/255, green: 247/255, blue: 255/255))
            )
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
        .disabled(viewModel.aiClassifyResult == nil && manualCategory.isEmpty)
        .opacity((viewModel.aiClassifyResult == nil && manualCategory.isEmpty) ? 0.5 : 1.0)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white)
    }
    
    // MARK: - Helper Methods
    
    private func resetClassification() {
        viewModel.aiClassifyResult = nil
        showManualClassification = false
        manualCategory = ""
        selectedCategory = ""
        selectedImage = nil
        isImageExpanded = true
    }
    
    private func classifyImage(_ image: UIImage) {
        isAnalyzing = true
        
        Task {
            guard let compressedData = compressImage(image) else {
                isAnalyzing = false
                return
            }
            
            print("📦 Compressed image size: \(compressedData.count) bytes")
            
            await viewModel.classifyWasteWithAI(imageData: compressedData)
            isAnalyzing = false
        }
    }
    
    private func compressImage(_ image: UIImage) -> Data? {
        let maxSize: CGFloat = 800
        let maxFileSize = 900_000
        
        print("📸 Original image size: \(image.size.width)x\(image.size.height)")
        
        var resizedImage = image
        if image.size.width > maxSize || image.size.height > maxSize {
            let ratio = min(maxSize / image.size.width, maxSize / image.size.height)
            let newSize = CGSize(width: image.size.width * ratio, height: image.size.height * ratio)
            
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.draw(in: CGRect(origin: .zero, size: newSize))
            resizedImage = UIGraphicsGetImageFromCurrentImageContext() ?? image
            UIGraphicsEndImageContext()
            
            print("🔍 Resized to: \(newSize.width)x\(newSize.height)")
        }
        
        var compression: CGFloat = 0.7
        var imageData = resizedImage.jpegData(compressionQuality: compression)
        
        var attempts = 0
        while let data = imageData, data.count > maxFileSize && compression > 0.1 {
            compression -= 0.1
            imageData = resizedImage.jpegData(compressionQuality: compression)
            attempts += 1
            
            if attempts > 10 {
                print("⚠️ Maximum compression attempts reached")
                break
            }
        }
        
        if let finalData = imageData {
            let sizeInKB = Double(finalData.count) / 1024.0
            print("✅ Final compressed size: \(String(format: "%.1f", sizeInKB))KB (quality: \(Int(compression * 100))%)")
            
            if finalData.count > maxFileSize {
                print("⚠️ Warning: File size (\(String(format: "%.1f", sizeInKB))KB) still exceeds limit")
            }
        }
        
        return imageData
    }
}

#Preview {
    LabRegistrationView()
}
