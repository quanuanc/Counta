import Foundation

@Observable
final class JournalViewModel: @unchecked Sendable {
    var isLoading = false
    var errorMessage: String?
    private(set) var entries: [JournalEntry] = []
    private(set) var groupedEntries: [JournalEntryGroup] = []
    private(set) var currentPage = 1
    private(set) var totalPages = 1

    private var hasLoaded = false
    private var allEntries: [JournalEntry] = []
    private var searchQuery = ""
    private let order: JournalOrder = .desc
    private let service = JournalService()

    var hasMorePages: Bool {
        currentPage < totalPages
    }

    func loadIfNeeded() async {
        guard !hasLoaded else { return }
        await refresh()
    }

    func refresh() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let baseURL = UserDefaults.standard.string(forKey: AppStorageKeys.favaApiURL) ?? ""
        do {
            let data = try await service.fetchJournal(baseURL: baseURL, page: 1, order: order)
            apply(data, appending: false)
            hasLoaded = true
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription
                ?? String(localized: L10n.Errors.vmLoadJournal)
        }
    }

    func loadNextPage() async {
        guard !isLoading, hasMorePages else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let baseURL = UserDefaults.standard.string(forKey: AppStorageKeys.favaApiURL) ?? ""
        let nextPage = currentPage + 1
        do {
            let data = try await service.fetchJournal(baseURL: baseURL, page: nextPage, order: order)
            apply(data, appending: true)
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription
                ?? String(localized: L10n.Errors.vmLoadJournalMore)
        }
    }

    func search(query: String) {
        searchQuery = query
        applyFilter()
    }

    private func apply(_ data: JournalData, appending: Bool) {
        let parsedEntries = JournalHTMLParser.parseEntries(from: data.journal)
        if appending {
            allEntries.append(contentsOf: parsedEntries)
        } else {
            allEntries = parsedEntries
        }
        currentPage = data.page
        totalPages = data.totalPages
        applyFilter()
    }

    private func applyFilter() {
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            entries = allEntries
            groupedEntries = JournalEntryGroup.makeGroups(from: allEntries)
            return
        }

        let lowercased = query.localizedLowercase
        entries = allEntries.filter { entry in
            let payee = entry.payee?.localizedLowercase ?? ""
            return entry.narration.localizedLowercase.contains(lowercased)
                || payee.contains(lowercased)
        }
        groupedEntries = JournalEntryGroup.makeGroups(from: entries)
    }
}
