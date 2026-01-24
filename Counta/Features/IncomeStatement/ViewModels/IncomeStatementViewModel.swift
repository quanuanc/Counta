import Foundation

@Observable
final class IncomeStatementViewModel: @unchecked Sendable {
    var selectedPeriod: Date = Date()
    var showDatePicker = false
    var incomeExpanded = true
    var expensesExpanded = true
    var isLoading = false
    var errorMessage: String?

    private(set) var incomeAccounts: [Account] = []
    private(set) var expenseAccounts: [Account] = []
    private var hasLoaded = false

    private let service = IncomeStatementService()

    var totalIncome: Decimal {
        incomeAccounts.reduce(0) { $0 + $1.totalBalance }
    }

    var totalExpenses: Decimal {
        expenseAccounts.reduce(0) { $0 + $1.totalBalance }
    }

    var netIncome: Decimal {
        totalIncome - totalExpenses
    }

    var incomeRows: [IncomeStatementAccountRow] {
        flattenAccounts(incomeAccounts)
    }

    var expenseRows: [IncomeStatementAccountRow] {
        flattenAccounts(expenseAccounts)
    }

    init() {}

    func loadIfNeeded() async {
        guard !hasLoaded else { return }
        await refresh()
    }

    func refresh() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let baseURL = UserDefaults.standard.string(forKey: AppStorageKeys.favaApiURL) ?? ""
        do {
            let data = try await service.fetchIncomeStatement(baseURL: baseURL)
            apply(data)
            hasLoaded = true
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "无法加载损益表数据"
        }
    }

    private func apply(_ data: IncomeStatementData) {
        if let incomeRoot = data.trees.first(where: { $0.account == "Income" }) {
            let source = incomeRoot.children.isEmpty ? [incomeRoot] : incomeRoot.children
            incomeAccounts = source.map { makeAccount(from: $0, type: .income, preferredCurrency: nil) }
        } else {
            incomeAccounts = []
        }

        if let expenseRoot = data.trees.first(where: { $0.account == "Expenses" }) {
            let source = expenseRoot.children.isEmpty ? [expenseRoot] : expenseRoot.children
            expenseAccounts = source.map { makeAccount(from: $0, type: .expenses, preferredCurrency: nil) }
        } else {
            expenseAccounts = []
        }

        if let range = data.dateRange,
           let beginDate = Self.dateFormatter.date(from: range.begin) {
            selectedPeriod = beginDate
        }
    }

    private func makeAccount(
        from node: IncomeStatementTreeNode,
        type: AccountType,
        preferredCurrency: String?
    ) -> Account {
        let selection = selectBalance(from: node.balance?.values ?? [:], preferredCurrency: preferredCurrency)
        let children = node.children.map { child in
            makeAccount(from: child, type: type, preferredCurrency: selection?.currency ?? preferredCurrency)
        }
        let currency = selection?.currency ?? children.first?.currency ?? preferredCurrency ?? "CNY"
        let balance = selection.map { abs($0.amount) } ?? 0

        return Account(
            id: node.account,
            type: type,
            currency: currency,
            balance: balance,
            children: children
        )
    }

    private func selectBalance(
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

    private func flattenAccounts(
        _ accounts: [Account],
        indentLevel: Int = 0
    ) -> [IncomeStatementAccountRow] {
        var rows: [IncomeStatementAccountRow] = []
        for account in accounts {
            rows.append(IncomeStatementAccountRow(account: account, indentLevel: indentLevel))
            if account.hasChildren {
                rows.append(contentsOf: flattenAccounts(account.children, indentLevel: indentLevel + 1))
            }
        }
        return rows
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

struct IncomeStatementAccountRow: Identifiable, Sendable {
    let account: Account
    let indentLevel: Int

    var id: String {
        account.id
    }
}

private struct BalanceSelection {
    let currency: String
    let amount: Decimal
}
