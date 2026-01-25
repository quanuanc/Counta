import Foundation

struct JournalResponse: Decodable, Sendable {
    let data: JournalData
    let mtime: String?
}

struct JournalData: Decodable, Sendable {
    let journal: String
    let page: Int
    let totalPages: Int

    enum CodingKeys: String, CodingKey {
        case journal
        case page
        case totalPages = "total_pages"
    }
}

enum JournalOrder: String, Sendable {
    case desc
    case asc
}
