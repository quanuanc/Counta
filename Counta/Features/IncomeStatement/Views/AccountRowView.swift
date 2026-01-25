import SwiftUI

struct AccountRowView: View {
    let account: Account
    let amounts: [Amount]
    var showCurrencyCode: Bool = false

    @AppStorage(AppStorageKeys.currencyDisplayMode) private var currencyDisplayMode: CurrencyDisplayMode = .symbol

    private var shouldShowCurrencyCode: Bool {
        showCurrencyCode || currencyDisplayMode == .code
    }

    var body: some View {
        HStack {
            Text(account.name)
            Spacer()
            AmountListView(
                amounts: amounts,
                font: .callout,
                showCurrencyCode: shouldShowCurrencyCode
            )
        }
    }
}

struct IncomeStatementAccountTreeRow: View {
    let account: Account
    let viewModel: IncomeStatementViewModel
    let showCurrencyCode: Bool

    var body: some View {
        if account.hasChildren {
            DisclosureGroup(isExpanded: expansionBinding) {
                ForEach(account.children) { child in
                    IncomeStatementAccountTreeRow(
                        account: child,
                        viewModel: viewModel,
                        showCurrencyCode: showCurrencyCode
                    )
                }
            } label: {
                AccountRowView(
                    account: account,
                    amounts: viewModel.displayAmounts(for: account),
                    showCurrencyCode: showCurrencyCode
                )
            }
        } else {
            AccountRowView(
                account: account,
                amounts: viewModel.displayAmounts(for: account),
                showCurrencyCode: showCurrencyCode
            )
        }
    }

    private var expansionBinding: Binding<Bool> {
        Binding(
            get: { viewModel.isAccountExpanded(account.id) },
            set: { viewModel.setAccountExpanded(account.id, isExpanded: $0) }
        )
    }
}

#Preview {
    PreviewContainer {
        List {
            AccountRowView(account: Account(
                id: "Expenses:Food:Dining",
                name: "餐饮",
                type: .expenses,
                balance: 2500
            ), amounts: [Amount(number: -2500, currency: "CNY")], showCurrencyCode: true)
        }
    }
}
