//
//  ImageHelpers.swift
//  Labify
//
//  Created by F_S on 10/27/25.
//

import SwiftUI

// MARK: - 이미지 확인 뷰
struct ImageConfirmView: View {
    let image: UIImage
    let onConfirm: () -> Void
    let onRetake: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
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
                
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Spacer()
                
                HStack(spacing: 40) {
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

// MARK: - 이미지 피커
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
