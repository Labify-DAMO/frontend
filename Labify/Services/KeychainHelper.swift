//
//  KeychainHelper.swift
//  Labify
//
//  Created by F_S on 10/15/25.
//

import Foundation
import Security

enum TokenStore {
    private static let service = Bundle.main.bundleIdentifier ?? "app.service"
    private static let account = "default"
    private static let key = "auth.token"

    @discardableResult
    static func save(_ token: String) -> Bool {
        let data = Data(token.utf8)

        // 공통 쿼리
        let base: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: "\(account)::\(key)"
        ]

        // 먼저 업데이트 시도
        let statusUpdate = SecItemUpdate(base as CFDictionary,
                                         [kSecValueData: data] as CFDictionary)
        if statusUpdate == errSecSuccess { return true }

        // 없으면 추가
        var add = base
        add[kSecValueData] = data
        add[kSecAttrAccessible] = kSecAttrAccessibleWhenUnlocked
        let statusAdd = SecItemAdd(add as CFDictionary, nil)
        return statusAdd == errSecSuccess
    }

    static func read() -> String? {
        var query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: "\(account)::\(key)",
            kSecMatchLimit: kSecMatchLimitOne,
            kSecReturnData: kCFBooleanTrue as Any
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    @discardableResult
    static func delete() -> Bool {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: "\(account)::\(key)"
        ]
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}
