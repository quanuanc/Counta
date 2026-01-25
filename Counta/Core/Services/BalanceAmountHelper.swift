import Foundation

struct BalanceSelection: Sendable {
    let currency: String
    let amount: Decimal
}

enum BalanceAmountHelper {
    static func selectBalance(
        from balances: [String: Decimal],
        preferredCurrency: String?
    ) -> BalanceSelection? {
        guard !balances.isEmpty else { return nil }
        if let preferredCurrency, let amount = balances[preferredCurrency] {
            return BalanceSelection(currency: preferredCurrency, amount: amount)
        }
        if let amount = balances["CNY"] {
            return BalanceSelection(currency: "CNY", amount: amount)
        }
        if let amount = balances["USD"] {
            return BalanceSelection(currency: "USD", amount: amount)
        }
        let sorted = balances.sorted { $0.key < $1.key }
        guard let first = sorted.first else { return nil }
        return BalanceSelection(currency: first.key, amount: first.value)
    }

    static func normalizeBalances(_ balances: [String: Decimal]) -> [String: Decimal] {
        balances.mapValues { abs($0) }
    }

    static func sortedCurrencies(
        _ currencies: Set<String>,
        preferred: String
    ) -> [String] {
        guard !currencies.isEmpty else { return [] }
        return currencies.sorted {
            currencySortKey($0, preferred: preferred) < currencySortKey($1, preferred: preferred)
        }
    }

    static func amounts(
        from balances: [String: Decimal],
        sign: Decimal = 1,
        preferredCurrency: String
    ) -> [Amount] {
        let currencies = sortedCurrencies(Set(balances.keys), preferred: preferredCurrency)
        if currencies.isEmpty {
            return [Amount(number: 0, currency: preferredCurrency)]
        }
        return currencies.map { currency in
            Amount(number: (balances[currency] ?? 0) * sign, currency: currency)
        }
    }

    private static func currencySortKey(_ currency: String, preferred: String) -> (Int, String) {
        if currency == preferred {
            return (0, currency)
        }
        switch currency {
        case "CNY":
            return (1, currency)
        case "USD":
            return (2, currency)
        case "EUR":
            return (3, currency)
        case "JPY":
            return (4, currency)
        case "GBP":
            return (5, currency)
        default:
            return (6, currency)
        }
    }
}
