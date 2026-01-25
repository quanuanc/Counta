#if DEBUG
import Foundation

enum PreviewFavaAPI {
    private static var isEnabled = false
    static let baseURL = "https://preview.fava.local/api"

    static func enable() {
        guard !isEnabled else { return }
        isEnabled = true
        UserDefaults.standard.set(baseURL, forKey: AppStorageKeys.favaApiURL)
        URLProtocol.registerClass(PreviewFavaURLProtocol.self)
    }

    fileprivate static func loadIncomeStatementData() throws -> Data {
        guard let url = previewJSONURL(path: "docs/income_statement/response.json") else {
            throw PreviewFavaAPIError.missingMockFile
        }
        return try Data(contentsOf: url)
    }

    fileprivate static func loadBalanceSheetData() throws -> Data {
        guard let url = previewJSONURL(path: "docs/balance_sheet/response.json") else {
            throw PreviewFavaAPIError.missingMockFile
        }
        return try Data(contentsOf: url)
    }

    fileprivate static func loadJournalData() throws -> Data {
        guard let url = previewJSONURL(path: "docs/journal/response.json") else {
            throw PreviewFavaAPIError.missingMockFile
        }
        return try Data(contentsOf: url)
    }

    fileprivate static func loadAccountDetailData() throws -> Data {
        guard let url = previewJSONURL(path: "docs/account_detail/response.json") else {
            throw PreviewFavaAPIError.missingMockFile
        }
        return try Data(contentsOf: url)
    }

    private static func previewJSONURL(path: String) -> URL? {
        let fileURL = URL(fileURLWithPath: #filePath)
        let repoRoot = fileURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        return repoRoot.appendingPathComponent(path)
    }
}

enum PreviewFavaAPIError: Error {
    case missingMockFile
    case invalidResponse
}

final class PreviewFavaURLProtocol: URLProtocol {
    private static let handledKey = "PreviewFavaURLProtocolHandled"

    override class func canInit(with request: URLRequest) -> Bool {
        guard let url = request.url else { return false }
        guard URLProtocol.property(forKey: handledKey, in: request) == nil else { return false }
        guard url.host == "preview.fava.local" else { return false }
        return url.path.hasSuffix("/income_statement")
            || url.path.hasSuffix("/balance_sheet")
            || url.path.hasSuffix("/journal_page")
            || url.path.hasSuffix("/account_report")
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        let mutableRequest = NSMutableURLRequest(url: request.url ?? URL(string: PreviewFavaAPI.baseURL)!)
        mutableRequest.allHTTPHeaderFields = request.allHTTPHeaderFields
        mutableRequest.httpMethod = request.httpMethod!
        mutableRequest.httpBody = request.httpBody
        URLProtocol.setProperty(true, forKey: Self.handledKey, in: mutableRequest)
        guard let url = mutableRequest.url else { return }

        do {
            let data: Data
            if url.path.hasSuffix("/balance_sheet") {
                data = try PreviewFavaAPI.loadBalanceSheetData()
            } else if url.path.hasSuffix("/account_report") {
                data = try PreviewFavaAPI.loadAccountDetailData()
            } else if url.path.hasSuffix("/journal_page") {
                data = try PreviewFavaAPI.loadJournalData()
            } else {
                data = try PreviewFavaAPI.loadIncomeStatementData()
            }
            guard let response = HTTPURLResponse(
                url: url,
                statusCode: 200,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            ) else {
                throw PreviewFavaAPIError.invalidResponse
            }
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
#endif
