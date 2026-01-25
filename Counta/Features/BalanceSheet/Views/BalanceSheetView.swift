import SwiftUI

struct BalanceSheetView: View {
    @State private var viewModel = BalanceSheetViewModel()
    @AppStorage(AppStorageKeys.currencyDisplayMode) private var currencyDisplayMode: CurrencyDisplayMode = .symbol

    var body: some View {
        NavigationStack {
            List {
                if let errorMessage = viewModel.errorMessage {
                    errorSection(message: errorMessage)
                }

                if viewModel.isLoading && isEmptyState {
                    loadingSection
                } else if isEmptyState {
                    emptySection
                } else {
                    summarySection
                    assetsSection
                    liabilitiesSection
                    equitySection
                }
            }
            .navigationTitle("资产负债表")
            .refreshable {
                await viewModel.refresh()
            }
            .task {
                await viewModel.loadIfNeeded()
            }
        }
    }

    private var isEmptyState: Bool {
        viewModel.assetAccounts.isEmpty
            && viewModel.liabilityAccounts.isEmpty
            && viewModel.equityAccounts.isEmpty
    }

    private var showCurrencyCode: Bool {
        currencyDisplayMode == .code
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
                "暂无资产负债表数据",
                systemImage: "chart.bar.doc.horizontal",
                description: Text("请检查 Fava 连接设置")
            )
        }
    }

    private var summarySection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("净资产")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    AmountListView(
                        amounts: viewModel.netWorthAmounts,
                        font: .title2.bold(),
                        showCurrencyCode: showCurrencyCode
                    )
                }

                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("资产")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        AmountListView(
                            amounts: viewModel.totalAssetsAmounts,
                            font: .callout,
                            showCurrencyCode: showCurrencyCode,
                            alignment: .leading
                        )
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("负债")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        AmountListView(
                            amounts: viewModel.totalLiabilitiesAmounts,
                            font: .callout,
                            showCurrencyCode: showCurrencyCode,
                            alignment: .trailing
                        )
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }

    private var assetsSection: some View {
        Section {
            DisclosureGroup(isExpanded: $viewModel.assetsExpanded) {
                ForEach(viewModel.assetAccounts) { account in
                    BalanceSheetAccountTreeRow(
                        account: account,
                        viewModel: viewModel,
                        showCurrencyCode: showCurrencyCode
                    )
                }
            } label: {
                HStack {
                    Text("Assets")
                        .font(.body)
                    Spacer()
                    AmountListView(
                        amounts: viewModel.totalAssetsAmounts,
                        font: .callout.bold(),
                        showCurrencyCode: showCurrencyCode
                    )
                }
            }
        } header: {
            sectionHeader(title: "资产", accountType: .assets)
        }
    }

    private var liabilitiesSection: some View {
        Section {
            DisclosureGroup(isExpanded: $viewModel.liabilitiesExpanded) {
                ForEach(viewModel.liabilityAccounts) { account in
                    BalanceSheetAccountTreeRow(
                        account: account,
                        viewModel: viewModel,
                        showCurrencyCode: showCurrencyCode
                    )
                }
            } label: {
                HStack {
                    Text("Liabilities")
                        .font(.body)
                    Spacer()
                    AmountListView(
                        amounts: viewModel.totalLiabilitiesAmounts,
                        font: .callout.bold(),
                        showCurrencyCode: showCurrencyCode
                    )
                }
            }
        } header: {
            sectionHeader(title: "负债", accountType: .liabilities)
        }
    }

    private var equitySection: some View {
        Section {
            DisclosureGroup(isExpanded: $viewModel.equityExpanded) {
                ForEach(viewModel.equityAccounts) { account in
                    BalanceSheetAccountTreeRow(
                        account: account,
                        viewModel: viewModel,
                        showCurrencyCode: showCurrencyCode
                    )
                }
            } label: {
                HStack {
                    Text("Equity")
                        .font(.body)
                    Spacer()
                    AmountListView(
                        amounts: viewModel.totalEquityAmounts,
                        font: .callout.bold(),
                        showCurrencyCode: showCurrencyCode
                    )
                }
            }
        } header: {
            sectionHeader(title: "权益", accountType: .equity)
        }
    }

    private func sectionHeader(title: String, accountType: AccountType) -> some View {
        HStack(spacing: 8) {
            AccountIcon(accountType: accountType, size: 18)
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .textCase(nil)
    }
}

#Preview {
    PreviewContainer {
        BalanceSheetView()
    }
}
