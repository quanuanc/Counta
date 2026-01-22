import Foundation

struct TransactionGroup: Sendable {
    let date: Date
    let transactions: [Transaction]
}

@Observable
final class JournalViewModel: @unchecked Sendable {
    var showAddTransaction = false
    private var allTransactions: [Transaction] = []
    private(set) var groupedTransactions: [TransactionGroup] = []

    init() {
        loadMockData()
        groupTransactions()
    }

    func refresh() async {
        try? await Task.sleep(for: .milliseconds(500))
        loadMockData()
        groupTransactions()
    }

    func search(query: String) {
        if query.isEmpty {
            groupTransactions()
            return
        }

        let filtered = allTransactions.filter { transaction in
            transaction.narration.localizedCaseInsensitiveContains(query)
            || (transaction.payee?.localizedCaseInsensitiveContains(query) ?? false)
            || transaction.postings.contains { $0.account.localizedCaseInsensitiveContains(query) }
        }

        groupTransactions(from: filtered)
    }

    func delete(_ transaction: Transaction) {
        allTransactions.removeAll { $0.id == transaction.id }
        groupTransactions()
    }

    private func groupTransactions(from transactions: [Transaction]? = nil) {
        let source = transactions ?? allTransactions
        let grouped = Dictionary(grouping: source) { $0.date.startOfDay }
        groupedTransactions = grouped
            .map { TransactionGroup(date: $0.key, transactions: $0.value) }
            .sorted { $0.date > $1.date }
    }

    private func loadMockData() {
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        allTransactions = [
            Transaction(
                date: calendar.date(bySettingHour: 12, minute: 30, second: 0, of: today)!,
                payee: "午餐",
                narration: "和同事吃饭",
                postings: [
                    Posting(account: "Expenses:Food:Dining", amount: Amount(number: 35)),
                    Posting(account: "Assets:Alipay", amount: Amount(number: -35)),
                ]
            ),
            Transaction(
                date: calendar.date(bySettingHour: 8, minute: 15, second: 0, of: today)!,
                payee: "地铁",
                narration: "通勤",
                postings: [
                    Posting(account: "Expenses:Transport", amount: Amount(number: 6)),
                    Posting(account: "Assets:TransportCard", amount: Amount(number: -6)),
                ]
            ),
            Transaction(
                date: calendar.date(bySettingHour: 10, minute: 0, second: 0, of: yesterday)!,
                narration: "工资",
                postings: [
                    Posting(account: "Assets:Bank:CMB", amount: Amount(number: 20000)),
                    Posting(account: "Income:Salary", amount: Amount(number: -20000)),
                ]
            ),
            Transaction(
                date: calendar.date(bySettingHour: 19, minute: 30, second: 0, of: yesterday)!,
                payee: "超市购物",
                narration: "日用品采购",
                postings: [
                    Posting(account: "Expenses:Shopping", amount: Amount(number: 256.5)),
                    Posting(account: "Assets:WeChat", amount: Amount(number: -256.5)),
                ]
            ),
        ]
    }
}
