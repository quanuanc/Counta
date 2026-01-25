import SwiftUI

struct JournalEntryGroupListView<Destination: View>: View {
    let groups: [JournalEntryGroup]
    private let destination: ((JournalEntry) -> Destination)?
    private let usesValueNavigation: Bool

    init(groups: [JournalEntryGroup]) where Destination == EmptyView {
        self.groups = groups
        self.destination = nil
        self.usesValueNavigation = true
    }

    init(
        groups: [JournalEntryGroup],
        @ViewBuilder destination: @escaping (JournalEntry) -> Destination
    ) {
        self.groups = groups
        self.destination = destination
        self.usesValueNavigation = false
    }

    var body: some View {
        ForEach(groups) { group in
            Section {
                ForEach(group.entries) { entry in
                    entryRow(for: entry)
                }
            } header: {
                Text(group.date.journalSectionTitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .textCase(nil)
            }
        }
    }

    @ViewBuilder
    private func entryRow(for entry: JournalEntry) -> some View {
        if usesValueNavigation {
            NavigationLink(value: entry) {
                JournalEntryRowView(entry: entry)
            }
        } else if let destination {
            NavigationLink {
                destination(entry)
            } label: {
                JournalEntryRowView(entry: entry)
            }
        }
    }
}

#Preview {
    PreviewContainer {
        NavigationStack {
            List {
                JournalEntryGroupListView(groups: [
                    JournalEntryGroup(date: Date(), entries: [
                        JournalEntry(
                            date: Date(),
                            kind: .transaction,
                            payee: "Cafe Modagor",
                            narration: "Eating out with Julie",
                            postings: []
                        )
                    ])
                ]) { entry in
                    JournalEntryDetailView(entry: entry)
                }
            }
        }
    }
}
