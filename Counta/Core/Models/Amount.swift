import Foundation

struct Amount: Hashable, Sendable {
    var number: Decimal
    var currency: String

    init(number: Decimal, currency: String = "CNY") {
        self.number = number
        self.currency = currency
    }

    var isNegative: Bool {
        number < 0
    }

    var isPositive: Bool {
        number > 0
    }

    var absoluteValue: Amount {
        Amount(number: abs(number), currency: currency)
    }
}
