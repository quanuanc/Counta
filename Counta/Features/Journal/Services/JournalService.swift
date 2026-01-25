import Foundation

struct JournalService: Sendable {
    func fetchJournal(baseURL: String, page: Int, order: JournalOrder) async throws -> JournalData {
        let trimmed = FavaURLValidator.normalized(baseURL)
        guard !trimmed.isEmpty else {
            throw JournalServiceError.missingBaseURL
        }
        guard FavaURLValidator.isValid(trimmed) else {
            throw JournalServiceError.invalidBaseURL
        }
        guard page >= 1 else {
            throw JournalServiceError.invalidPage
        }

        let url = try makeJournalURL(from: trimmed, page: page, order: order)
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let authHeader = FavaAuthorization.storedBasicHeader() {
            request.setValue(authHeader, forHTTPHeaderField: "Authorization")
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw JournalServiceError.requestFailed(underlying: error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw JournalServiceError.invalidResponse
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw JournalServiceError.httpStatus(httpResponse.statusCode)
        }

        do {
            return try JSONDecoder().decode(JournalResponse.self, from: data).data
        } catch {
            throw JournalServiceError.decodingFailed(underlying: error)
        }
    }

    private func makeJournalURL(from baseURL: String, page: Int, order: JournalOrder) throws -> URL {
        guard var components = URLComponents(string: baseURL) else {
            throw JournalServiceError.invalidBaseURL
        }
        let path = components.path
        let normalizedPath: String
        if path.hasSuffix("/journal_page") {
            normalizedPath = path
        } else if path.hasSuffix("/") {
            normalizedPath = path + "journal_page"
        } else {
            normalizedPath = path + "/journal_page"
        }
        components.path = normalizedPath
        var queryItems = components.queryItems ?? []
        queryItems.append(URLQueryItem(name: "page", value: String(page)))
        queryItems.append(URLQueryItem(name: "order", value: order.rawValue))
        components.queryItems = queryItems
        guard let url = components.url else {
            throw JournalServiceError.invalidBaseURL
        }
        return url
    }
}

enum JournalServiceError: LocalizedError {
    case missingBaseURL
    case invalidBaseURL
    case invalidPage
    case invalidResponse
    case httpStatus(Int)
    case decodingFailed(underlying: Error)
    case requestFailed(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .missingBaseURL:
            return String(localized: L10n.Errors.missingBaseURL)
        case .invalidBaseURL:
            return String(localized: L10n.Errors.invalidBaseURL)
        case .invalidPage:
            return String(localized: L10n.Errors.invalidPage)
        case .invalidResponse:
            return String(localized: L10n.Errors.invalidResponse)
        case .httpStatus(let statusCode):
            if statusCode == 401 || statusCode == 403 {
                return String(localized: L10n.Errors.authFailed)
            }
            if statusCode == 404 {
                return String(localized: L10n.Errors.noMoreJournalData)
            }
            return L10n.Errors.httpStatus(statusCode)
        case .decodingFailed:
            return String(localized: L10n.Errors.decodingJournal)
        case .requestFailed(let error):
            return L10n.Errors.requestFailed(error)
        }
    }
}
