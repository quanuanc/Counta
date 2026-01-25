import SwiftUI

struct JournalEntryRowView: View {
    let entry: JournalEntry

    private var trimmedNarration: String {
        entry.narration.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedPayee: String {
        entry.payee?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    private var primaryText: String {
        if !trimmedNarration.isEmpty {
            return trimmedNarration
        }
        if !trimmedPayee.isEmpty {
            return trimmedPayee
        }
        return "—"
    }

    private var secondaryText: String? {
        if trimmedNarration.isEmpty {
            return nil
        }
        return trimmedPayee.isEmpty ? nil : trimmedPayee
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(primaryText)
                .font(.body.weight(.semibold))
                .lineLimit(1)

            if let secondaryText {
                Text(secondaryText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    PreviewContainer {
        List {
            JournalEntryRowView(entry: JournalEntry(
                date: Date(),
                kind: .transaction,
                payee: "Cafe Modagor",
                narration: "Eating out with Julie",
                postings: []
            ))

            JournalEntryRowView(entry: JournalEntry(
                date: Date(),
                kind: .open,
                narration: "Assets:Cash"
            ))
        }
    }
}
