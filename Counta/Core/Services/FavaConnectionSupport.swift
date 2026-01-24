import Foundation

enum FavaURLValidator {
    static func normalized(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func isValid(_ value: String) -> Bool {
        let trimmed = normalized(value)
        guard let url = URL(string: trimmed),
              let scheme = url.scheme?.lowercased(),
              ["http", "https"].contains(scheme),
              url.host != nil
        else {
            return false
        }
        return true
    }
}

enum FavaAuthorization {
    static func basicHeader(username: String, password: String) -> String? {
        guard !username.isEmpty, !password.isEmpty else {
            return nil
        }
        guard let data = "\(username):\(password)".data(using: .utf8) else {
            return nil
        }
        return "Basic \(data.base64EncodedString())"
    }

    static func storedBasicHeader() -> String? {
        let defaults = UserDefaults.standard
        guard defaults.bool(forKey: AppStorageKeys.favaUsesBasicAuth) else {
            return nil
        }
        guard let username = defaults.string(forKey: AppStorageKeys.favaApiUsername),
              !username.isEmpty
        else {
            return nil
        }
        guard let password = KeychainService.readString(for: KeychainKeys.favaApiPassword),
              !password.isEmpty
        else {
            return nil
        }
        return basicHeader(username: username, password: password)
    }
}
