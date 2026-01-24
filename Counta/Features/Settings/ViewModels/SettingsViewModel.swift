import Foundation

@Observable
final class SettingsViewModel: @unchecked Sendable {
    var defaultCurrency = "CNY"
    var accountDepth = 3

    init() {}
}
