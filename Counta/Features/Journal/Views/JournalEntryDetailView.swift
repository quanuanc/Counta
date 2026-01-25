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
        Section(L10n.Journal.detailOverview) {
            LabeledContent(L10n.Journal.detailDate, value: entry.date.formatted(.dateTime.year().month().day()))
            LabeledContent(L10n.Journal.detailKind, value: String(localized: entry.kind.localizedTitle))

            if let status = entry.status {
                LabeledContent(L10n.Journal.detailStatus, value: String(localized: status.localizedTitle))
            }

            if let flag = entry.flag, !flag.isEmpty {
                LabeledContent(L10n.Journal.detailFlag, value: flag)
            }

            if let amount = entry.displayAmount {
                HStack {
                    Text(L10n.Journal.detailAmount)
                    Spacer()
                    AmountText(amount: amount, showSign: true, font: .body.weight(.semibold))
                }
            }
        }
    }

    private var descriptionSection: some View {
        Section(L10n.Journal.detailDescription) {
            LabeledContent(L10n.Journal.detailPayee, value: payeeValue)
            LabeledContent(L10n.Journal.detailNarration, value: narrationValue)
        }
    }

    private var postingsSection: some View {
        Section(L10n.Journal.detailPostings) {
            if entry.postings.isEmpty {
                Text(L10n.Journal.detailNoPostings)
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
