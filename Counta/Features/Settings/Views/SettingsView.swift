import SwiftUI

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()

    var body: some View {
        NavigationStack {
            List {
                dataSourceSection

                displaySection

                aboutSection
            }
            .navigationTitle("设置")
        }
    }

    private var dataSourceSection: some View {
        Section("数据源") {
            NavigationLink {
                Text("文件选择器 - 待实现")
            } label: {
                HStack {
                    Image(systemName: "doc.text")
                        .foregroundStyle(.blue)
                        .frame(width: 28)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Beancount 文件")
                        if let path = viewModel.beancountFilePath {
                            Text(path)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        } else {
                            Text("未选择")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            NavigationLink {
                Text("同步设置 - 待实现")
            } label: {
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .foregroundStyle(.blue)
                        .frame(width: 28)
                    Text("同步设置")
                }
            }
        }
    }

    private var displaySection: some View {
        Section("显示") {
            NavigationLink {
                Text("货币设置 - 待实现")
            } label: {
                HStack {
                    Image(systemName: "dollarsign.circle")
                        .foregroundStyle(.green)
                        .frame(width: 28)
                    Text("默认货币")
                    Spacer()
                    Text(viewModel.defaultCurrency)
                        .foregroundStyle(.secondary)
                }
            }

            Stepper(value: $viewModel.accountDepth, in: 1...5) {
                HStack {
                    Image(systemName: "list.bullet.indent")
                        .foregroundStyle(.orange)
                        .frame(width: 28)
                    Text("账户层级显示")
                    Spacer()
                    Text("\(viewModel.accountDepth)")
                        .foregroundStyle(.secondary)
                }
            }
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
    SettingsView()
}
