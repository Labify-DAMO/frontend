//
//  EmailVerificationViewModel.swift
//  Labify
//
//  Created by F_s on 10/2/25.
//

import SwiftUI

@MainActor
class EmailVerificationViewModel: ObservableObject {
	@Published var errorMessage: String?
	@Published var successMessage: String?
	@Published var isLoading = false
	@Published var resendCooldown = 0
	
	private var cooldownTimer: Timer?
	
	func verifyCode(email: String, code: String) async {
		guard !code.isEmpty else {
			errorMessage = "Please enter verification code"
			return
		}
		
		isLoading = true
		errorMessage = nil
		successMessage = nil
		
		do {
			let url = URL(string: "YOUR_API_BASE_URL/api/auth/verify-code")!
			var request = URLRequest(url: url)
			request.httpMethod = "POST"
			request.setValue("application/json", forHTTPHeaderField: "Content-Type")
			
			let body: [String: String] = [
				"email": email,
				"code": code
			]
			request.httpBody = try JSONEncoder().encode(body)
			
			let (_, response) = try await URLSession.shared.data(for: request)
			
			guard let httpResponse = response as? HTTPURLResponse else {
				errorMessage = "Invalid response"
				isLoading = false
				return
			}
			
			if httpResponse.statusCode == 200 {
				successMessage = "Email verified successfully!"
				isLoading = false
				// 로그인 화면으로 이동 또는 자동 로그인 로직 추가
			} else if httpResponse.statusCode == 400 {
				errorMessage = "Invalid or expired verification code"
				isLoading = false
			} else {
				errorMessage = "Verification failed. Please try again."
				isLoading = false
			}
		} catch {
			errorMessage = "Network error: \(error.localizedDescription)"
			isLoading = false
		}
	}
	
	func resendCode(email: String) async {
		isLoading = true
		errorMessage = nil
		successMessage = nil
		
		do {
			let url = URL(string: "YOUR_API_BASE_URL/api/auth/send-code")!
			var request = URLRequest(url: url)
			request.httpMethod = "POST"
			request.setValue("application/json", forHTTPHeaderField: "Content-Type")
			
			let body: [String: String] = ["email": email]
			request.httpBody = try JSONEncoder().encode(body)
			
			let (_, response) = try await URLSession.shared.data(for: request)
			
			guard let httpResponse = response as? HTTPURLResponse else {
				errorMessage = "Invalid response"
				isLoading = false
				return
			}
			
			if httpResponse.statusCode == 200 {
				successMessage = "Verification code sent!"
				startCooldown()
				isLoading = false
			} else {
				errorMessage = "Failed to resend code. Please try again."
				isLoading = false
			}
		} catch {
			errorMessage = "Network error: \(error.localizedDescription)"
			isLoading = false
		}
	}
	
	private func startCooldown() {
		resendCooldown = 60
		cooldownTimer?.invalidate()
		cooldownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
			guard let self = self else {
				timer.invalidate()
				return
			}
			
			if self.resendCooldown > 0 {
				self.resendCooldown -= 1
			} else {
				timer.invalidate()
			}
		}
	}
	
	deinit {
		cooldownTimer?.invalidate()
	}
}
