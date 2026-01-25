import Foundation
import SwiftSoup

enum JournalHTMLParser {
    static func parseEntries(from html: String) -> [JournalEntry] {
        let wrappedHTML = "<ul>\(html)</ul>"
        do {
            let document = try SwiftSoup.parseBodyFragment(wrappedHTML)
            guard let rootList = try document.body()?.select("ul").first() else { return [] }
            let items = try rootList.select("> li")
            return try items.compactMap { try parseEntry(from: $0) }
        } catch {
            return []
        }
    }

    private static func parseEntry(from element: Element) throws -> JournalEntry? {
        let classAttribute = try element.attr("class")
        let classTokens = Set(classAttribute.split(separator: " ").map { String($0) })
        let kind = entryKind(from: classTokens)
        guard let date = parseDate(in: element) else { return nil }

        let header = try element.select("> p").first() ?? element
        let flag = try parseFlag(in: header)
        let descriptionElement = try header.select("span.description").first()
        let payee = try parsePayee(in: descriptionElement)
        let narration = try parseNarration(in: descriptionElement, payee: payee)
        let postings = kind == .transaction ? try parsePostings(in: element) : []
        let status = parseStatus(from: classTokens, kind: kind)

        return JournalEntry(
            date: date,
            kind: kind,
            status: status,
            flag: flag,
            payee: payee,
            narration: narration,
            postings: postings
        )
    }

    private static func entryKind(from classes: Set<String>) -> JournalEntryKind {
        if classes.contains("transaction") { return .transaction }
        if classes.contains("open") { return .open }
        if classes.contains("balance") { return .balance }
        if classes.contains("price") { return .price }
        if classes.contains("note") { return .note }
        if classes.contains("pad") { return .pad }
        return .other
    }

    private static func parseStatus(from classes: Set<String>, kind: JournalEntryKind) -> JournalEntryStatus? {
        guard kind == .transaction else { return nil }
        if classes.contains("cleared") { return .cleared }
        if classes.contains("pending") { return .pending }
        if classes.contains("other") { return .other }
        return nil
    }

    private static func parseDate(in element: Element) -> Date? {
        do {
            if let dateCell = try element.select("> p span.datecell").first() {
                let value = try dateCell.text().trimmingCharacters(in: .whitespacesAndNewlines)
                return dateFormatter.date(from: value)
            }
        } catch {
            return nil
        }
        return nil
    }

    private static func parseFlag(in element: Element) throws -> String? {
        guard let flagText = try element.select("span.flag").first()?.text() else { return nil }
        let cleaned = flagText.trimmingCharacters(in: .whitespacesAndNewlines)
        return cleaned.isEmpty ? nil : cleaned
    }

    private static func parsePayee(in descriptionElement: Element?) throws -> String? {
        guard let descriptionElement else { return nil }
        guard let payeeText = try descriptionElement.select("strong.payee").first()?.text() else {
            return nil
        }
        let cleaned = payeeText.trimmingCharacters(in: .whitespacesAndNewlines)
        return cleaned.isEmpty ? nil : cleaned
    }

    private static func parseNarration(in descriptionElement: Element?, payee: String?) throws -> String {
        guard let descriptionElement else { return "" }
        let ownText = descriptionElement.ownText().trimmingCharacters(in: .whitespacesAndNewlines)
        if !ownText.isEmpty {
            return trimNarration(ownText)
        }

        let fullText = try descriptionElement.text().trimmingCharacters(in: .whitespacesAndNewlines)
        if let payee, !payee.isEmpty, fullText.hasPrefix(payee) {
            let trimmed = fullText.dropFirst(payee.count)
            return trimNarration(String(trimmed))
        }
        return trimNarration(fullText)
    }

    private static func trimNarration(_ text: String) -> String {
        let separators = CharacterSet(charactersIn: "•-–—")
        return text.trimmingCharacters(in: separators.union(.whitespacesAndNewlines))
    }

    private static func parsePostings(in element: Element) throws -> [JournalPosting] {
        let postingElements = try element.select("ul.postings > li")
        return try postingElements.compactMap { postingElement in
            guard let descriptionElement = try postingElement.select("span.description").first() else {
                return nil
            }
            let account = try descriptionElement.text().trimmingCharacters(in: .whitespacesAndNewlines)
            guard !account.isEmpty else { return nil }
            let amountText = try extractAmountText(in: postingElement)
            let (amount, rawAmount) = parseAmount(from: amountText)
            return JournalPosting(account: account, amount: amount, rawAmount: rawAmount)
        }
    }

    private static func extractAmountText(in element: Element) throws -> String? {
        let amounts = try element.select("span.num")
        for amountElement in amounts.array() {
            let text = try amountElement.text().trimmingCharacters(in: .whitespacesAndNewlines)
            if !text.isEmpty {
                return text
            }
        }
        return nil
    }

    private static func parseAmount(from text: String?) -> (Amount?, String?) {
        guard let text, !text.isEmpty else { return (nil, nil) }
        let normalized = collapseWhitespace(text.replacingOccurrences(of: "\u{00A0}", with: " "))
        let parts = normalized.split(separator: " ")
        guard parts.count >= 2 else {
            return (nil, normalized)
        }
        let numberString = parts[0].replacingOccurrences(of: ",", with: "")
        let currency = String(parts[1])
        if let decimal = Decimal(string: numberString, locale: posixLocale) {
            return (Amount(number: decimal, currency: currency), nil)
        }
        return (nil, normalized)
    }

    private static func collapseWhitespace(_ text: String) -> String {
        guard let regex = whitespaceRegex else { return text }
        let nsRange = NSRange(text.startIndex..<text.endIndex, in: text)
        let collapsed = regex.stringByReplacingMatches(in: text, range: nsRange, withTemplate: " ")
        return collapsed.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static let posixLocale = Locale(identifier: "en_US_POSIX")

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = posixLocale
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private static let whitespaceRegex = try? NSRegularExpression(pattern: "\\s+", options: [])
}
