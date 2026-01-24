import SwiftUI

struct RootView: View {
    @AppStorage(AppStorageKeys.favaApiURL) private var favaApiURL = ""

    private var needsOnboarding: Bool {
        favaApiURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        if needsOnboarding {
            WelcomeView()
        } else {
            MainTabView()
        }
    }
}

#Preview {
    RootView()
}
