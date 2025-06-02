import SwiftUI

struct AllNewsView: View {
    @ObservedObject var viewModel: NewsViewModel
    
    var body: some View {
        if viewModel.articles.isEmpty {
            EmptyStateView(
                icon: "newspaper",
                text: "No Results",
                action: { viewModel.retry() },
                actionTitle: "Refresh"
            )
        } else {
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.newsModel) { item in
                        switch item {
                        case .article(let article):
                            ArticleCardView(
                                viewModel: viewModel,
                                article: article
                            )
                            .onTapGesture {
                                if let url = URL(string: article.webUrl) {
                                    UIApplication.shared.open(url)
                                }
                            }
                            
                        case .navigation(let block, _):
                            NavigationBlockView(block: block)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
} 
