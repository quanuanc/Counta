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
            .navigationTitle("日记账")
            .searchable(text: $searchText, prompt: "搜索交易")
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
                "暂无日记账数据",
                systemImage: "book",
                description: Text("请检查 Fava 连接设置")
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
                        Text("加载更多")
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
