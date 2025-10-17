import Foundation

struct AuthService {
    
    static let networkManager = NetworkManager.shared
    
    // MARK: - 회원가입
    static func signup(request: SignupRequest) async throws {
        let _: EmptyResponse = try await networkManager.request(
            endpoint: "/auth/signup",
            method: "POST",
            body: request
        )
    }
    
    // MARK: - 로그인
    static func login(request: LoginRequest) async throws -> TokenResponse {
        let response: TokenResponse = try await networkManager.request(
            endpoint: "/auth/login",
            method: "POST",
            body: request
        )
        return response
    }
    
    // MARK: - 토큰 재발급
    static func refreshToken(_ request: RefreshTokenRequest) async throws -> TokenResponse {
        let response: TokenResponse = try await networkManager.request(
            endpoint: "/auth/refresh",
            method: "POST",
            body: request
        )
        return response
    }
    
    // MARK: - 사용자 정보 조회
    static func getUserInfo(token: String) async throws -> UserInfo {
        let response: UserInfo = try await networkManager.request(
            endpoint: "/user/me",
            method: "GET",
            token: token
        )
        return response
    }
    
    // MARK: - 이메일 인증 코드 전송
    static func sendVerificationCode(email: String) async throws {
        let request = EmailRequest(email: email)
        let _: EmptyResponse = try await networkManager.request(
            endpoint: "/auth/send-code",
            method: "POST",
            body: request
        )
    }
    
    // MARK: - 인증 코드 확인
    static func verifyCode(request: VerifyCodeRequest) async throws {
        let _: EmptyResponse = try await networkManager.request(
            endpoint: "/auth/verify-code",
            method: "POST",
            body: request
        )
    }
}
