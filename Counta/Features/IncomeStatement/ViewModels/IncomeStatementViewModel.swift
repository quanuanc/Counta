import Foundation

@Observable
final class IncomeStatementViewModel: @unchecked Sendable {
    var selectedPeriod: Date = Date()
    var showDatePicker = false
    var incomeExpanded = true
    var expensesExpanded = true

    private(set) var incomeAccounts: [Account] = []
    private(set) var expenseAccounts: [Account] = []

    var totalIncome: Decimal {
        incomeAccounts.reduce(0) { $0 + $1.balance }
    }

    var totalExpenses: Decimal {
        expenseAccounts.reduce(0) { $0 + $1.balance }
    }

    var netIncome: Decimal {
        totalIncome - totalExpenses
    }

    init() {
        loadMockData()
    }

    func refresh() async {
        try? await Task.sleep(for: .milliseconds(500))
        loadMockData()
    }

    private func loadMockData() {
        incomeAccounts = [
            Account(id: "Income:Salary", name: "工资收入", type: .income, balance: 20000),
            Account(id: "Income:Investment", name: "投资收益", type: .income, balance: 3500),
            Account(id: "Income:Other", name: "其他收入", type: .income, balance: 1500),
        ]

        expenseAccounts = [
            Account(id: "Expenses:Food", name: "餐饮", type: .expenses, balance: 2500),
            Account(id: "Expenses:Transport", name: "交通", type: .expenses, balance: 1200),
            Account(id: "Expenses:Shopping", name: "购物", type: .expenses, balance: 3800),
            Account(id: "Expenses:Rent", name: "房租", type: .expenses, balance: 4000),
            Account(id: "Expenses:Other", name: "其他", type: .expenses, balance: 920),
        ]
    }
}
