import SwiftUI
import Combine
import RealmSwift

final class NewsViewModel: ObservableObject {
    // MARK: - Published Properties
    /// Published properties for view binding and UI updates.
    @Published var navigationBlocks: [NavigationBlock] = []
    @Published var articles: [Article] = []
    @Published var error: String? = nil
    @Published var isLoading = false
    @Published var favoriteArticles: [Article] = []
    @Published var blockedArticles: [Article] = []
    @Published var showBlockAlert = false
    @Published var articleToBlock: Article?
    
    // MARK: - Private Properties
    /// Internal state and dependencies used by the view model.
    private var currentPage = 1
    private let service: NewsAPIService
    private let storage: ArticleStorage
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    /// Model:  returns  News + Blocks
    var newsModel: [NewsItem] {
        var result: [NewsItem] = []
        let filtered = articles.filter { !blockedArticles.contains($0) }
        
        for (index, article) in filtered.enumerated() {
            result.append(.article(article))
            
            if (index + 1) % 2 == 0 && !navigationBlocks.isEmpty {
                let navIndex = (index / 2) % navigationBlocks.count
                let navBlock = navigationBlocks[navIndex]
                result.append(.navigation(navBlock, index / 2))
            }
        }
        
        return result
    }
    
    // MARK: - Types
    
    enum NewsItem: Identifiable {
        case article(Article)
        case navigation(NavigationBlock, Int)
        
        var id: String {
            switch self {
            case .article(let article): return "article-\(article.id)"
            case .navigation(let block, let index): return "nav-\(block.id)-\(index)"
            }
        }
    }
    
    // MARK: - Initialization
    /// Initializes the NewsViewModel with a service and storage.
    /// - Parameters:
    ///   - service: The NewsAPIService instance to fetch data from API.
    ///   - storage: The ArticleStorage instance to manage local article state.
    
    init(service: NewsAPIService = NewsAPIService(), storage: ArticleStorage = RealmArticleStorage.shared) {
        self.service = service
        self.storage = storage
        setupObservers()
        loadNavigationBlocks()
        loadPage()
    }
    
    // MARK: - Private Methods
    
    /// Sets up observers for favorite and blocked articles using Combine publishers.
    private func setupObservers() {
        storage.observeFavorites()
            .catch { error -> AnyPublisher<[Article], Never> in
                print("Error observing favorites: \(error)")
                return Just([]).eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$favoriteArticles)
        
        storage.observeBlocked()
            .catch { error -> AnyPublisher<[Article], Never> in
                print("Error observing blocked: \(error)")
                return Just([]).eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$blockedArticles)
    }
    
    /// Loads navigation blocks from the API and binds them to navigationBlocks property.
    private func loadNavigationBlocks() {
        service.fetchNavigationBlocks()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case let .failure(error) = completion {
                        self?.error = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] blocks in
                    self?.navigationBlocks = blocks
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    /// Blocks an article and removes it from the list of visible articles.
    /// - Parameter article: The article to be blocked.
    func blockArticle(_ article: Article) {
        storage.blockArticle(article)
        articles.removeAll { $0.id == article.id }
        blockedArticles.append(article)
        
        // Remove from favorites if it was there
        if favoriteArticles.contains(article) {
            removeFromFavorites(article)
        }
    }
    
    /// Unblocks an article and restores it to the list if not blocked.
    /// - Parameter article: The article to be unblocked.
    func unblockArticle(_ article: Article) {
        storage.unblockArticle(article)
        blockedArticles.removeAll { $0.id == article.id }
        
        if !articles.contains(article) {
            articles.insert(article, at: 0)
        }
    }
    
    /// Adds an article to favorites.
    /// - Parameter article: The article to add to favorites.
    func addToFavorites(_ article: Article) {
        storage.addToFavorites(article)
        favoriteArticles.append(article)
    }
    
    /// Removes an article from favorites.
    /// - Parameter article: The article to remove from favorites.
    func removeFromFavorites(_ article: Article) {
        storage.removeFromFavorites(article)
        favoriteArticles.removeAll { $0.id == article.id }
    }
    
    /// Loads the next page of news articles from the API.
    func loadPage() {
        guard !isLoading else { return }
        isLoading = true
        error = nil
        
        service.fetchNews(page: currentPage)
            .map { [weak self] (newArticles: [Article]) -> [Article] in
                guard let self = self else { return [] }
                return newArticles.filter { !self.blockedArticles.contains($0) }
            }
            .catch { error -> AnyPublisher<[Article], Never> in
                print("Error loading page: \(error)")
                return Just([]).eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case let .failure(error) = completion {
                        self?.error = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] newArticles in
                    guard let self = self else { return }
                    
                    self.articles.append(contentsOf: newArticles)
                    
                    self.currentPage += 1
                    self.isLoading = false
                }
            )
            .store(in: &cancellables)
    }
    
    /// Paggination
    func refresh() {
        loadPage()
    }
    
    /// Trying to load data in case of empty result.
    func retry() {
        currentPage = 1
        loadPage()
    }
}
