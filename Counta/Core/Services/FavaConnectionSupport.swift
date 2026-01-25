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

enum FavaURLResolver {
    enum ResolveError: LocalizedError {
        case invalidURL
        case invalidResponse
        case missingLedgerPath
        case requestFailed(underlying: Error)

        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return String(localized: L10n.Errors.favaResolverInvalidURL)
            case .invalidResponse:
                return String(localized: L10n.Errors.favaResolverInvalidResponse)
            case .missingLedgerPath:
                return String(localized: L10n.Errors.favaResolverMissingLedgerPath)
            case .requestFailed(let error):
                return L10n.Errors.favaResolverRequestFailed(error)
            }
        }
    }

    private static let endpointHints: Set<String> = [
        "income_statement",
        "balance_sheet",
        "journal",
        "journal_page",
        "account_report",
        "trial_balance"
    ]

    static func baseURL(from input: String) -> String {
        let trimmed = FavaURLValidator.normalized(input)
        guard var components = URLComponents(string: trimmed) else {
            return trimmed
        }
        let pathComponents = components.path.split(separator: "/")
        if let apiIndex = pathComponents.firstIndex(of: "api") {
            let baseComponents = pathComponents.prefix(upTo: apiIndex)
            components.path = baseComponents.isEmpty
                ? ""
                : "/" + baseComponents.joined(separator: "/")
        } else if let last = pathComponents.last, endpointHints.contains(String(last)) {
            let baseComponents = pathComponents.dropLast()
            components.path = baseComponents.isEmpty
                ? ""
                : "/" + baseComponents.joined(separator: "/")
        }
        if components.path == "/" {
            components.path = ""
        }
        components.query = nil
        components.fragment = nil
        return components.url?.absoluteString ?? trimmed
    }

    static func resolveAPIBase(
        from input: String,
        authorizationHeader: String? = nil,
        session: URLSession = .shared
    ) async throws -> String {
        let trimmed = FavaURLValidator.normalized(input)
        guard let url = URL(string: trimmed) else {
            throw ResolveError.invalidURL
        }

        if let apiURL = apiBase(from: url) {
            return apiURL
        }

        do {
            var request = URLRequest(url: url)
            if let authorizationHeader {
                request.setValue(authorizationHeader, forHTTPHeaderField: "Authorization")
            }
            let (_, response) = try await session.data(for: request)
            guard let finalURL = response.url else {
                throw ResolveError.invalidResponse
            }
            if let apiURL = apiBase(from: finalURL) {
                return apiURL
            }
            guard let apiURL = apiBaseFromRedirect(finalURL) else {
                throw ResolveError.missingLedgerPath
            }
            return apiURL
        } catch let error as ResolveError {
            throw error
        } catch {
            throw ResolveError.requestFailed(underlying: error)
        }
    }

    private static func apiBase(from url: URL) -> String? {
        guard let components = apiComponents(from: url) else {
            return nil
        }
        return components.url?.absoluteString
    }

    private static func apiComponents(from url: URL) -> URLComponents? {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }
        let pathComponents = components.path.split(separator: "/")
        guard let apiIndex = pathComponents.firstIndex(of: "api") else {
            return nil
        }
        let apiPath = "/" + pathComponents.prefix(through: apiIndex).joined(separator: "/")
        components.path = apiPath
        components.query = nil
        components.fragment = nil
        return components
    }

    private static func apiBaseFromRedirect(_ url: URL) -> String? {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }
        let segments = components.path.split(separator: "/")
        let baseSegments: [Substring]
        if let last = segments.last, endpointHints.contains(String(last)) {
            baseSegments = Array(segments.dropLast())
        } else {
            baseSegments = Array(segments)
        }
        let apiPath: String
        if baseSegments.isEmpty {
            apiPath = "/api"
        } else {
            apiPath = "/" + baseSegments.joined(separator: "/") + "/api"
        }
        components.path = apiPath
        components.query = nil
        components.fragment = nil
        return components.url?.absoluteString
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
