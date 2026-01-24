import SwiftUI

struct AccountRowView: View {
    let account: Account
    var indentLevel: Int = 0

    private var displayAmount: Amount {
        let amount = account.totalBalance
        let signedAmount = account.type == .expenses ? -amount : amount
        return Amount(number: signedAmount, currency: account.currency)
    }

    var body: some View {
        HStack {
            Text(account.name)
                .padding(.leading, CGFloat(indentLevel) * 16)
            Spacer()
            AmountText(
                amount: displayAmount,
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
