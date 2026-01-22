import Foundation

struct Transaction: Identifiable, Hashable, Sendable {
    let id: UUID
    var date: Date
    var payee: String?
    var narration: String
    var tags: [String]
    var postings: [Posting]
    var metadata: [String: String]

    init(
        id: UUID = UUID(),
        date: Date,
        payee: String? = nil,
        narration: String,
        tags: [String] = [],
        postings: [Posting] = [],
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.date = date
        self.payee = payee
        self.narration = narration
        self.tags = tags
        self.postings = postings
        self.metadata = metadata
    }

    var primaryAmount: Amount? {
        postings.first(where: { $0.amount.isNegative })?.amount.absoluteValue
            ?? postings.first?.amount
    }

    var primaryAccount: String? {
        postings.first(where: { $0.amount.isNegative })?.account
            ?? postings.first?.account
    }

    var isExpense: Bool {
        postings.contains { $0.account.hasPrefix("Expenses:") }
    }

    var isIncome: Bool {
        postings.contains { $0.account.hasPrefix("Income:") }
    }
}
