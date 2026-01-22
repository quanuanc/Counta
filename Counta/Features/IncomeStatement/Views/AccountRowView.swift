import SwiftUI

struct AccountRowView: View {
    let account: Account
    var indentLevel: Int = 0

    var body: some View {
        HStack {
            Text(account.name)
                .padding(.leading, CGFloat(indentLevel) * 16)
            Spacer()
            AmountText(
                amount: Amount(number: account.balance, currency: account.currency),
                font: .callout
            )
        }
    }
}

#Preview {
    List {
        AccountRowView(account: Account(
            id: "Expenses:Food:Dining",
            name: "餐饮",
            type: .expenses,
            balance: 2500
        ))
    }
}
