//
//  AuthService.swift
//  Labify
//
//  Created by F_s on 9/22/25.
//

import Foundation

class AuthService {
	private let baseURL = "http://localhost:8080/api/auth" // Spring Boot 서버 URL
	
	func login(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
		guard let url = URL(string: "\(baseURL)/login") else { return }
		
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		
		let body: [String: Any] = ["email": email, "password": password]
		request.httpBody = try? JSONSerialization.data(withJSONObject: body)
		
		URLSession.shared.dataTask(with: request) { data, response, error in
			if let error = error {
				completion(.failure(error))
				return
			}
			guard let data = data else { return }
			
			do {
				// 서버에서 JWT 토큰이나 세션 ID 반환한다고 가정
				if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
					let token = json["token"] as? String {
					completion(.success(token))
				} else {
					completion(.failure(NSError(domain: "InvalidResponse", code: -1)))
				}
			} catch {
				completion(.failure(error))
			}
		}.resume()
	}
	
	func signup(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
		guard let url = URL(string: "\(baseURL)/signup") else { return }
		
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		
		let body: [String: Any] = ["email": email, "password": password]
		request.httpBody = try? JSONSerialization.data(withJSONObject: body)
		
		URLSession.shared.dataTask(with: request) { _, _, error in
			if let error = error {
				completion(.failure(error))
			} else {
				completion(.success(()))
			}
		}.resume()
	}
}
