//
//  SplashView.swift
//  Labify
//
//  Created by F_s on 10/14/25.
//

import SwiftUI

struct SplashView: View {
    @State private var fadeOutColors = false
    @State private var slideUpButton = false
    @State private var showLogin = false
    @State private var loginSlideUp = false
    
    var body: some View {
        ZStack {
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            if showLogin {
                LoginView()
                    .opacity(loginSlideUp ? 1 : 0)
            }
            
            if !showLogin {
                VStack(spacing: 0) {
                    Spacer()
                    
                    Text("Labify")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(red: 30/255, green: 59/255, blue: 207/255),
                                         Color(red: 113/255, green: 100/255, blue: 230/255)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .opacity(fadeOutColors ? 0 : 1)
                    
                    Spacer()
                    
                    Button(action: startAnimation) {
                        ZStack {
                            // ✅ 상단 모서리만 둥근 사각형
                            RoundedCorner(radius: 40, corners: [.topLeft, .topRight])
                                .fill(
                                    LinearGradient(
                                        colors: [Color(red: 30/255, green: 59/255, blue: 207/255),
                                                 Color(red: 113/255, green: 100/255, blue: 230/255).opacity(0.7)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(
                                    width: UIScreen.main.bounds.width,
                                    height: slideUpButton ? UIScreen.main.bounds.height * 2.5 : 175
                                )
                                .opacity(fadeOutColors ? 0 : 1)
                            
                            Text("시작하기")
                                .font(.system(size: 32, weight: .semibold))
                                .foregroundColor(.white)
                                .offset(y: -30)
                                .opacity(fadeOutColors ? 0 : 1)
                        }
                    }
                    .offset(y: slideUpButton ? -UIScreen.main.bounds.height * 0.5 : 0)
                }
                .edgesIgnoringSafeArea(.bottom)
            }
        }
    }
    
    func startAnimation() {
        withAnimation(.easeOut(duration: 1.2)) {
            fadeOutColors = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.8)) {
                slideUpButton = true
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            showLogin = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeIn(duration: 0.6)) {
                loginSlideUp = true
            }
        }
    }
}

/// ✅ 특정 모서리만 둥글게 만드는 커스텀 Shape
struct RoundedCorner: Shape {
    var radius: CGFloat = 0
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    SplashView()
}
