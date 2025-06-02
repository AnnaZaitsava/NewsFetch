import SwiftUI

struct FavoritesView: View {
    @ObservedObject var viewModel: NewsViewModel
    
    var body: some View {
        if viewModel.favoriteArticles.isEmpty {
            EmptyStateView(
                icon: "heart",
                text: "No Favorite News"
            )
        } else {
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.favoriteArticles) { article in
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
