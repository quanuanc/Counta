import Foundation

extension Decimal {
    var formatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: self as NSDecimalNumber) ?? "0.00"
    }

    var formattedWithSign: String {
        let sign = self >= 0 ? "+" : ""
        return sign + formatted
    }
}
