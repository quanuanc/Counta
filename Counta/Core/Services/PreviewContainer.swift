#if DEBUG
import SwiftUI

struct PreviewContainer<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        PreviewFavaAPI.enable()
        self.content = content()
    }

    var body: some View {
        content
    }
}
#endif
