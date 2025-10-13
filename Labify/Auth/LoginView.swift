//
//  LoginView.swift
//  Labify
//
//  Created by F_s on 9/22/25.
//

import SwiftUI

struct LoginView: View {
	@StateObject private var vm = AuthViewModel()
	@State private var showSignup = false
	@State private var rememberMe = false
	@State private var showPassword = false
	
	var body: some View {
		NavigationStack {
			VStack(spacing: 16) {
				Spacer()
				
				// 로고
				Text("Labify")
					.font(.system(size: 32, weight: .bold))
					.foregroundStyle(
						LinearGradient(
							colors: [Color(red: 30/255, green: 59/255, blue: 207/255), Color(red: 113/255, green: 100/255, blue: 230/255)],
							startPoint: .top,
							endPoint: .bottom
						)
					)
					.padding(.bottom, 50)
				
				// 이메일 입력
				TextField("이메일을 입력해주세요.", text: $vm.email)
					.padding()
					.background(Color(white: 0.96))
					.cornerRadius(10)
					.autocapitalization(.none)
					.keyboardType(.emailAddress)
				
				// 비밀번호 입력
				HStack {
					if showPassword {
						TextField("비밀번호를 입력해주세요.", text: $vm.password)
					} else {
						SecureField("비밀번호를 입력해주세요.", text: $vm.password)
					}
					
					Button(action: {
						showPassword.toggle()
					}) {
						Image(systemName: showPassword ? "eye.slash" : "eye")
							.foregroundColor(.gray)
					}
				}
				.padding()
				.background(Color(white: 0.96))
				.cornerRadius(10)
				
				// 자동 로그인, 아이디/비밀번호 찾기
				HStack {
					Button(action: {
						rememberMe.toggle()
					}) {
						HStack(spacing: 6) {
							ZStack {
								RoundedRectangle(cornerRadius: 4)
									.stroke(Color.gray.opacity(0.5), lineWidth: 1.5)
									.frame(width: 20, height: 20)
								
								if rememberMe {
									Image(systemName: "checkmark")
										.font(.system(size: 12, weight: .semibold))
										.foregroundColor(.blue)
								}
							}
							
							Text("자동 로그인")
								.font(.system(size: 14))
								.foregroundColor(.primary)
						}
					}
					
					Spacer()
					
					Button("아이디 찾기") {
						// TODO: 아이디 찾기 기능
					}
					.font(.system(size: 13))
					.foregroundColor(.gray)
					
					Text("|")
						.foregroundColor(.gray.opacity(0.5))
						.font(.system(size: 13))
					
					Button("비밀번호 찾기") {
						// TODO: 비밀번호 찾기 기능
					}
					.font(.system(size: 13))
					.foregroundColor(.gray)
				}
				.padding(.horizontal, 4)
				.padding(.top, 4)
				
				if let error = vm.errorMessage {
					Text(error)
						.foregroundColor(.red)
						.font(.footnote)
				}
				
				// 로그인 버튼
				Button(action: {
					vm.login()
				}) {
					Text("로그인")
						.font(.system(size: 17, weight: .semibold))
						.foregroundColor(.white)
						.frame(maxWidth: .infinity)
						.padding(.vertical, 16)
						.background(
							LinearGradient(
								colors: [Color(red: 30/255, green: 59/255, blue: 207/255), Color(red: 113/255, green: 100/255, blue: 230/255)],
								startPoint: .top,
								endPoint: .bottom
							)
						)
						.cornerRadius(10)
				}
				.disabled(vm.isLoading)
				.padding(.top, 8)
				
				if vm.isLoading {
					ProgressView()
				}
				
				// 또는 구분선
				HStack(spacing: 16) {
					Rectangle()
						.frame(height: 1)
						.foregroundColor(.gray.opacity(0.3))
					
					Text("또는")
						.font(.system(size: 13))
						.foregroundColor(.gray)
					
					Rectangle()
						.frame(height: 1)
						.foregroundColor(.gray.opacity(0.3))
				}
				.padding(.vertical, 16)
				
				// 회원가입 버튼
				Button(action: {
					showSignup = true
				}) {
					Text("회원가입")
						.font(.system(size: 17, weight: .semibold))
						.foregroundColor(.white)
						.frame(maxWidth: .infinity)
						.padding(.vertical, 16)
						.background(Color.black)
						.cornerRadius(10)
				}
				
				// 소셜 로그인 버튼들
				HStack(spacing: 16) {
					// Google 로그인
					Button(action: {
						// TODO: Google 로그인 연동
						print("Google login tapped")
					}) {
						Image("google_logo")
							.resizable()
							.scaledToFit()
							.frame(width: 56, height: 56)
							.clipShape(Circle())
					}
					
					// Naver 로그인
					Button(action: {
						// TODO: Naver 로그인 연동
						print("Naver login tapped")
					}) {
						Image("naver_logo")
							.resizable()
							.scaledToFit()
							.frame(width: 56, height: 56)
							.clipShape(Circle())
					}
					
					// Kakao 로그인
					Button(action: {
						// TODO: Kakao 로그인 연동
						print("Kakao login tapped")
					}) {
						Image("kakao_logo")
							.resizable()
							.scaledToFit()
							.frame(width: 56, height: 56)
							.clipShape(Circle())
					}
				}
				.padding(.top, 16)
				
				Spacer()
				Spacer()
			}
			.padding(.horizontal, 32)
			.navigationDestination(isPresented: $showSignup) {
				SignupView()
			}
		}
	}
}

#Preview {
	LoginView()
}
