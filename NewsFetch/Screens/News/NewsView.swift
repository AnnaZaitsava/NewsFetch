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
    
    //Segments Array
    let segments = ["All", "Favorites", "Blocked"]
    
    
    // MARK: - Layout
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
                
                if viewModel.isLoading && viewModel.articles.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.beigeCustom)
                } else {
                    Group {
                        switch selectedSegment {
                        case 0:
                            AllNewsView(viewModel: viewModel)
                        case 1:
                            FavoritesView(viewModel: viewModel)
                        case 2:
                            BlockedView(viewModel: viewModel)
                        default:
                            EmptyView()
                        }
                    }
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
            if viewModel.isLoading && viewModel.articles.isEmpty {
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
}
