//
//  WasteCameraSection.swift
//  Labify
//
//  Created by F_S on 10/27/25.
//

import SwiftUI

struct WasteCameraSection: View {
    @Binding var selectedImage: UIImage?
    @Binding var isImageExpanded: Bool
    @Binding var showingActionSheet: Bool
    let onReset: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            let expandedSize = min(geometry.size.width - 40, geometry.size.height - 40)
            
            ZStack {
                if let image = selectedImage {
                    if isImageExpanded {
                        ExpandedImageView(
                            image: image,
                            size: expandedSize,
                            onReset: onReset,
                            showingActionSheet: $showingActionSheet
                        )
                    } else {
                        CollapsedImageView(
                            image: image,
                            onExpand: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    isImageExpanded = true
                                }
                            },
                            onReset: onReset,
                            showingActionSheet: $showingActionSheet
                        )
                    }
                } else {
                    EmptyStateView(
                        size: expandedSize,
                        showingActionSheet: $showingActionSheet
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: (selectedImage != nil && !isImageExpanded) ? 120 : 400)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isImageExpanded)
        .padding(.top, 20)
    }
}

struct ExpandedImageView: View {
    let image: UIImage
    let size: CGFloat
    let onReset: () -> Void
    @Binding var showingActionSheet: Bool
    
    var body: some View {
        ZStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color(red: 30/255, green: 59/255, blue: 207/255), lineWidth: 3)
                )
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        onReset()
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
        }
    }
}

struct CollapsedImageView: View {
    let image: UIImage
    let onExpand: () -> Void
    let onReset: () -> Void
    @Binding var showingActionSheet: Bool
    
    var body: some View {
        Button(action: onExpand) {
            HStack(spacing: 16) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(red: 30/255, green: 59/255, blue: 207/255), lineWidth: 2)
                    )
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("폐기물 이미지")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("탭하여 확대")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                
                Button(action: {
                    onReset()
                    showingActionSheet = true
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
                        .frame(width: 40, height: 40)
                        .background(Color(red: 30/255, green: 59/255, blue: 207/255).opacity(0.1))
                        .clipShape(Circle())
                }
                .padding(.leading, 8)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
            )
            .padding(.horizontal, 20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EmptyStateView: View {
    let size: CGFloat
    @Binding var showingActionSheet: Bool
    
    var body: some View {
        ZStack {
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
            
            RoundedRectangle(cornerRadius: 24)
                .stroke(style: StrokeStyle(lineWidth: 3, dash: [12, 8]))
                .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255).opacity(0.4))
                .frame(width: size, height: size)
            
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
}
