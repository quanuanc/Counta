import Foundation

enum AccountType: String, CaseIterable, Sendable {
    case assets = "Assets"
    case liabilities = "Liabilities"
    case income = "Income"
    case expenses = "Expenses"
    case equity = "Equity"
}

struct Account: Identifiable, Hashable, Sendable {
    let id: String
    var name: String
    var type: AccountType
    var currency: String
    var balance: Decimal
    var balancesByCurrency: [String: Decimal]
    var children: [Account]

    init(
        id: String,
        name: String? = nil,
        type: AccountType,
        currency: String = "CNY",
        balance: Decimal = 0,
        balancesByCurrency: [String: Decimal] = [:],
        children: [Account] = []
    ) {
        self.id = id
        self.name = name ?? id.components(separatedBy: ":").last ?? id
        self.type = type
        self.currency = currency
        self.balance = balance
        self.balancesByCurrency = balancesByCurrency
        self.children = children
    }

    var totalBalance: Decimal {
        balance + children.reduce(0) { $0 + $1.totalBalance }
    }

    var totalBalancesByCurrency: [String: Decimal] {
        var totals = balancesByCurrency
        if totals.isEmpty, balance != 0 || children.isEmpty {
            totals[currency] = balance
        }
        for child in children {
            for (currency, amount) in child.totalBalancesByCurrency {
                totals[currency, default: 0] += amount
            }
        }
        return totals
    }

    var hasChildren: Bool {
        !children.isEmpty
    }
}
