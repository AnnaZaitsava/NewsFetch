import SwiftUI

struct FullScreenView: View {
    let block: NavigationBlock
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack{
            VStack(spacing: 10) {
                
                Text(block.title ?? "")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.blackCustom)
                
                Text(block.subtitle ?? "")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.grayCustom)
                
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.headline)
                    }
                }
            }
        }
    }
}
