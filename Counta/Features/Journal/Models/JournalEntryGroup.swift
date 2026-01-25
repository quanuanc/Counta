import Foundation

struct JournalEntryGroup: Sendable, Identifiable {
    let date: Date
    var entries: [JournalEntry]

    var id: Date { date }
}

extension JournalEntryGroup {
    static func makeGroups(from entries: [JournalEntry]) -> [JournalEntryGroup] {
        var groups: [JournalEntryGroup] = []
        var indexByDate: [Date: Int] = [:]

        for entry in entries {
            let day = entry.date.startOfDay
            if let index = indexByDate[day] {
                groups[index].entries.append(entry)
            } else {
                indexByDate[day] = groups.count
                groups.append(JournalEntryGroup(date: day, entries: [entry]))
            }
        }

        return groups
    }
}
