import Foundation

struct AccountDetailService: Sendable {
    func fetchAccountDetail(
        baseURL: String,
        account: String,
        report: AccountDetailReport = .journal
    ) async throws -> AccountDetailData {
        let trimmed = FavaURLValidator.normalized(baseURL)
        guard !trimmed.isEmpty else {
            throw AccountDetailServiceError.missingBaseURL
        }
        guard FavaURLValidator.isValid(trimmed) else {
            throw AccountDetailServiceError.invalidBaseURL
        }

        let url = try makeAccountDetailURL(from: trimmed, account: account, report: report)
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
            throw AccountDetailServiceError.requestFailed(underlying: error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AccountDetailServiceError.invalidResponse
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw AccountDetailServiceError.httpStatus(httpResponse.statusCode)
        }

        do {
            return try JSONDecoder().decode(AccountDetailResponse.self, from: data).data
        } catch {
            throw AccountDetailServiceError.decodingFailed(underlying: error)
        }
    }

    private func makeAccountDetailURL(
        from baseURL: String,
        account: String,
        report: AccountDetailReport
    ) throws -> URL {
        guard var components = URLComponents(string: baseURL) else {
            throw AccountDetailServiceError.invalidBaseURL
        }
        let path = components.path
        let normalizedPath: String
        if path.hasSuffix("/account_report") {
            normalizedPath = path
        } else if path.hasSuffix("/") {
            normalizedPath = path + "account_report"
        } else {
            normalizedPath = path + "/account_report"
        }
        components.path = normalizedPath

        var queryItems = (components.queryItems ?? []).filter {
            $0.name != "a" && $0.name != "r"
        }
        queryItems.append(URLQueryItem(name: "a", value: account))
        queryItems.append(URLQueryItem(name: "r", value: report.rawValue))
        components.queryItems = queryItems

        guard let url = components.url else {
            throw AccountDetailServiceError.invalidBaseURL
        }
        return url
    }
}

enum AccountDetailReport: String, Sendable {
    case journal
}

enum AccountDetailServiceError: LocalizedError {
    case missingBaseURL
    case invalidBaseURL
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
        case .invalidResponse:
            return "服务器响应无效，请稍后重试"
        case .httpStatus(let statusCode):
            if statusCode == 401 || statusCode == 403 {
                return "认证失败，请检查用户名和密码"
            }
            return "服务器返回错误（\(statusCode)）"
        case .decodingFailed:
            return "无法解析账户明细数据"
        case .requestFailed(let error):
            return "网络请求失败：\(error.localizedDescription)"
        }
    }
}
