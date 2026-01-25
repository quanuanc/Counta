import SwiftUI

struct CurrencySettingsView: View {
    @AppStorage(AppStorageKeys.currencyDisplayMode) private var currencyDisplayMode: CurrencyDisplayMode = .symbol

    var body: some View {
        Form {
            Section {
                Picker("货币显示", selection: $currencyDisplayMode) {
                    ForEach(CurrencyDisplayMode.allCases) { mode in
                        Text("\(mode.title) (\(mode.example))")
                            .tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            } header: {
                Text("显示")
            } footer: {
                Text("当货币没有常见符号时，将使用通用货币符号 ¤。")
            }
        }
        .navigationTitle("货币设置")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        CurrencySettingsView()
    }
}
