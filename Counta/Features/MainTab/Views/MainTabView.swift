import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .incomeStatement

    enum Tab: String, CaseIterable {
        case incomeStatement
        case balanceSheet
        case journal
        case settings

        var title: String {
            switch self {
            case .incomeStatement: return "损益表"
            case .balanceSheet: return "资产负债"
            case .journal: return "日记账"
            case .settings: return "设置"
            }
        }

        var icon: String {
            switch self {
            case .incomeStatement: return "chart.bar"
            case .balanceSheet: return "chart.line.uptrend.xyaxis"
            case .journal: return "book"
            case .settings: return "gearshape"
            }
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            IncomeStatementView()
                .tabItem {
                    Label(Tab.incomeStatement.title, systemImage: Tab.incomeStatement.icon)
                }
                .tag(Tab.incomeStatement)

            BalanceSheetView()
                .tabItem {
                    Label(Tab.balanceSheet.title, systemImage: Tab.balanceSheet.icon)
                }
                .tag(Tab.balanceSheet)

            JournalView()
                .tabItem {
                    Label(Tab.journal.title, systemImage: Tab.journal.icon)
                }
                .tag(Tab.journal)

            SettingsView()
                .tabItem {
                    Label(Tab.settings.title, systemImage: Tab.settings.icon)
                }
                .tag(Tab.settings)
        }
    }
}

#Preview {
    MainTabView()
}
