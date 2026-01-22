import Foundation

@Observable
final class SettingsViewModel: @unchecked Sendable {
    var beancountFilePath: String?
    var defaultCurrency = "CNY"
    var accountDepth = 3

    init() {}
}
