import SwiftUI

struct AccountTreeRow: View {
    let account: Account
    @State private var isExpanded = false

    var body: some View {
        if account.hasChildren {
            DisclosureGroup(isExpanded: $isExpanded) {
                ForEach(account.children) { child in
                    AccountTreeRow(account: child)
                }
            } label: {
                accountLabel
            }
        } else {
            accountLabel
        }
    }

    private var accountLabel: some View {
        HStack {
            Text(account.name)
            Spacer()
            AmountText(
                amount: Amount(number: account.totalBalance, currency: account.currency),
                font: .callout
            )
        }
    }
}

#Preview {
    List {
        AccountTreeRow(account: Account(
            id: "Assets:Bank",
            name: "银行账户",
            type: .assets,
            balance: 0,
            children: [
                Account(id: "Assets:Bank:CCB", name: "建设银行", type: .assets, balance: 100000),
                Account(id: "Assets:Bank:CMB", name: "招商银行", type: .assets, balance: 80000),
            ]
        ))
    }
}
