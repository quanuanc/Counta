import SwiftUI

struct PreviewContainer<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        #if DEBUG
        PreviewFavaAPI.enable()
        #endif
        self.content = content()
    }

    var body: some View {
        content
    }
}
