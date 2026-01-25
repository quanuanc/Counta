import Foundation

struct IncomeStatementService: Sendable {
    func fetchIncomeStatement(baseURL: String) async throws -> IncomeStatementData {
        let trimmed = FavaURLValidator.normalized(baseURL)
        guard !trimmed.isEmpty else {
            throw IncomeStatementServiceError.missingBaseURL
        }
        guard FavaURLValidator.isValid(trimmed) else {
            throw IncomeStatementServiceError.invalidBaseURL
        }

        let url = try makeIncomeStatementURL(from: trimmed)
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
            throw IncomeStatementServiceError.requestFailed(underlying: error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw IncomeStatementServiceError.invalidResponse
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw IncomeStatementServiceError.httpStatus(httpResponse.statusCode)
        }

        do {
            return try JSONDecoder().decode(IncomeStatementResponse.self, from: data).data
        } catch {
            throw IncomeStatementServiceError.decodingFailed(underlying: error)
        }
    }

    private func makeIncomeStatementURL(from baseURL: String) throws -> URL {
        guard var components = URLComponents(string: baseURL) else {
            throw IncomeStatementServiceError.invalidBaseURL
        }
        let path = components.path
        let normalizedPath: String
        if path.hasSuffix("/income_statement") {
            normalizedPath = path
        } else if path.hasSuffix("/") {
            normalizedPath = path + "income_statement"
        } else {
            normalizedPath = path + "/income_statement"
        }
        components.path = normalizedPath
        guard let url = components.url else {
            throw IncomeStatementServiceError.invalidBaseURL
        }
        return url
    }
}

enum IncomeStatementServiceError: LocalizedError {
    case missingBaseURL
    case invalidBaseURL
    case invalidResponse
    case httpStatus(Int)
    case decodingFailed(underlying: Error)
    case requestFailed(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .missingBaseURL:
            return "请先在设置中配置 Fava 地址"
        case .invalidBaseURL:
            return "Fava 地址无效，请检查设置"
        case .invalidResponse:
            return "服务器响应无效，请稍后重试"
        case .httpStatus(let statusCode):
            if statusCode == 401 || statusCode == 403 {
                return "认证失败，请检查用户名和密码"
            }
            return "服务器返回错误（\(statusCode)）"
        case .decodingFailed:
            return "无法解析损益表数据"
        case .requestFailed(let error):
            return "网络请求失败：\(error.localizedDescription)"
        }
    }
}
