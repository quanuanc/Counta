import SwiftUI

struct IncomeStatementView: View {
    @State private var viewModel = IncomeStatementViewModel()

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
                    AmountText(
                        amount: Amount(number: viewModel.netIncome),
                        font: .title2.bold()
                    )
                }

                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("收入")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        AmountText(
                            amount: Amount(number: viewModel.totalIncome),
                            font: .callout
                        )
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("支出")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        AmountText(
                            amount: Amount(number: -viewModel.totalExpenses),
                            font: .callout
                        )
                    }
                }

                GeometryReader { geometry in
                    HStack(spacing: 4) {
                        let total = viewModel.totalIncome + viewModel.totalExpenses
                        let incomeWidth = total > 0
                            ? geometry.size.width * CGFloat(truncating: (viewModel.totalIncome / total) as NSDecimalNumber)
                            : geometry.size.width * 0.5

                        RoundedRectangle(cornerRadius: 4)
                            .fill(.green)
                            .frame(width: max(incomeWidth, 4))

                        RoundedRectangle(cornerRadius: 4)
                            .fill(.red)
                            .frame(width: max(geometry.size.width - incomeWidth - 4, 4))
                    }
                }
                .frame(height: 8)
            }
            .padding(.vertical, 8)
        }
    }

    private var incomeSection: some View {
        Section {
            DisclosureGroup(isExpanded: $viewModel.incomeExpanded) {
                ForEach(viewModel.incomeRows) { row in
                    AccountRowView(account: row.account, indentLevel: row.indentLevel)
                }
            } label: {
                HStack {
                    AccountIcon(accountType: .income)
                    Text("收入 Income")
                        .font(.headline)
                    Spacer()
                    AmountText(
                        amount: Amount(number: viewModel.totalIncome),
                        font: .callout.bold()
                    )
                }
            }
        }
    }

    private var expensesSection: some View {
        Section {
            DisclosureGroup(isExpanded: $viewModel.expensesExpanded) {
                ForEach(viewModel.expenseRows) { row in
                    AccountRowView(account: row.account, indentLevel: row.indentLevel)
                }
            } label: {
                HStack {
                    AccountIcon(accountType: .expenses)
                    Text("支出 Expenses")
                        .font(.headline)
                    Spacer()
                    AmountText(
                        amount: Amount(number: -viewModel.totalExpenses),
                        font: .callout.bold()
                    )
                }
            }
        }
    }
}

#Preview {
    IncomeStatementView()
}
