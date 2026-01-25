import SwiftUI

struct AmountText: View {
    let amount: Amount
    var showSign: Bool = false
    var font: Font = .body
    var showCurrencyCode: Bool = false

    @AppStorage(AppStorageKeys.currencyDisplayMode) private var currencyDisplayMode: CurrencyDisplayMode = .symbol

    private var textColor: Color {
        if amount.isPositive {
            return .green
        } else if amount.isNegative {
            return .red
        } else {
            return .primary
        }
    }

    private var effectiveCurrencyDisplayMode: CurrencyDisplayMode {
        showCurrencyCode ? .code : currencyDisplayMode
    }

    private var currencyCode: String {
        amount.currency.uppercased()
    }

    private var currencySymbol: String {
        switch currencyCode {
        case "CNY": return "¥"
        case "USD": return "$"
        case "EUR": return "€"
        case "JPY": return "¥"
        case "GBP": return "£"
        default: return "¤"
        }
    }

    private var currencyPrefix: String {
        switch effectiveCurrencyDisplayMode {
        case .symbol:
            return currencySymbol + " "
        case .code:
            return currencyCode + " "
        }
    }

    private var displayText: String {
        let sign = showSign && amount.isPositive ? "+" : ""
        return sign + currencyPrefix + amount.number.formatted
    }

    var body: some View {
        Text(displayText)
            .font(font)
            .foregroundStyle(textColor)
    }
}

#Preview {
    VStack(spacing: 20) {
        AmountText(amount: Amount(number: 1234.56))
        AmountText(amount: Amount(number: -567.89))
        AmountText(amount: Amount(number: 1000, currency: "USD"), showSign: true)
    }
}
