import SwiftUI

struct AccountIcon: View {
    let accountType: AccountType
    var size: CGFloat = 24

    private var iconName: String {
        switch accountType {
        case .assets: return "banknote"
        case .liabilities: return "creditcard"
        case .income: return "arrow.down.circle"
        case .expenses: return "arrow.up.circle"
        case .equity: return "chart.pie"
        }
    }

    private var iconColor: Color {
        switch accountType {
        case .assets: return .blue
        case .liabilities: return .orange
        case .income: return .green
        case .expenses: return .red
        case .equity: return .purple
        }
    }

    var body: some View {
        Image(systemName: iconName)
            .font(.system(size: size * 0.6))
            .foregroundStyle(iconColor)
            .frame(width: size, height: size)
            .background(iconColor.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: size * 0.2))
    }
}

extension AccountIcon {
    init(accountPath: String, size: CGFloat = 24) {
        if accountPath.hasPrefix("Assets") {
            self.init(accountType: .assets, size: size)
        } else if accountPath.hasPrefix("Liabilities") {
            self.init(accountType: .liabilities, size: size)
        } else if accountPath.hasPrefix("Income") {
            self.init(accountType: .income, size: size)
        } else if accountPath.hasPrefix("Expenses") {
            self.init(accountType: .expenses, size: size)
        } else {
            self.init(accountType: .equity, size: size)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ForEach(AccountType.allCases, id: \.self) { type in
            HStack {
                AccountIcon(accountType: type)
                Text(type.rawValue)
            }
        }
    }
}
