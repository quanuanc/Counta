import SwiftUI

struct AmountListView: View {
    let amounts: [Amount]
    var font: Font = .body
    var showSign: Bool = false
    var showCurrencyCode: Bool = false
    var alignment: HorizontalAlignment = .trailing
    var spacing: CGFloat = 2

    var body: some View {
        VStack(alignment: alignment, spacing: spacing) {
            ForEach(amounts, id: \.self) { amount in
                AmountText(
                    amount: amount,
                    showSign: showSign,
                    font: font,
                    showCurrencyCode: showCurrencyCode
                )
            }
        }
    }
}

#Preview {
    AmountListView(
        amounts: [
            Amount(number: 1200, currency: "USD"),
            Amount(number: -530, currency: "EUR"),
        ],
        font: .callout,
        showCurrencyCode: true
    )
}
