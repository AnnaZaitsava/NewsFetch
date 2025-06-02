import Foundation
import Combine

/// Protocol defining the storage operations for articles
protocol ArticleStorage {
    /// Get all favorite articles
    func getFavoriteArticles() -> [Article]
    
    /// Get all blocked articles
    func getBlockedArticles() -> [Article]
    
    /// Add an article to favorites
    func addToFavorites(_ article: Article)
    
    /// Remove an article from favorites
    func removeFromFavorites(_ article: Article)
    
    /// Block an article
    func blockArticle(_ article: Article)
    
    /// Unblock an article
    func unblockArticle(_ article: Article)
    
    /// Observe changes to favorite articles
    func observeFavorites() -> AnyPublisher<[Article], Never>
    
    /// Observe changes to blocked articles
    func observeBlocked() -> AnyPublisher<[Article], Never>
}

/// Errors that can occur during storage operations
enum StorageError: Error {
    case failedToInitialize
    case failedToWrite(String)
    case failedToRead(String)
} 