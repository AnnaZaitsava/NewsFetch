import SwiftUI

struct ModalView: View {
    let block: NavigationBlock
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Text("Modal Navigation")
                .navigationTitle(block.title ?? "")
                .navigationBarItems(trailing: Button("Done") {
                    dismiss()
                })
        }
    }
} 