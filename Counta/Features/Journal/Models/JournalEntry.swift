import Foundation

enum JournalEntryKind: String, Sendable {
    case transaction
    case open
    case balance
    case price
    case note
    case pad
    case other
}

enum JournalEntryStatus: String, Sendable {
    case cleared
    case pending
    case other
}

struct JournalEntry: Identifiable, Hashable, Sendable {
    let id: UUID
    let date: Date
    let kind: JournalEntryKind
    let status: JournalEntryStatus?
    let flag: String?
    let payee: String?
    let narration: String
    let postings: [JournalPosting]

    init(
        id: UUID = UUID(),
        date: Date,
        kind: JournalEntryKind,
        status: JournalEntryStatus? = nil,
        flag: String? = nil,
        payee: String? = nil,
        narration: String,
        postings: [JournalPosting] = []
    ) {
        self.id = id
        self.date = date
        self.kind = kind
        self.status = status
        self.flag = flag
        self.payee = payee
        self.narration = narration
        self.postings = postings
    }

    var title: String {
        if let payee, !payee.isEmpty {
            return payee
        }
        return narration
    }

    var subtitle: String? {
        guard let payee, !payee.isEmpty else { return nil }
        return narration.isEmpty ? nil : narration
    }

    var isTransaction: Bool {
        kind == .transaction
    }

    var isExpense: Bool {
        postings.contains { $0.account.hasPrefix("Expenses:") }
    }

    var isIncome: Bool {
        postings.contains { $0.account.hasPrefix("Income:") }
    }

    var primaryAmount: Amount? {
        postings.compactMap(\.amount).first(where: { $0.isNegative })
            ?? postings.compactMap(\.amount).first
    }

    var displayAmount: Amount? {
        guard let amount = primaryAmount else { return nil }
        if isExpense {
            return Amount(number: -amount.absoluteValue.number, currency: amount.currency)
        }
        if isIncome {
            return amount.absoluteValue
        }
        return amount
    }
}

struct JournalPosting: Identifiable, Hashable, Sendable {
    let id: UUID
    let account: String
    let amount: Amount?
    let rawAmount: String?

    init(
        id: UUID = UUID(),
        account: String,
        amount: Amount?,
        rawAmount: String? = nil
    ) {
        self.id = id
        self.account = account
        self.amount = amount
        self.rawAmount = rawAmount
    }
}
