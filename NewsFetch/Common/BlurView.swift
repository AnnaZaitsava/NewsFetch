import SwiftUI
struct BlurView: View {
    var content: () -> any View
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
            Rectangle()
                .fill(.ultraThinMaterial)
                .edgesIgnoringSafeArea(.all)
            AnyView(content())
        }
        .animation(.easeInOut(duration: 0.2), value: true)
    }
}
