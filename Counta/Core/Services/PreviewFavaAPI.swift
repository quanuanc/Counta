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
        guard let url = previewJSONURL() else {
            throw PreviewFavaAPIError.missingMockFile
        }
        return try Data(contentsOf: url)
    }

    private static func previewJSONURL() -> URL? {
        let fileURL = URL(fileURLWithPath: #filePath)
        let repoRoot = fileURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        return repoRoot.appendingPathComponent("docs/income_statement/response.json")
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
            let data = try PreviewFavaAPI.loadIncomeStatementData()
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
