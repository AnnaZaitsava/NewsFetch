import SwiftUI

struct AllNewsView: View {
    @ObservedObject var viewModel: NewsViewModel
    
    var body: some View {
        if viewModel.articles.isEmpty {
            EmptyStateView(
                icon: "exclamationmark.circle.fill",
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
                            ArticleView(
                                viewModel: viewModel,
                                article: article
                            )
                            .onTapGesture {
                                if let url = URL(string: article.webUrl) {
                                    UIApplication.shared.open(url)
                                }
                            }
                            .onAppear {
                                if case .article(let lastArticle) = viewModel.newsModel.last,
                                   article.id == lastArticle.id {
                                    viewModel.loadPage()
                                }
                            }
                            
                        case .navigation(let block, _):
                            NavigationBlockView(block: block)
                        }
                    }
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
} 
