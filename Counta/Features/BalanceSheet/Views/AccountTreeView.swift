import SwiftUI

struct BalanceSheetAccountTreeRow: View {
    let account: Account
    let viewModel: BalanceSheetViewModel
    let showCurrencyCode: Bool

    var body: some View {
        if account.hasChildren {
            DisclosureGroup(isExpanded: expansionBinding) {
                ForEach(account.children) { child in
                    BalanceSheetAccountTreeRow(
                        account: child,
                        viewModel: viewModel,
                        showCurrencyCode: showCurrencyCode
                    )
                }
            } label: {
                accountLabel
            }
        } else {
            accountLabel
        }
    }

    private var accountLabel: some View {
        NavigationLink {
            AccountDetailView(
                account: account,
                balanceAmounts: viewModel.displayAmounts(for: account)
            )
        } label: {
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
