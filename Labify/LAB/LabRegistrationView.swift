//
//  LabRegistrationView.swift
//  Labify
//
//  Created by KITS on 10/13/25.
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
    
    let categories = ["감염성", "화학", "일반"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 카메라 영역
                cameraSection
                
                ScrollView {
                    VStack(spacing: 24) {
                        // AI 분류 결과
                        if let result = viewModel.aiClassifyResult {
                            aiResultSection(result: result)
                        }
                        
                        // 분석 중 표시
                        if isAnalyzing {
                            analyzingSection
                        }
                        
                        // AI 분류 시작 버튼 (이미지만 선택하고 아직 분석 안 한 경우)
                        if selectedImage != nil && viewModel.aiClassifyResult == nil && !isAnalyzing {
                            analyzeButton
                        }
                        
                        // 수동 분류 버튼 및 섹션
                        if viewModel.aiClassifyResult != nil {
                            manualClassificationToggle
                        }
                        
                        if showManualClassification {
                            manualClassificationSection
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
                WeightInputView()
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
    
    private var cameraSection: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width - 40, geometry.size.height - 40)
            
            ZStack {
                if let image = selectedImage {
                    // 선택된 이미지 표시
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: size, height: size)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color(red: 30/255, green: 59/255, blue: 207/255), lineWidth: 3)
                        )
                    
                    // 재촬영 버튼
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                // 결과 초기화
                                viewModel.aiClassifyResult = nil
                                showManualClassification = false
                                manualCategory = ""
                                selectedCategory = ""
                                selectedImage = nil
                                showingActionSheet = true
                            }) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                                    .background(Color.black.opacity(0.6))
                                    .clipShape(Circle())
                            }
                            .padding(12)
                        }
                        Spacer()
                    }
                } else {
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
                        showingActionSheet = true
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
                            
                            Text("폐기물 촬영")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: 400)
        .padding(.top, 20)
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
    
    private var analyzingSection: some View {
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
    
    private func aiResultSection(result: AIClassifyResponse) -> some View {
        VStack(spacing: 20) {
            // 헤더
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.green)
                
                Text("AI 분류 완료")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(spacing: 16) {
                // 대분류 (Coarse)
                ClassificationRow(
                    icon: "square.grid.2x2",
                    title: "대분류",
                    value: result.displayCoarse,
                    color: Color(red: 30/255, green: 59/255, blue: 207/255)
                )
                
                Divider()
                    .padding(.horizontal, 8)
                
                // 세분류 (Fine)
                ClassificationRow(
                    icon: "list.bullet.rectangle",
                    title: "세분류",
                    value: result.displayFine,
                    color: Color(red: 113/255, green: 100/255, blue: 230/255)
                )
                
                Divider()
                    .padding(.horizontal, 8)
                
                // 생물학적 폐기물 여부
                ClassificationRow(
                    icon: result.is_bio ? "cross.circle.fill" : "cross.circle",
                    title: "생물학적 위험",
                    value: result.is_bio ? "예" : "아니오",
                    color: result.is_bio ? .red : .gray
                )
                
                // OCR 텍스트 (있는 경우)
                if result.is_ocr, let ocrText = result.ocr_text, !ocrText.isEmpty {
                    Divider()
                        .padding(.horizontal, 8)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.system(size: 16))
                                .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
                            
                            Text("감지된 텍스트")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                        
                        Text(ocrText)
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
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
            )
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
    
    private var manualClassificationSection: some View {
        VStack(spacing: 16) {
            Text("원하는 분류를 선택하세요")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    ManualCategoryButton(
                        title: category,
                        isSelected: manualCategory == category
                    ) {
                        manualCategory = category
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
        )
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
    
    // MARK: - 이미지 분류 핸들러
    private func classifyImage(_ image: UIImage) {
        isAnalyzing = true
        
        Task {
            // 이미지 리사이즈 및 압축
            guard let compressedData = compressImage(image) else {
                isAnalyzing = false
                return
            }
            
            print("📦 Compressed image size: \(compressedData.count) bytes")
            
            await viewModel.classifyWasteWithAI(imageData: compressedData)
            isAnalyzing = false
        }
    }
    
    // 이미지 압축 (백엔드 제한에 맞춤)
    private func compressImage(_ image: UIImage) -> Data? {
        // 백엔드 기본 제한이 1MB일 경우를 대비해 안전하게 압축
        let maxSize: CGFloat = 800 // AI 분석에 충분한 크기
        let maxFileSize = 900_000 // 900KB (여유있게)
        
        print("📸 Original image size: \(image.size.width)x\(image.size.height)")
        
        // 1단계: 이미지 리사이즈
        var resizedImage = image
        if image.size.width > maxSize || image.size.height > maxSize {
            let ratio = min(maxSize / image.size.width, maxSize / image.size.height)
            let newSize = CGSize(width: image.size.width * ratio, height: image.size.height * ratio)
            
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.draw(in: CGRect(origin: .zero, size: newSize))
            resizedImage = UIGraphicsGetImageFromCurrentImageContext() ?? image
            UIGraphicsEndImageContext()
            
            print("📏 Resized to: \(newSize.width)x\(newSize.height)")
        }
        
        // 2단계: 품질 조정하면서 압축
        var compression: CGFloat = 0.7 // 시작 품질
        var imageData = resizedImage.jpegData(compressionQuality: compression)
        
        var attempts = 0
        while let data = imageData, data.count > maxFileSize && compression > 0.1 {
            compression -= 0.1
            imageData = resizedImage.jpegData(compressionQuality: compression)
            attempts += 1
            
            if attempts > 10 { // 무한 루프 방지
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

// MARK: - 분류 정보 행
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

// MARK: - 수동 분류 버튼
struct ManualCategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        isSelected ?
                        LinearGradient(
                            colors: [Color(red: 30/255, green: 59/255, blue: 207/255),
                                     Color(red: 113/255, green: 100/255, blue: 230/255)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ) :
                        LinearGradient(
                            colors: [Color(red: 244/255, green: 247/255, blue: 255/255),
                                     Color(red: 244/255, green: 247/255, blue: 255/255)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.clear : Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

// MARK: - 이미지 확인 뷰 (카카오톡 스타일)
struct ImageConfirmView: View {
    let image: UIImage
    let onConfirm: () -> Void
    let onRetake: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                // 상단 취소 버튼
                HStack {
                    Button(action: onCancel) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                Spacer()
                
                // 이미지
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Spacer()
                
                // 하단 버튼들
                HStack(spacing: 40) {
                    // 다시 찍기
                    Button(action: onRetake) {
                        VStack(spacing: 8) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 28))
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())
                            
                            Text("다시 찍기")
                                .font(.system(size: 13))
                                .foregroundColor(.white)
                        }
                    }
                    
                    // 사용하기
                    Button(action: onConfirm) {
                        VStack(spacing: 8) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color(red: 30/255, green: 59/255, blue: 207/255))
                                .clipShape(Circle())
                            
                            Text("사용하기")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - 이미지 소스 선택 시트
struct ImageSourceSheet: View {
    @Binding var showingCamera: Bool
    @Binding var showingImagePicker: Bool
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // 카메라로 촬영하기
            Button(action: {
                isPresented = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showingCamera = true
                }
            }) {
                HStack(spacing: 16) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 22))
                        .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
                        .frame(width: 32)
                    
                    Text("카메라로 촬영하기")
                        .font(.system(size: 17))
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(Color.white)
            }
            
            Divider()
                .padding(.leading, 72)
            
            // 갤러리에서 선택하기
            Button(action: {
                isPresented = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showingImagePicker = true
                }
            }) {
                HStack(spacing: 16) {
                    Image(systemName: "photo.fill")
                        .font(.system(size: 22))
                        .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
                        .frame(width: 32)
                    
                    Text("갤러리에서 선택하기")
                        .font(.system(size: 17))
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(Color.white)
            }
        }
        .background(Color(UIColor.systemBackground))
    }
}

// MARK: - 카메라 뷰
struct CameraView: UIViewControllerRepresentable {
    @Binding var capturedImage: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.capturedImage = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - 이미지 피커 (갤러리)
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    LabRegistrationView()
}
