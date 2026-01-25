import SwiftUI

struct AccountRowView: View {
    let account: Account
    let amounts: [Amount]
    var showCurrencyCode: Bool = false
    var indentLevel: Int = 0

    @AppStorage(AppStorageKeys.currencyDisplayMode) private var currencyDisplayMode: CurrencyDisplayMode = .symbol

    private var shouldShowCurrencyCode: Bool {
        showCurrencyCode || currencyDisplayMode == .code
    }

    var body: some View {
        HStack {
            Text(account.name)
                .padding(.leading, CGFloat(indentLevel) * 16)
            Spacer()
            AmountListView(
                amounts: amounts,
                font: .callout,
                showCurrencyCode: shouldShowCurrencyCode
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
        ), amounts: [Amount(number: -2500, currency: "CNY")], showCurrencyCode: true)
    }
}
