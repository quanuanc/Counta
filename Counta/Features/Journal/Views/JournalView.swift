import SwiftUI

struct JournalView: View {
    @State private var viewModel = JournalViewModel()
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            List {
                if let errorMessage = viewModel.errorMessage {
                    errorSection(message: errorMessage)
                }

                if viewModel.isLoading && viewModel.groupedEntries.isEmpty {
                    loadingSection
                } else if viewModel.groupedEntries.isEmpty {
                    emptySection
                } else {
                    entriesSection
                    if viewModel.hasMorePages {
                        loadMoreSection
                    }
                }
            }
            .navigationTitle(L10n.Titles.journal)
            .searchable(text: $searchText, prompt: L10n.Journal.searchPrompt)
            .refreshable {
                await viewModel.refresh()
            }
            .task {
                await viewModel.loadIfNeeded()
            }
            .onSubmit(of: .search) {
                viewModel.search(query: searchText)
            }
            .onChange(of: searchText) { _, newValue in
                if newValue.isEmpty {
                    viewModel.search(query: "")
                }
            }
            .navigationDestination(for: JournalEntry.self) { entry in
                JournalEntryDetailView(entry: entry)
            }
        }
    }

    private func errorSection(message: String) -> some View {
        Section {
            Text(message)
                .font(.footnote)
                .foregroundStyle(.red)
        }
    }

    private var loadingSection: some View {
        Section {
            HStack {
                Spacer()
                ProgressView()
                Spacer()
            }
        }
    }

    private var emptySection: some View {
        Section {
            ContentUnavailableView(
                L10n.Journal.emptyTitle,
                systemImage: "book",
                description: Text(L10n.Common.checkFavaSettings)
            )
        }
    }

    private var entriesSection: some View {
        JournalEntryGroupListView(groups: viewModel.groupedEntries)
    }

    private var loadMoreSection: some View {
        Section {
            Button {
                Task {
                    await viewModel.loadNextPage()
                }
            } label: {
                HStack {
                    Spacer()
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Text(L10n.Journal.loadMore)
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isLoading)
        }
    }
}

#Preview {
    PreviewContainer {
        JournalView()
    }
}
