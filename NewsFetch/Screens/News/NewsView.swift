import SwiftUI

struct NewsView: View {
    // MARK: - Private Properties
    @StateObject private var viewModel = NewsViewModel()
    @StateObject private var networkMonitor = NetworkMonitor()
    
    @State private var selectedSegment = 0
    @State private var showBlockAlert = false
    @State private var showNetworkAlert = false
    @State private var shouldBlockNews = false
    @State private var articleToBlock: Article?
    
    @State private var selectedURL: URL? = nil
    @State private var isShowingBrowser = false
    
    var filteredArticles: [Article] {
        switch selectedSegment {
        case 0: return viewModel.articles
        case 1: return viewModel.favoriteArticles
        case 2: return viewModel.blockedArticles
        default: return []
        }
    }
    
    let segments = ["All", "Favorites", "Blocked"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("", selection: $selectedSegment) {
                    ForEach(0..<segments.count, id: \.self) { index in
                        Text(segments[index])
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
                
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.beigeCustom)
                } else {
                    List {
                        switch selectedSegment {
                        case 0:
                            ForEach(viewModel.articlesWithNavigation) { item in
                                switch item {
                                case .article(let article):
                                    ArticleCardView(
                                        viewModel: viewModel,
                                        article: article
                                    )
                                    .onTapGesture {
                                        if let url = URL(string: article.webUrl) {
                                            selectedURL = url
                                            isShowingBrowser = true
                                        }
                                    }
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                                    .padding(.vertical, -6)
                                    
                                case .navigation(let block, _):
                                    NavigationBlockView(block: block)
                                        .listRowSeparator(.hidden)
                                        .listRowBackground(Color.clear)
                                }
                            }
                        case 1:
                            if viewModel.favoriteArticles.isEmpty {
                                emptyStateView(
                                    icon: "heart",
                                    text: "No Favorite News"
                                )
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height - 200)
                            } else {
                                ForEach(viewModel.favoriteArticles) { article in
                                    ArticleCardView(
                                        viewModel: viewModel,
                                        article: article
                                    )
                                    .onTapGesture {
                                        if let url = URL(string: article.webUrl) {
                                            selectedURL = url
                                            isShowingBrowser = true
                                        }
                                    }
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                                    .padding(.vertical, -6)
                                }
                            }
                        case 2:
                            if viewModel.blockedArticles.isEmpty {
                                emptyStateView(
                                    icon: "nosign",
                                    text: "No Blocked News"
                                )
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height - 200)
                            } else {
                                ForEach(viewModel.blockedArticles) { article in
                                    ArticleCardView(
                                        viewModel: viewModel,
                                        article: article
                                    )
                                    .onTapGesture {
                                        if let url = URL(string: article.webUrl) {
                                            selectedURL = url
                                            isShowingBrowser = true
                                        }
                                    }
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                                    .padding(.vertical, -6)
                                }
                            }
                        default:
                            EmptyView()
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .scrollIndicators(.hidden)
                    .refreshable {
                        viewModel.refresh()
                    }
                }
            }
            .navigationTitle("News")
            .navigationBarTitleDisplayMode(.large)
            .background(Color.beigeCustom)
        }
        .overlay {
            if viewModel.isLoading {
                BlurView {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                }
            }
            
            if showBlockAlert {
                BlurView {
                    EmptyView()
                }
                .alert("Do you want to block?", isPresented: $showBlockAlert) {
                    Button("Cancel", role: .cancel) {
                        viewModel.articleToBlock = nil
                    }
                    Button("Block", role: .destructive) {
                        if let article = viewModel.articleToBlock {
                            viewModel.blockArticle(article)
                            viewModel.articleToBlock = nil
                        }
                    }
                } message: {
                    Text("Confirm to hide this news source")
                }
            }
            
            if showNetworkAlert {
                BlurView {
                    EmptyView()
                }
                .alert("No Internet Connection", isPresented: $showNetworkAlert) {
                    Button("OK", role: .cancel) {
                        showNetworkAlert = false
                    }
                }
            }
        }
        .onChange(of: viewModel.articleToBlock) { article in
            if article != nil {
                showBlockAlert = true
            }
        }
        .onReceive(networkMonitor.$isConnected) { isConnected in
            showNetworkAlert = !isConnected
        }
    }
    
    private func emptyStateView(icon: String, text: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.blueCustom)
            Text(text)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.blackCustom)
        }
    }
}
