import Foundation

struct BalanceSheetResponse: Decodable, Sendable {
    let data: BalanceSheetData
    let mtime: String?
}

struct BalanceSheetData: Decodable, Sendable {
    let trees: [BalanceSheetTreeNode]
    let dateRange: BalanceSheetDateRange?

    enum CodingKeys: String, CodingKey {
        case trees
        case dateRange = "date_range"
    }
}

struct BalanceSheetDateRange: Decodable, Sendable {
    let begin: String
    let end: String
}

struct BalanceSheetTreeNode: Decodable, Sendable {
    let account: String
    let balance: FavaBalance?
    let balanceChildren: FavaBalance?
    let children: [BalanceSheetTreeNode]

    enum CodingKeys: String, CodingKey {
        case account
        case balance
        case balanceChildren = "balance_children"
        case children
    }
}
