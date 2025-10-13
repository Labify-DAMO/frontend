//
//  SignUpView.swift
//  Labify
//
//  Created by F_s on 9/22/25.
//

import SwiftUI

struct SignupView: View {
	@StateObject private var vm = AuthViewModel()
	@State private var showVerification = false
	@Environment(\.dismiss) var dismiss
	
	var body: some View {
		VStack(spacing: 16) {
			Text("Sign Up")
				.font(.largeTitle)
				.bold()
				.padding(.bottom, 20)
			
			TextField("Email", text: $vm.email)
				.textFieldStyle(RoundedBorderTextFieldStyle())
				.autocapitalization(.none)
				.keyboardType(.emailAddress)
			
			SecureField("Password", text: $vm.password)
				.textFieldStyle(RoundedBorderTextFieldStyle())
			
			if let error = vm.errorMessage {
				Text(error)
					.foregroundColor(.red)
					.font(.footnote)
			}
			
			Button("Create Account") {
				Task {
					let success = await vm.signup()
					if success {
						showVerification = true
					}
				}
			}
			.buttonStyle(.borderedProminent)
			.padding(.top, 8)
			.disabled(vm.isLoading)
			
			if vm.isLoading {
				ProgressView()
			}
			
			Button("Back to Login") {
				dismiss()
			}
			.font(.footnote)
			.padding(.top, 4)
		}
		.padding()
		.navigationDestination(isPresented: $showVerification) {
			EmailVerificationView(email: vm.email)
		}
	}
}

#Preview {
	SignupView()
}
