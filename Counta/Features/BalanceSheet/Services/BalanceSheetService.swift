import Foundation

struct BalanceSheetService: Sendable {
    func fetchBalanceSheet(baseURL: String) async throws -> BalanceSheetData {
        let trimmed = FavaURLValidator.normalized(baseURL)
        guard !trimmed.isEmpty else {
            throw BalanceSheetServiceError.missingBaseURL
        }
        guard FavaURLValidator.isValid(trimmed) else {
            throw BalanceSheetServiceError.invalidBaseURL
        }

        let url = try makeBalanceSheetURL(from: trimmed)
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
            throw BalanceSheetServiceError.requestFailed(underlying: error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw BalanceSheetServiceError.invalidResponse
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw BalanceSheetServiceError.httpStatus(httpResponse.statusCode)
        }

        do {
            return try JSONDecoder().decode(BalanceSheetResponse.self, from: data).data
        } catch {
            throw BalanceSheetServiceError.decodingFailed(underlying: error)
        }
    }

    private func makeBalanceSheetURL(from baseURL: String) throws -> URL {
        guard var components = URLComponents(string: baseURL) else {
            throw BalanceSheetServiceError.invalidBaseURL
        }
        let path = components.path
        let normalizedPath: String
        if path.hasSuffix("/balance_sheet") {
            normalizedPath = path
        } else if path.hasSuffix("/") {
            normalizedPath = path + "balance_sheet"
        } else {
            normalizedPath = path + "/balance_sheet"
        }
        components.path = normalizedPath
        guard let url = components.url else {
            throw BalanceSheetServiceError.invalidBaseURL
        }
        return url
    }
}

enum BalanceSheetServiceError: LocalizedError {
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
            return "无法解析资产负债表数据"
        case .requestFailed(let error):
            return "网络请求失败：\(error.localizedDescription)"
        }
    }
}
