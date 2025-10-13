//
//  AuthViewModel.swift
//  Labify
//
//  Created by F_s on 9/22/25.
//

import SwiftUI

class AuthViewModel: ObservableObject {
	@Published var email = ""
	@Published var password = ""
	@Published var isLoading = false
	@Published var errorMessage: String?
	@Published var isAuthenticated = false
	
	// 토큰 저장
	@Published var accessToken: String?
	@Published var refreshToken: String?
	
	func login() {
		// 입력 검증
		guard !email.isEmpty else {
			errorMessage = "이메일을 입력해주세요."
			return
		}
		
		guard !password.isEmpty else {
			errorMessage = "비밀번호를 입력해주세요."
			return
		}
		
		// 로딩 시작
		isLoading = true
		errorMessage = nil
		
		// 비동기 API 호출
		Task {
			do {
				let response = try await NetworkManager.shared.login(email: email, password: password)
				
				// 메인 스레드에서 UI 업데이트
				await MainActor.run {
					self.accessToken = response.accessToken
					self.refreshToken = response.refreshToken
					self.isAuthenticated = true
					self.isLoading = false
					
					print("✅ 로그인 성공!")
					print("Access Token 저장됨: \(response.accessToken)")
				}
				
			} catch {
				// 에러 처리
				await MainActor.run {
					self.isLoading = false
					self.errorMessage = error.localizedDescription
					print("❌ 로그인 실패: \(error.localizedDescription)")
				}
			}
		}
	}
	
	func logout() {
		isAuthenticated = false
		accessToken = nil
		refreshToken = nil
		email = ""
		password = ""
		errorMessage = nil
	}
}
