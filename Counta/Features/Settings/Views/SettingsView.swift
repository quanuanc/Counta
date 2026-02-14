import SwiftUI

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()
    @AppStorage(AppStorageKeys.favaBaseURL) private var storedFavaBaseURL = ""
    @AppStorage(AppStorageKeys.favaApiURL) private var storedFavaApiURL = ""
    @AppStorage(AppStorageKeys.currencyDisplayMode) private var currencyDisplayMode: CurrencyDisplayMode = .symbol

    var body: some View {
        NavigationStack {
            Form {
                favaConnectionSection
                displaySection
                aboutSection
            }
            .navigationTitle(L10n.Titles.settings)
        }
    }

    private var favaConnectionSection: some View {
        Section(L10n.Settings.sectionConnection) {
            NavigationLink {
                WelcomeView(context: .settings)
            } label: {
                HStack {
                    Image(systemName: "dot.radiowaves.left.and.right")
                        .foregroundStyle(.blue)
                        .frame(width: 28)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(L10n.Settings.favaServer)
                        if displayFavaURL.isEmpty {
                            Text(L10n.Settings.notSet)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        } else {
                            Text(displayFavaURL)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
    }

    private var displayFavaURL: String {
        if !storedFavaBaseURL.isEmpty {
            return storedFavaBaseURL
        }
        let derived = FavaURLResolver.baseURL(from: storedFavaApiURL)
        return derived.isEmpty ? storedFavaApiURL : derived
    }

    private var displaySection: some View {
        Section(L10n.Settings.sectionDisplay) {
            Picker(selection: $currencyDisplayMode) {
                ForEach(CurrencyDisplayMode.allCases) { mode in
                    Text(mode.displayTitle)
                        .tag(mode)
                }
            } label: {
                HStack {
                    Image(systemName: "dollarsign.circle")
                        .foregroundStyle(.green)
                        .frame(width: 28)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(L10n.Settings.currencyDisplay)
                        Text(L10n.Settings.currencyUncommonSymbolNote)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .pickerStyle(.menu)
        }
    }

    private var aboutSection: some View {
        Section(L10n.Settings.sectionAbout) {
            NavigationLink {
                AboutView()
            } label: {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundStyle(.gray)
                        .frame(width: 28)
                    Text(L10n.Settings.aboutCounta)
                }
            }
        }
    }
}

struct AboutView: View {
    var body: some View {
        List {
            Section {
                HStack {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "chart.bar.doc.horizontal")
                            .font(.system(size: 60))
                            .foregroundStyle(.blue)

                        Text("Counta")
                            .font(.title.bold())

                        Text(L10n.Settings.aboutTagline)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 32)
                    Spacer()
                }
            }

            Section {
                LabeledContent(L10n.Settings.aboutVersion, value: "1.0.0")
                LabeledContent(L10n.Settings.aboutBuild, value: "1")
            }

            Section {
                Link(destination: URL(string: "https://beancount.github.io")!) {
                    HStack {
                        Text(L10n.Settings.aboutBeancountWebsite)
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle(L10n.Titles.about)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("En") {
    PreviewContainer {
        SettingsView()
            .environment(\.locale, .init(identifier: "en"))
    }
}
#Preview("Zh") {
    PreviewContainer {
        SettingsView()
            .environment(\.locale, .init(identifier: "zh"))
    }
}
