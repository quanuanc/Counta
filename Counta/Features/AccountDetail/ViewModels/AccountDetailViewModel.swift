import Foundation

@Observable
final class AccountDetailViewModel: @unchecked Sendable {
    let account: Account
    var isLoading = false
    var errorMessage: String?
    private(set) var balanceAmounts: [Amount]
    private(set) var relatedEntries: [JournalEntry]

    var relatedEntryGroups: [JournalEntryGroup] {
        JournalEntryGroup.makeGroups(from: relatedEntries)
    }

    private let service = AccountDetailService()
    private var hasLoaded = false

    init(
        account: Account,
        initialBalances: [Amount] = [],
        initialEntries: [JournalEntry] = []
    ) {
        self.account = account
        self.balanceAmounts = initialBalances
        self.relatedEntries = initialEntries
    }

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
            let data = try await service.fetchAccountDetail(baseURL: baseURL, account: account.id)
            apply(data)
            hasLoaded = true
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription
                ?? String(localized: L10n.Errors.vmLoadAccountDetail)
        }
    }

    private func apply(_ data: AccountDetailData) {
        if let balances = latestBalances(from: data.charts) {
            balanceAmounts = makeBalanceAmounts(from: balances)
        }
        relatedEntries = makeRelatedEntries(from: data.journal)
    }

    private func latestBalances(from charts: [AccountDetailChart]) -> [String: Decimal]? {
        let preferredCharts = charts.filter { $0.type == "balances" }
        let fallbackCharts = charts.filter { $0.type != "balances" }

        for chart in preferredCharts + fallbackCharts {
            let points = chart.data.compactMap { point -> (Date, [String: Decimal])? in
                guard let balances = point.balance?.values, !balances.isEmpty else { return nil }
                guard let date = Self.dateFormatter.date(from: point.date) else { return nil }
                return (date, balances)
            }
            if let latest = points.max(by: { $0.0 < $1.0 }) {
                return latest.1
            }

            if let fallback = chart.data.last(where: { !(($0.balance?.values ?? [:]).isEmpty) }) {
                return fallback.balance?.values
            }
        }
        return nil
    }

    private func makeBalanceAmounts(from balances: [String: Decimal]) -> [Amount] {
        let normalized = BalanceAmountHelper.normalizeBalances(balances)
        let preferredCurrency = BalanceAmountHelper.selectBalance(
            from: normalized,
            preferredCurrency: account.currency
        )?.currency ?? account.currency
        return BalanceAmountHelper.amounts(
            from: normalized,
            sign: balanceSign,
            preferredCurrency: preferredCurrency
        )
    }

    private var balanceSign: Decimal {
        switch account.type {
        case .expenses, .liabilities, .equity:
            return -1
        default:
            return 1
        }
    }

    private func makeRelatedEntries(from journalHTML: String) -> [JournalEntry] {
        let entries = JournalHTMLParser.parseEntries(from: journalHTML)
        return entries.filter { $0.isTransaction }
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
