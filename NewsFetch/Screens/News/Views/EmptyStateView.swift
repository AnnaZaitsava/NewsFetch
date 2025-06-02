import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let text: String
    var action: (() -> Void)?
    var actionTitle: String?
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 8) {
                Spacer()
                Image(systemName: icon)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.blueCustom)
                Text(text)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.blackCustom)
                    .multilineTextAlignment(.center)
                
                if let actionTitle = actionTitle, let action = action {
                    Button(action: action) {
                        Text(actionTitle)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color.blueCustom)
                            .cornerRadius(4)
                    }
                    .padding(.top, 12)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: geometry.size.height)
            .padding(.horizontal, 16)
        }
    }
} 