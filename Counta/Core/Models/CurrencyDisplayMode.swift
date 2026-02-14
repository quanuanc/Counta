import Foundation

enum CurrencyDisplayMode: String, CaseIterable, Identifiable, Sendable {
    case symbol
    case code

    var id: String { rawValue }

    var title: LocalizedStringResource {
        switch self {
        case .symbol:
            return L10n.CurrencyDisplayMode.symbolTitle
        case .code:
            return L10n.CurrencyDisplayMode.codeTitle
        }
    }

    var displayTitle: LocalizedStringResource {
        switch self {
        case .symbol:
            return L10n.CurrencyDisplayMode.symbolItem
        case .code:
            return L10n.CurrencyDisplayMode.codeItem
        }
    }
}
