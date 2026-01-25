import SwiftUI

struct IncomeStatementView: View {
    @State private var viewModel = IncomeStatementViewModel()
    @AppStorage(AppStorageKeys.currencyDisplayMode) private var currencyDisplayMode: CurrencyDisplayMode = .symbol

    var body: some View {
        NavigationStack {
            List {
                if let errorMessage = viewModel.errorMessage {
                    errorSection(message: errorMessage)
                }

                if viewModel.isLoading && isEmptyState {
                    loadingSection
                } else if isEmptyState {
                    emptySection
                } else {
                    summarySection
                    incomeSection
                    expensesSection
                }
            }
            .navigationTitle("损益表")
            .refreshable {
                await viewModel.refresh()
            }
            .task {
                await viewModel.loadIfNeeded()
            }
        }
    }

    private var isEmptyState: Bool {
        viewModel.incomeAccounts.isEmpty && viewModel.expenseAccounts.isEmpty
    }

    private var showCurrencyCode: Bool {
        currencyDisplayMode == .code
    }

    private func errorSection(message: String) -> some View {
        Section {
            Text(message)
                .font(.footnote)
                .foregroundStyle(.red)
        }
    }

    private var loadingSection: some View {
        Section {
            HStack {
                Spacer()
                ProgressView()
                Spacer()
            }
        }
    }

    private var emptySection: some View {
        Section {
            ContentUnavailableView(
                "暂无损益表数据",
                systemImage: "chart.bar.doc.horizontal",
                description: Text("请检查 Fava 连接设置")
            )
        }
    }

    private var summarySection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("净收入")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    AmountListView(
                        amounts: viewModel.netIncomeAmounts,
                        font: .title2.bold(),
                        showCurrencyCode: showCurrencyCode
                    )
                }

                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("收入")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        AmountListView(
                            amounts: viewModel.totalIncomeAmounts,
                            font: .callout,
                            showCurrencyCode: showCurrencyCode,
                            alignment: .leading
                        )
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("支出")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        AmountListView(
                            amounts: viewModel.totalExpenseAmounts,
                            font: .callout,
                            showCurrencyCode: showCurrencyCode,
                            alignment: .trailing
                        )
                    }
                }

                summaryBarSection
            }
            .padding(.vertical, 8)
        }
    }

    private var summaryBarSection: some View {
        let currencies = viewModel.summaryCurrencies
        return VStack(spacing: 6) {
            ForEach(currencies, id: \.self) { currency in
                SummaryBarRow(
                    currency: currency,
                    income: viewModel.totalIncomeByCurrency[currency] ?? 0,
                    expenses: viewModel.totalExpensesByCurrency[currency] ?? 0,
                    showCurrencyLabel: currencies.count > 1
                )
            }
        }
    }

    private var incomeSection: some View {
        Section {
            DisclosureGroup(isExpanded: $viewModel.incomeExpanded) {
                ForEach(viewModel.incomeAccounts) { account in
                    IncomeStatementAccountTreeRow(
                        account: account,
                        viewModel: viewModel,
                        showCurrencyCode: showCurrencyCode
                    )
                }
            } label: {
                HStack {
                    AccountIcon(accountType: .income)
                    Text("收入 Income")
                        .font(.headline)
                    Spacer()
                    AmountListView(
                        amounts: viewModel.totalIncomeAmounts,
                        font: .callout.bold(),
                        showCurrencyCode: showCurrencyCode
                    )
                }
            }
        }
    }

    private var expensesSection: some View {
        Section {
            DisclosureGroup(isExpanded: $viewModel.expensesExpanded) {
                ForEach(viewModel.expenseAccounts) { account in
                    IncomeStatementAccountTreeRow(
                        account: account,
                        viewModel: viewModel,
                        showCurrencyCode: showCurrencyCode
                    )
                }
            } label: {
                HStack {
                    AccountIcon(accountType: .expenses)
                    Text("支出 Expenses")
                        .font(.headline)
                    Spacer()
                    AmountListView(
                        amounts: viewModel.totalExpenseAmounts,
                        font: .callout.bold(),
                        showCurrencyCode: showCurrencyCode
                    )
                }
            }
        }
    }
}

private struct SummaryBarRow: View {
    let currency: String
    let income: Decimal
    let expenses: Decimal
    let showCurrencyLabel: Bool

    var body: some View {
        HStack(spacing: 8) {
            if showCurrencyLabel {
                Text(currency)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .frame(width: 44, alignment: .leading)
            }

            GeometryReader { geometry in
                let incomeValue = max(income, 0)
                let expenseValue = max(expenses, 0)
                let total = incomeValue + expenseValue
                let hasIncome = incomeValue > 0
                let hasExpense = expenseValue > 0
                let barSpacing: CGFloat = (hasIncome && hasExpense) ? 4 : 0
                let availableWidth = max(geometry.size.width - barSpacing, 0)
                let incomeRatio = total > 0 ? (incomeValue / total) : 0
                let incomeWidth = availableWidth * CGFloat(truncating: incomeRatio as NSDecimalNumber)
                let expenseWidth = availableWidth - incomeWidth

                HStack(spacing: barSpacing) {
                    if hasIncome {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.green)
                            .frame(width: incomeWidth)
                    }

                    if hasExpense {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.red)
                            .frame(width: expenseWidth)
                    }
                }
            }
            .frame(height: 8)
        }
        .frame(height: 8)
    }
}

#Preview {
    PreviewContainer {
        IncomeStatementView()
    }
}
