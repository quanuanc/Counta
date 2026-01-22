import Foundation

struct Posting: Identifiable, Hashable, Sendable {
    let id: UUID
    var account: String
    var amount: Amount

    init(id: UUID = UUID(), account: String, amount: Amount) {
        self.id = id
        self.account = account
        self.amount = amount
    }
}
