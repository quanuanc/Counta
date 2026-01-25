import Foundation

extension AccountType {
    var localizedTitle: LocalizedStringResource {
        switch self {
        case .assets:
            return L10n.AccountType.assets
        case .liabilities:
            return L10n.AccountType.liabilities
        case .income:
            return L10n.AccountType.income
        case .expenses:
            return L10n.AccountType.expenses
        case .equity:
            return L10n.AccountType.equity
        }
    }
}

