import SwiftUI

// MARK: - BlockAlertModifier
/// A ViewModifier that presents a blocking alert to confirm hiding an article.
// - Properties:
///   - isPresented: Binding `Bool` to control the presentation state of the alert.
///   - article: The `Article` to be blocked if user confirms.
///   - onBlock: Callback action when the user chooses to block the article.
///   - onCancel: Callback action when the user cancels the action.
///
struct BlockAlertModifier: ViewModifier {
    ///
    @Binding var isPresented: Bool
    let article: Article?
    let onBlock: (Article) -> Void
    let onCancel: () -> Void
    
    // MARK: - Layout
    func body(content: Content) -> some View {
        content.overlay {
            if isPresented {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .alert("Do you want to block?", isPresented: $isPresented) {
                        Button("Cancel", role: .cancel) {
                            onCancel()
                        }
                        Button("Block", role: .destructive) {
                            if let article = article {
                                onBlock(article)
                            }
                        }
                    } message: {
                        Text("Confirm to hide this news source")
                    }
            }
        }
    }
}

// MARK: - NetworkAlertModifier
/// A ViewModifier that shows an alert indicating no internet connection.
// - Properties:
///   - isPresented: Binding `Bool` to control the presentation state of the alert.

struct NetworkAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    
    func body(content: Content) -> some View {
        content.overlay {
            if isPresented {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .alert("No Internet Connection", isPresented: $isPresented) {
                        Button("OK", role: .cancel) { }
                    }
            }
        }
    }
}

// MARK: - View Extensions
extension View {
    
    // MARK:  Block Alert
    func blockAlert(
        isPresented: Binding<Bool>,
        article: Article?,
        onBlock: @escaping (Article) -> Void,
        onCancel: @escaping () -> Void
    ) -> some View {
        modifier(BlockAlertModifier(
            isPresented: isPresented,
            article: article,
            onBlock: onBlock,
            onCancel: onCancel
        ))
    }
    
    // MARK:  Network Alert
    func networkAlert(isPresented: Binding<Bool>) -> some View {
        modifier(NetworkAlertModifier(isPresented: isPresented))
    }
}
