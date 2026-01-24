import Foundation

struct IncomeStatementResponse: Decodable, Sendable {
    let data: IncomeStatementData
    let mtime: String?
}

struct IncomeStatementData: Decodable, Sendable {
    let trees: [IncomeStatementTreeNode]
    let dateRange: IncomeStatementDateRange?

    enum CodingKeys: String, CodingKey {
        case trees
        case dateRange = "date_range"
    }
}

struct IncomeStatementDateRange: Decodable, Sendable {
    let begin: String
    let end: String
}

struct IncomeStatementTreeNode: Decodable, Sendable {
    let account: String
    let balance: FavaBalance?
    let balanceChildren: FavaBalance?
    let children: [IncomeStatementTreeNode]

    enum CodingKeys: String, CodingKey {
        case account
        case balance
        case balanceChildren = "balance_children"
        case children
    }
}

struct FavaBalance: Decodable, Sendable {
    let values: [String: Decimal]

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            values = [:]
            return
        }

        let raw = try container.decode([String: FavaDecimal].self)
        values = raw.mapValues { $0.value }
    }
}

struct FavaDecimal: Decodable, Sendable {
    let value: Decimal

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let decimal = try? container.decode(Decimal.self) {
            value = decimal
            return
        }
        if let double = try? container.decode(Double.self) {
            value = Decimal(double)
            return
        }
        if let string = try? container.decode(String.self) {
            let sanitized = string.replacingOccurrences(of: ",", with: "")
            if let decimal = Decimal(string: sanitized, locale: Locale(identifier: "en_US_POSIX")) {
                value = decimal
                return
            }
        }
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported decimal format")
    }
}
