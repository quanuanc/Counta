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
            return "请先在设置中配置 Fava API 地址"
        case .invalidBaseURL:
            return "Fava API 地址无效，请检查设置"
        case .invalidPage:
            return "页码无效，请稍后重试"
        case .invalidResponse:
            return "服务器响应无效，请稍后重试"
        case .httpStatus(let statusCode):
            if statusCode == 401 || statusCode == 403 {
                return "认证失败，请检查用户名和密码"
            }
            if statusCode == 404 {
                return "暂无更多日记账数据"
            }
            return "服务器返回错误（\(statusCode)）"
        case .decodingFailed:
            return "无法解析日记账数据"
        case .requestFailed(let error):
            return "网络请求失败：\(error.localizedDescription)"
        }
    }
}
