import Foundation

@Observable
final class BalanceSheetViewModel: @unchecked Sendable {
    var assetsExpanded = false
    var liabilitiesExpanded = false
    var equityExpanded = false
    var isLoading = false
    var errorMessage: String?
    private(set) var expandedAccountIds: Set<String> = []

    private(set) var assetAccounts: [Account] = []
    private(set) var liabilityAccounts: [Account] = []
    private(set) var equityAccounts: [Account] = []
    private var hasLoaded = false
    private var hasInitializedAccountExpansion = false

    private let service = BalanceSheetService()

    var totalAssetsByCurrency: [String: Decimal] {
        aggregateBalances(from: assetAccounts)
    }

    var totalLiabilitiesByCurrency: [String: Decimal] {
        aggregateBalances(from: liabilityAccounts)
    }

    var totalEquityByCurrency: [String: Decimal] {
        aggregateBalances(from: equityAccounts)
    }

    var netWorthByCurrency: [String: Decimal] {
        mergeBalances(totalAssetsByCurrency, totalLiabilitiesByCurrency) { $0 - $1 }
    }

    var totalAssetsAmounts: [Amount] {
        amounts(from: totalAssetsByCurrency)
    }

    var totalLiabilitiesAmounts: [Amount] {
        amounts(from: totalLiabilitiesByCurrency, sign: -1)
    }

    var totalEquityAmounts: [Amount] {
        amounts(from: totalEquityByCurrency, sign: -1)
    }

    var netWorthAmounts: [Amount] {
        amounts(from: netWorthByCurrency)
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
            let data = try await service.fetchBalanceSheet(baseURL: baseURL)
            apply(data)
            hasLoaded = true
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription
                ?? String(localized: L10n.Errors.vmLoadBalanceSheet)
        }
    }

    private func apply(_ data: BalanceSheetData) {
        if let assetRoot = data.trees.first(where: { $0.account == "Assets" }) {
            let source = assetRoot.children.isEmpty ? [assetRoot] : assetRoot.children
            assetAccounts = source.map { makeAccount(from: $0, type: .assets, preferredCurrency: nil) }
        } else {
            assetAccounts = []
        }

        if let liabilityRoot = data.trees.first(where: { $0.account == "Liabilities" }) {
            let source = liabilityRoot.children.isEmpty ? [liabilityRoot] : liabilityRoot.children
            liabilityAccounts = source.map { makeAccount(from: $0, type: .liabilities, preferredCurrency: nil) }
        } else {
            liabilityAccounts = []
        }

        if let equityRoot = data.trees.first(where: { $0.account == "Equity" }) {
            let source = equityRoot.children.isEmpty ? [equityRoot] : equityRoot.children
            equityAccounts = source.map { makeAccount(from: $0, type: .equity, preferredCurrency: nil) }
        } else {
            equityAccounts = []
        }

        updateAccountExpansion()
    }

    private func makeAccount(
        from node: BalanceSheetTreeNode,
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
            from: totalAssetsByCurrency,
            preferredCurrency: nil
        )?.currency {
            return currency
        }
        if let currency = BalanceAmountHelper.selectBalance(
            from: totalLiabilitiesByCurrency,
            preferredCurrency: nil
        )?.currency {
            return currency
        }
        if let currency = BalanceAmountHelper.selectBalance(
            from: totalEquityByCurrency,
            preferredCurrency: nil
        )?.currency {
            return currency
        }
        return "CNY"
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
        let expandableIds = collectExpandableAccountIds(from: assetAccounts)
            .union(collectExpandableAccountIds(from: liabilityAccounts))
            .union(collectExpandableAccountIds(from: equityAccounts))
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
        let sign: Decimal
        switch account.type {
        case .liabilities, .equity:
            sign = -1
        default:
            sign = 1
        }
        return amounts(from: account.totalBalancesByCurrency, sign: sign)
    }
}
