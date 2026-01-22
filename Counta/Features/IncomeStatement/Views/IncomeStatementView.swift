import SwiftUI

struct IncomeStatementView: View {
    @State private var viewModel = IncomeStatementViewModel()

    var body: some View {
        NavigationStack {
            List {
                summarySection

                incomeSection

                expensesSection
            }
            .navigationTitle("损益表")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.showDatePicker = true
                    } label: {
                        Text(viewModel.selectedPeriod.monthYearDescription)
                            .foregroundStyle(.primary)
                        Image(systemName: "chevron.down")
                    }
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
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
                ForEach(viewModel.incomeAccounts) { account in
                    AccountRowView(account: account)
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
                ForEach(viewModel.expenseAccounts) { account in
                    AccountRowView(account: account)
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
