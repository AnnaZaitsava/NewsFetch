import SwiftUI

struct NavigationBlockView: View {
    let block: NavigationBlock
    @State private var showPush = false
    @State private var showModal = false
    @State private var showFullScreen = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            if let symbol = block.title_symbol {
                Image(systemName: symbol)
                    .font(.system(size: 20))
                    .foregroundColor(.blueCustom)
            }
            
            if let title = block.title {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.blackCustom)
            }
            
            if let subtitle = block.subtitle {
                Text(subtitle)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.grayCustom)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button {
                handleNavigation()
            } label: {
                ZStack {
                    Text(block.button_title ?? "Continue")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(maxWidth: .infinity)
                    
                    if let symbol = block.button_symbol {
                        HStack {
                            Spacer()
                            Image(systemName: symbol)
                                .font(.system(size: 20))
                        }
                        .padding(.trailing)
                    }
                }
                .frame(height: 44)
                .background(.blueCustom)
                .foregroundColor(.white)
                .cornerRadius(4)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .padding(.vertical, -6)
        .background(
            NavigationLink(
                destination: PushView(block: block),
                isActive: $showPush,
                label: { EmptyView() }
            )
            .hidden()
        )
        .sheet(isPresented: $showModal) {
            ModalView(block: block)
        }
        .fullScreenCover(isPresented: $showFullScreen) {
            FullScreenView(block: block)
        }
    }
    
    private func handleNavigation() {
        switch block.navigation {
        case "push":
            showPush = true
        case "modal":
            showModal = true
        case "full_screen":
            showFullScreen = true
        default: break
        }
    }
} 
