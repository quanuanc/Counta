import Foundation

@Observable
final class BalanceSheetViewModel: @unchecked Sendable {
    var assetsExpanded = true
    var liabilitiesExpanded = true
    var equityExpanded = false

    private(set) var assetAccounts: [Account] = []
    private(set) var liabilityAccounts: [Account] = []
    private(set) var equityAccounts: [Account] = []

    var totalAssets: Decimal {
        assetAccounts.reduce(0) { $0 + $1.totalBalance }
    }

    var totalLiabilities: Decimal {
        liabilityAccounts.reduce(0) { $0 + $1.totalBalance }
    }

    var totalEquity: Decimal {
        equityAccounts.reduce(0) { $0 + $1.totalBalance }
    }

    var netWorth: Decimal {
        totalAssets - totalLiabilities
    }

    init() {
        loadMockData()
    }

    func refresh() async {
        try? await Task.sleep(for: .milliseconds(500))
        loadMockData()
    }

    private func loadMockData() {
        assetAccounts = [
            Account(
                id: "Assets:Bank",
                name: "银行账户",
                type: .assets,
                balance: 0,
                children: [
                    Account(id: "Assets:Bank:CCB", name: "建设银行", type: .assets, balance: 100000),
                    Account(id: "Assets:Bank:CMB", name: "招商银行", type: .assets, balance: 80000),
                ]
            ),
            Account(
                id: "Assets:Investment",
                name: "投资账户",
                type: .assets,
                balance: 0,
                children: [
                    Account(id: "Assets:Investment:Stock", name: "股票", type: .assets, balance: 150000),
                    Account(id: "Assets:Investment:Fund", name: "基金", type: .assets, balance: 50000),
                ]
            ),
            Account(id: "Assets:Cash", name: "现金", type: .assets, balance: 40000),
        ]

        liabilityAccounts = [
            Account(id: "Liabilities:CreditCard", name: "信用卡", type: .liabilities, balance: 11580),
            Account(id: "Liabilities:Loan", name: "借款", type: .liabilities, balance: 50000),
        ]

        equityAccounts = [
            Account(id: "Equity:Opening", name: "期初余额", type: .equity, balance: 300000),
            Account(id: "Equity:Retained", name: "本期损益", type: .equity, balance: 58420),
        ]
    }
}
