import SwiftUI

struct BalanceSheetView: View {
    @State private var viewModel = BalanceSheetViewModel()

    var body: some View {
        NavigationStack {
            List {
                summarySection

                assetsSection

                liabilitiesSection

                equitySection
            }
            .navigationTitle("资产负债表")
            .refreshable {
                await viewModel.refresh()
            }
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
                    AmountText(
                        amount: Amount(number: viewModel.netWorth),
                        font: .title2.bold()
                    )
                }

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("资产")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        AmountText(
                            amount: Amount(number: viewModel.totalAssets),
                            font: .callout
                        )
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("负债")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        AmountText(
                            amount: Amount(number: -viewModel.totalLiabilities),
                            font: .callout
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
                    AccountTreeRow(account: account)
                }
            } label: {
                HStack {
                    AccountIcon(accountType: .assets)
                    Text("资产 Assets")
                        .font(.headline)
                    Spacer()
                    AmountText(
                        amount: Amount(number: viewModel.totalAssets),
                        font: .callout.bold()
                    )
                }
            }
        }
    }

    private var liabilitiesSection: some View {
        Section {
            DisclosureGroup(isExpanded: $viewModel.liabilitiesExpanded) {
                ForEach(viewModel.liabilityAccounts) { account in
                    AccountTreeRow(account: account)
                }
            } label: {
                HStack {
                    AccountIcon(accountType: .liabilities)
                    Text("负债 Liabilities")
                        .font(.headline)
                    Spacer()
                    AmountText(
                        amount: Amount(number: viewModel.totalLiabilities),
                        font: .callout.bold()
                    )
                }
            }
        }
    }

    private var equitySection: some View {
        Section {
            DisclosureGroup(isExpanded: $viewModel.equityExpanded) {
                ForEach(viewModel.equityAccounts) { account in
                    AccountTreeRow(account: account)
                }
            } label: {
                HStack {
                    AccountIcon(accountType: .equity)
                    Text("权益 Equity")
                        .font(.headline)
                    Spacer()
                    AmountText(
                        amount: Amount(number: viewModel.totalEquity),
                        font: .callout.bold()
                    )
                }
            }
        }
    }
}

#Preview {
    BalanceSheetView()
}
