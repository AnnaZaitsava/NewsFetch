import SwiftUI

struct BlockedView: View {
    @ObservedObject var viewModel: NewsViewModel
    
    var body: some View {
        if viewModel.blockedArticles.isEmpty {
            EmptyStateView(
                icon: "nosign",
                text: "No Blocked News"
            )
        } else {
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.blockedArticles) { article in
                        ArticleCardView(
                            viewModel: viewModel,
                            article: article
                        )
                        .onTapGesture {
                            if let url = URL(string: article.webUrl) {
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
} 
