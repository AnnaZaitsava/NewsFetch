import SwiftUI

struct BlockAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    let article: Article?
    let onBlock: (Article) -> Void
    let onCancel: () -> Void
    
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

extension View {
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
    
    func networkAlert(isPresented: Binding<Bool>) -> some View {
        modifier(NetworkAlertModifier(isPresented: isPresented))
    }
} 