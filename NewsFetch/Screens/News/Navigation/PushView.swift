import SwiftUI

struct PushView: View {
    
    let block: NavigationBlock
    
    var body: some View {
        VStack {
            Text(block.subtitle ?? "")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.grayCustom)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 80)
        }
        .navigationTitle(block.title ?? "")
        .navigationBarTitleDisplayMode(.inline)
    }
}
