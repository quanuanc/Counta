import SwiftUI

struct CurrencySettingsView: View {
    @AppStorage(AppStorageKeys.currencyDisplayMode) private var currencyDisplayMode: CurrencyDisplayMode = .symbol

    var body: some View {
        Form {
            Section {
                Picker(L10n.Settings.currencyDisplay, selection: $currencyDisplayMode) {
                    ForEach(CurrencyDisplayMode.allCases) { mode in
                        Text(mode.displayTitle)
                            .tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            } header: {
                Text(L10n.CurrencySettings.sectionDisplay)
            } footer: {
                Text(L10n.CurrencySettings.footerUncommonCurrencySymbolNote)
            }
        }
        .navigationTitle(L10n.CurrencySettings.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    PreviewContainer {
        NavigationStack {
            CurrencySettingsView()
        }
    }
}
