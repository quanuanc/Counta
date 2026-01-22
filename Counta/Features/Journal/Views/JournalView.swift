import SwiftUI

struct JournalView: View {
    @State private var viewModel = JournalViewModel()
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.groupedTransactions, id: \.date) { group in
                    Section {
                        ForEach(group.transactions) { transaction in
                            TransactionRowView(transaction: transaction)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        viewModel.delete(transaction)
                                    } label: {
                                        Label("删除", systemImage: "trash")
                                    }
                                }
                        }
                    } header: {
                        Text("\(group.date.relativeDescription) - \(group.date, format: .dateTime.month().day())")
                    }
                }
            }
            .navigationTitle("日记账")
            .searchable(text: $searchText, prompt: "搜索交易")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.showAddTransaction = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
            .onChange(of: searchText) { _, newValue in
                viewModel.search(query: newValue)
            }
        }
    }
}

#Preview {
    JournalView()
}
