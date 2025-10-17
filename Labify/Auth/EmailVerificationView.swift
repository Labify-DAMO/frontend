////
////  EmailVerificationView.swift
////  Labify
////
////  Created by F_s on 9/22/25.
////
//
//import SwiftUI
//
//struct EmailVerificationView: View {
//	let email: String
//	@StateObject private var vm = EmailVerificationViewModel()
//	@State private var verificationCode = ""
//	@Environment(\.dismiss) var dismiss
//	
//	var body: some View {
//		VStack(spacing: 20) {
//			Image(systemName: "envelope.badge.shield.half.filled")
//				.font(.system(size: 60))
//				.foregroundColor(.blue)
//				.padding(.bottom, 10)
//			
//			Text("Email Verification")
//				.font(.largeTitle)
//				.bold()
//			
//			Text("We sent a verification code to")
//				.font(.subheadline)
//				.foregroundColor(.secondary)
//			
//			Text(email)
//				.font(.subheadline)
//				.bold()
//				.padding(.bottom, 20)
//			
//			VStack(spacing: 12) {
//				TextField("Enter verification code", text: $verificationCode)
//					.textFieldStyle(RoundedBorderTextFieldStyle())
//					.keyboardType(.numberPad)
//					.multilineTextAlignment(.center)
//					.font(.title3)
//				
//				if let error = vm.errorMessage {
//					Text(error)
//						.foregroundColor(.red)
//						.font(.footnote)
//				}
//				
//				if let success = vm.successMessage {
//					Text(success)
//						.foregroundColor(.green)
//						.font(.footnote)
//				}
//			}
//			
//			Button("Verify") {
//				Task {
//					await vm.verifyCode(email: email, code: verificationCode)
//				}
//			}
//			.buttonStyle(.borderedProminent)
//			.padding(.top, 8)
//			.disabled(vm.isLoading || verificationCode.isEmpty)
//			
//			if vm.isLoading {
//				ProgressView()
//			}
//			
//			Divider()
//				.padding(.vertical, 10)
//			
//			VStack(spacing: 8) {
//				Text("Didn't receive the code?")
//					.font(.footnote)
//					.foregroundColor(.secondary)
//				
//				Button("Resend Code") {
//					Task {
//						await vm.resendCode(email: email)
//					}
//				}
//				.font(.footnote)
//				.disabled(vm.isLoading || vm.resendCooldown > 0)
//				
//				if vm.resendCooldown > 0 {
//					Text("Resend available in \(vm.resendCooldown)s")
//						.font(.caption)
//						.foregroundColor(.secondary)
//				}
//			}
//		}
//		.padding()
//		.navigationBarBackButtonHidden(true)
//	}
//}
//
//#Preview {
//	EmailVerificationView(email: "example@email.com")
//}
