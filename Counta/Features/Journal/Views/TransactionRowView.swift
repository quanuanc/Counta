import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction

    private var icon: String {
        if transaction.isExpense {
            return expenseIcon
        } else if transaction.isIncome {
            return "arrow.down.circle.fill"
        }
        return "arrow.left.arrow.right.circle"
    }

    private var expenseIcon: String {
        guard let account = transaction.primaryAccount else { return "creditcard" }

        if account.contains("Food") || account.contains("Dining") {
            return "fork.knife"
        } else if account.contains("Transport") {
            return "tram.fill"
        } else if account.contains("Shopping") {
            return "bag.fill"
        } else if account.contains("Rent") || account.contains("Housing") {
            return "house.fill"
        } else if account.contains("Entertainment") {
            return "gamecontroller.fill"
        }
        return "creditcard"
    }

    private var iconColor: Color {
        if transaction.isIncome {
            return .green
        } else if transaction.isExpense {
            return .red
        }
        return .blue
    }

    private var displayAmount: Amount? {
        if transaction.isExpense {
            if let amount = transaction.primaryAmount {
                return Amount(number: -amount.number, currency: amount.currency)
            }
        }
        return transaction.primaryAmount
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(iconColor)
                .frame(width: 36, height: 36)
                .background(iconColor.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.payee ?? transaction.narration)
                    .font(.body)
                    .lineLimit(1)

                Text(transaction.primaryAccount ?? "")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                if let amount = displayAmount {
                    AmountText(amount: amount, font: .callout.bold())
                }

                Text(transaction.date.timeDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    PreviewContainer {
        List {
            TransactionRowView(transaction: Transaction(
                date: Date(),
                payee: "午餐",
                narration: "和同事吃饭",
                postings: [
                    Posting(account: "Expenses:Food:Dining", amount: Amount(number: 35)),
                    Posting(account: "Assets:Alipay", amount: Amount(number: -35)),
                ]
            ))

            TransactionRowView(transaction: Transaction(
                date: Date(),
                narration: "工资",
                postings: [
                    Posting(account: "Assets:Bank:CMB", amount: Amount(number: 20000)),
                    Posting(account: "Income:Salary", amount: Amount(number: -20000)),
                ]
            ))
        }
    }
}
