import SwiftUI

struct AccountDetailView: View {
    let account: Account
    private let balanceAmounts: [Amount]
    private let transactions: [Transaction]

    init(
        account: Account,
        balanceAmounts: [Amount]? = nil,
        transactions: [Transaction] = AccountDetailView.placeholderTransactions
    ) {
        self.account = account
        self.balanceAmounts = balanceAmounts ?? Self.makeBalanceAmounts(for: account)
        self.transactions = transactions
    }

    var body: some View {
        List {
            accountInfoSection
            balanceSection
            transactionsSection
        }
        .navigationTitle(account.name)
        .navigationBarTitleDisplayMode(.inline)
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
            HStack {
                Text("当前余额")
                Spacer()
                BalanceAmountList(amounts: balanceAmounts)
            }
        }
    }

    private var transactionsSection: some View {
        Section("相关交易") {
            if transactions.isEmpty {
                Text("暂无相关交易")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(transactions) { transaction in
                    AccountRelatedTransactionRow(transaction: transaction)
                }
            }
        }
    }

    private static func makeBalanceAmounts(for account: Account) -> [Amount] {
        let sign: Decimal = account.type == .expenses ? -1 : 1
        let balances = account.totalBalancesByCurrency
        if balances.isEmpty {
            return [Amount(number: account.balance * sign, currency: account.currency)]
        }
        return balances
            .map { Amount(number: $0.value * sign, currency: $0.key) }
            .sorted { $0.currency < $1.currency }
    }

    private static let placeholderTransactions: [Transaction] = [
        Transaction(
            date: makeDate(2024, 1, 31),
            payee: "公司",
            narration: "工资",
            postings: [
                Posting(account: "Assets:Bank", amount: Amount(number: 20000)),
                Posting(account: "Income:Salary", amount: Amount(number: -20000)),
            ]
        ),
        Transaction(
            date: makeDate(2024, 1, 15),
            payee: "超市",
            narration: "买菜",
            postings: [
                Posting(account: "Expenses:Food", amount: Amount(number: 50)),
                Posting(account: "Assets:Cash", amount: Amount(number: -50)),
            ]
        ),
    ]

    private static func makeDate(_ year: Int, _ month: Int, _ day: Int) -> Date {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: day)) ?? Date()
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

private struct AccountRelatedTransactionRow: View {
    let transaction: Transaction

    private var indicatorColor: Color {
        if transaction.isIncome {
            return .green
        } else if transaction.isExpense {
            return .red
        }
        return .blue
    }

    private var titleText: String {
        transaction.payee ?? transaction.narration
    }

    private var subtitleText: String {
        if transaction.payee != nil {
            return transaction.narration
        }
        return transaction.primaryAccount ?? ""
    }

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(indicatorColor)
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 2) {
                Text(titleText)
                    .font(.body)
                    .lineLimit(1)

                if !subtitleText.isEmpty {
                    Text(subtitleText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Text(transaction.date.relativeDescription)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.footnote)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

private extension AccountType {
    var localizedTitle: String {
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

    var tintColor: Color {
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
            AccountDetailView(account: Account(
                id: "Assets:Bank",
                name: "Bank",
                type: .assets,
                balance: 9950
            ))
        }
    }
}
