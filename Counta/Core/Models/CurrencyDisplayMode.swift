import Foundation

enum CurrencyDisplayMode: String, CaseIterable, Identifiable, Sendable {
    case symbol
    case code

    var id: String { rawValue }

    var title: String {
        switch self {
        case .symbol:
            return "符号"
        case .code:
            return "缩写"
        }
    }

    var example: String {
        switch self {
        case .symbol:
            return "$"
        case .code:
            return "USD"
        }
    }
}
