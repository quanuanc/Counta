import Foundation

struct AccountDetailResponse: Decodable, Sendable {
    let data: AccountDetailData
    let mtime: String?
}

struct AccountDetailData: Decodable, Sendable {
    let charts: [AccountDetailChart]
    let journal: String
}

struct AccountDetailChart: Decodable, Sendable {
    let label: String
    let type: String
    let data: [AccountDetailChartPoint]
}

struct AccountDetailChartPoint: Decodable, Sendable {
    let date: String
    let balance: FavaBalance?

    enum CodingKeys: String, CodingKey {
        case date
        case balance
    }
}
