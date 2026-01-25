import SwiftUI

struct JournalEntryDetailView: View {
    let entry: JournalEntry

    private var payeeValue: String {
        let trimmed = entry.payee?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? "—" : trimmed
    }

    private var narrationValue: String {
        let trimmed = entry.narration.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "—" : trimmed
    }

    var body: some View {
        List {
            overviewSection
            descriptionSection
            postingsSection
        }
        .navigationTitle(entry.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var overviewSection: some View {
        Section("概览") {
            LabeledContent("日期", value: entry.date.formatted(.dateTime.year().month().day()))
            LabeledContent("类型", value: entry.kind.localizedTitle)

            if let status = entry.status {
                LabeledContent("状态", value: status.localizedTitle)
            }

            if let flag = entry.flag, !flag.isEmpty {
                LabeledContent("标记", value: flag)
            }

            if let amount = entry.displayAmount {
                HStack {
                    Text("金额")
                    Spacer()
                    AmountText(amount: amount, showSign: true, font: .body.weight(.semibold))
                }
            }
        }
    }

    private var descriptionSection: some View {
        Section("描述") {
            LabeledContent("交易方", value: payeeValue)
            LabeledContent("摘要", value: narrationValue)
        }
    }

    private var postingsSection: some View {
        Section("分录") {
            if entry.postings.isEmpty {
                Text("暂无分录")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(entry.postings) { posting in
                    JournalPostingDetailRow(posting: posting)
                }
            }
        }
    }
}

private struct JournalPostingDetailRow: View {
    let posting: JournalPosting

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(posting.account)
                .font(.body)
                .lineLimit(2)

            Spacer()

            if let amount = posting.amount {
                AmountText(amount: amount, font: .body)
            } else if let rawAmount = posting.rawAmount {
                Text(rawAmount)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private extension JournalEntryKind {
    var localizedTitle: String {
        switch self {
        case .transaction:
            return "交易"
        case .open:
            return "开账"
        case .balance:
            return "余额"
        case .price:
            return "价格"
        case .note:
            return "备注"
        case .pad:
            return "调整"
        case .other:
            return "其他"
        }
    }
}

private extension JournalEntryStatus {
    var localizedTitle: String {
        switch self {
        case .cleared:
            return "已清算"
        case .pending:
            return "待确认"
        case .other:
            return "其他"
        }
    }
}

#Preview {
    PreviewContainer {
        NavigationStack {
            JournalEntryDetailView(entry: JournalEntry(
                date: Date(),
                kind: .transaction,
                status: .cleared,
                flag: "*",
                payee: "Cafe Modagor",
                narration: "Eating out with Julie",
                postings: [
                    JournalPosting(account: "Liabilities:US:Chase:Slate", amount: Amount(number: -33.71, currency: "USD")),
                    JournalPosting(account: "Expenses:Food:Restaurant", amount: Amount(number: 33.71, currency: "USD")),
                ]
            ))
        }
    }
}
