import Foundation

@Observable
final class IncomeStatementViewModel: @unchecked Sendable {
    var selectedPeriod: Date = Date()
    var showDatePicker = false
    var incomeExpanded = false
    var expensesExpanded = false
    var isLoading = false
    var errorMessage: String?
    private(set) var expandedAccountIds: Set<String> = []

    private(set) var incomeAccounts: [Account] = []
    private(set) var expenseAccounts: [Account] = []
    private var hasLoaded = false
    private var hasInitializedAccountExpansion = false

    private let service = IncomeStatementService()

    var totalIncomeByCurrency: [String: Decimal] {
        aggregateBalances(from: incomeAccounts)
    }

    var totalExpensesByCurrency: [String: Decimal] {
        aggregateBalances(from: expenseAccounts)
    }

    var netIncomeByCurrency: [String: Decimal] {
        mergeBalances(totalIncomeByCurrency, totalExpensesByCurrency) { $0 - $1 }
    }

    var totalIncomeAmounts: [Amount] {
        amounts(from: totalIncomeByCurrency)
    }

    var totalExpenseAmounts: [Amount] {
        amounts(from: totalExpensesByCurrency, sign: -1)
    }

    var netIncomeAmounts: [Amount] {
        amounts(from: netIncomeByCurrency)
    }

    var summaryCurrencies: [String] {
        let currencies = Set(totalIncomeByCurrency.keys).union(totalExpensesByCurrency.keys)
        return sortedCurrencies(currencies)
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

        updateAccountExpansion()
    }

    private func makeAccount(
        from node: IncomeStatementTreeNode,
        type: AccountType,
        preferredCurrency: String?
    ) -> Account {
        let rawBalances = node.balance?.values ?? [:]
        let normalizedBalances = BalanceAmountHelper.normalizeBalances(rawBalances)
        let selection = BalanceAmountHelper.selectBalance(from: rawBalances, preferredCurrency: preferredCurrency)
        let nextPreferredCurrency = selection?.currency ?? preferredCurrency
        let children = node.children.map { child in
            makeAccount(from: child, type: type, preferredCurrency: nextPreferredCurrency)
        }
        let currency = selection?.currency ?? children.first?.currency ?? preferredCurrency ?? "CNY"
        let balance = selection.map { abs($0.amount) } ?? 0

        return Account(
            id: node.account,
            type: type,
            currency: currency,
            balance: balance,
            balancesByCurrency: normalizedBalances,
            children: children
        )
    }

    private func aggregateBalances(from accounts: [Account]) -> [String: Decimal] {
        var totals: [String: Decimal] = [:]
        for account in accounts {
            for (currency, amount) in account.totalBalancesByCurrency {
                totals[currency, default: 0] += amount
            }
        }
        return totals
    }

    private func mergeBalances(
        _ left: [String: Decimal],
        _ right: [String: Decimal],
        combine: (Decimal, Decimal) -> Decimal
    ) -> [String: Decimal] {
        var merged = left
        for (currency, amount) in right {
            let existing = merged[currency] ?? 0
            merged[currency] = combine(existing, amount)
        }
        return merged
    }

    private var primaryCurrency: String {
        if let currency = BalanceAmountHelper.selectBalance(
            from: totalIncomeByCurrency,
            preferredCurrency: nil
        )?.currency {
            return currency
        }
        if let currency = BalanceAmountHelper.selectBalance(
            from: totalExpensesByCurrency,
            preferredCurrency: nil
        )?.currency {
            return currency
        }
        return "CNY"
    }

    private func sortedCurrencies(_ currencies: Set<String>) -> [String] {
        BalanceAmountHelper.sortedCurrencies(currencies, preferred: primaryCurrency)
    }

    private func amounts(
        from balances: [String: Decimal],
        sign: Decimal = 1
    ) -> [Amount] {
        BalanceAmountHelper.amounts(from: balances, sign: sign, preferredCurrency: primaryCurrency)
    }

    func isAccountExpanded(_ accountId: String) -> Bool {
        expandedAccountIds.contains(accountId)
    }

    func setAccountExpanded(_ accountId: String, isExpanded: Bool) {
        if isExpanded {
            expandedAccountIds.insert(accountId)
        } else {
            expandedAccountIds.remove(accountId)
        }
    }

    private func updateAccountExpansion() {
        let expandableIds = collectExpandableAccountIds(from: incomeAccounts)
            .union(collectExpandableAccountIds(from: expenseAccounts))
        if !hasInitializedAccountExpansion {
            if !expandableIds.isEmpty {
                expandedAccountIds.removeAll()
                hasInitializedAccountExpansion = true
            }
        } else {
            expandedAccountIds = expandedAccountIds.intersection(expandableIds)
        }
    }

    private func collectExpandableAccountIds(from accounts: [Account]) -> Set<String> {
        var ids: Set<String> = []
        for account in accounts {
            if account.hasChildren {
                ids.insert(account.id)
                ids.formUnion(collectExpandableAccountIds(from: account.children))
            }
        }
        return ids
    }

    func displayAmounts(for account: Account) -> [Amount] {
        let sign: Decimal = account.type == .expenses ? -1 : 1
        return amounts(from: account.totalBalancesByCurrency, sign: sign)
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
