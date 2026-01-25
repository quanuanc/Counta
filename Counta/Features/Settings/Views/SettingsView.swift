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
            .navigationTitle("设置")
        }
    }

    private var favaConnectionSection: some View {
        Section("连接") {
            NavigationLink {
                WelcomeView(context: .settings)
            } label: {
                HStack {
                    Image(systemName: "dot.radiowaves.left.and.right")
                        .foregroundStyle(.blue)
                        .frame(width: 28)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Fava 服务器")
                        Text(displayFavaURL.isEmpty ? "未设置" : displayFavaURL)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
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
        Section("显示") {
            Picker(selection: $currencyDisplayMode) {
                ForEach(CurrencyDisplayMode.allCases) { mode in
                    Text("\(mode.title) (\(mode.example))")
                        .tag(mode)
                }
            } label: {
                HStack {
                    Image(systemName: "dollarsign.circle")
                        .foregroundStyle(.green)
                        .frame(width: 28)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("货币显示")
                        Text("非常见货币将使用符号¤")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .pickerStyle(.menu)
        }
    }

    private var aboutSection: some View {
        Section("关于") {
            NavigationLink {
                AboutView()
            } label: {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundStyle(.gray)
                        .frame(width: 28)
                    Text("关于 Counta")
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

                        Text("基于 Beancount 的财务管理")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 32)
                    Spacer()
                }
            }

            Section {
                LabeledContent("版本", value: "1.0.0")
                LabeledContent("构建", value: "1")
            }

            Section {
                Link(destination: URL(string: "https://beancount.github.io")!) {
                    HStack {
                        Text("Beancount 官网")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("关于")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    PreviewContainer {
        SettingsView()
    }
}
