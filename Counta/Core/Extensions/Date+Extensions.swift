import Foundation

extension Date {
    private static let relativeDayFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = .current
        formatter.unitsStyle = .full
        formatter.dateTimeStyle = .named
        return formatter
    }()

    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var startOfMonth: Date {
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: components) ?? self
    }

    var endOfMonth: Date {
        guard let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: startOfMonth) else {
            return self
        }
        return Calendar.current.date(byAdding: .day, value: -1, to: nextMonth) ?? self
    }

    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }

    var relativeDescription: String {
        if isToday || isYesterday {
            return Self.relativeDayFormatter.localizedString(for: self, relativeTo: Date())
        }
        return formatted(.dateTime.month().day())
    }

    var monthYearDescription: String {
        formatted(.dateTime.year().month())
    }

    var journalSectionTitle: String {
        if isToday || isYesterday {
            return Self.relativeDayFormatter.localizedString(for: self, relativeTo: Date())
        }
        if Calendar.current.isDate(self, equalTo: Date(), toGranularity: .year) {
            return formatted(.dateTime.month().day())
        }
        return formatted(.dateTime.year().month().day())
    }

    var timeDescription: String {
        formatted(.dateTime.hour().minute())
    }
}
