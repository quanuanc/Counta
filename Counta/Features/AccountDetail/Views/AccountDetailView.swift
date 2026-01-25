import SwiftUI

struct AccountDetailView: View {
    let account: Account
    @State private var viewModel: AccountDetailViewModel

    init(
        account: Account,
        balanceAmounts: [Amount]? = nil
    ) {
        self.account = account
        let initialBalances =
            balanceAmounts ?? Self.makeBalanceAmounts(for: account)
        _viewModel = State(
            initialValue: AccountDetailViewModel(
                account: account,
                initialBalances: initialBalances
            )
        )
    }

    var body: some View {
        List {
            if let errorMessage = viewModel.errorMessage {
                errorSection(message: errorMessage)
            }
            accountInfoSection
            balanceSection
            transactionsSection
        }
        .navigationTitle(account.name)
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await viewModel.refresh()
        }
        .task {
            await viewModel.loadIfNeeded()
        }
    }

    private var accountInfoSection: some View {
        Section("账户信息") {
            LabeledContent("完整名称", value: account.id)
            HStack {
                Text("类型")
                Spacer()
                AccountTypeBadge(type: account.type)
            }
        }
    }

    private var balanceSection: some View {
        Section("余额") {
            if viewModel.isLoading && viewModel.balanceAmounts.isEmpty {
                loadingRow
            } else {
                HStack {
                    Text("当前余额")
                    Spacer()
                    BalanceAmountList(amounts: viewModel.balanceAmounts)
                }
            }
        }
    }

    @ViewBuilder
    private var transactionsSection: some View {
        if viewModel.isLoading && viewModel.relatedEntries.isEmpty {
            Section("相关交易") {
                loadingRow
            }
        } else if viewModel.relatedEntries.isEmpty {
            Section("相关交易") {
                Text("暂无相关交易")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        } else {
            JournalEntryGroupListView(groups: viewModel.relatedEntryGroups) {
                entry in
                JournalEntryDetailView(entry: entry)
            }
        }
    }

    private func errorSection(message: String) -> some View {
        Section {
            Text(message)
                .font(.footnote)
                .foregroundStyle(.red)
        }
    }

    private var loadingRow: some View {
        HStack {
            Spacer()
            ProgressView()
            Spacer()
        }
    }

    private static func makeBalanceAmounts(for account: Account) -> [Amount] {
        let sign: Decimal
        switch account.type {
        case .expenses, .liabilities, .equity:
            sign = -1
        default:
            sign = 1
        }
        let balances = account.totalBalancesByCurrency
        if balances.isEmpty {
            return [
                Amount(
                    number: account.balance * sign,
                    currency: account.currency
                )
            ]
        }
        return
            balances
            .map { Amount(number: $0.value * sign, currency: $0.key) }
            .sorted { $0.currency < $1.currency }
    }
}

private struct BalanceAmountList: View {
    let amounts: [Amount]

    var body: some View {
        let showCurrencyCode = amounts.count > 1
        VStack(alignment: .trailing, spacing: 2) {
            ForEach(amounts, id: \.self) { amount in
                AmountText(
                    amount: amount,
                    font: .callout,
                    showCurrencyCode: showCurrencyCode
                )
            }
        }
    }
}

private struct AccountTypeBadge: View {
    let type: AccountType

    var body: some View {
        Text(type.localizedTitle)
            .font(.caption.weight(.semibold))
            .foregroundStyle(type.tintColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(type.tintColor.opacity(0.15))
            .clipShape(Capsule())
    }
}

extension AccountType {
    fileprivate var localizedTitle: String {
        switch self {
        case .assets:
            return "资产"
        case .liabilities:
            return "负债"
        case .income:
            return "收入"
        case .expenses:
            return "支出"
        case .equity:
            return "权益"
        }
    }

    fileprivate var tintColor: Color {
        switch self {
        case .assets:
            return .blue
        case .liabilities:
            return .orange
        case .income:
            return .green
        case .expenses:
            return .red
        case .equity:
            return .purple
        }
    }
}

#Preview {
    PreviewContainer {
        NavigationStack {
            AccountDetailView(
                account: Account(
                    id: "Assets:Bank",
                    name: "Bank",
                    type: .assets,
                    balance: 9950
                )
            )
        }
    }
}
