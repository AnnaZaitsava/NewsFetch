import RealmSwift
import Combine

final class RealmArticleStorage: ArticleStorage {
    //MARK: - Singleton
    static let shared = RealmArticleStorage()
    private let realm: Realm
    
    // MARK: - Initialization
    private init() {
        do {
            realm = try Realm()
        } catch {
            fatalError("Failed to initialize Realm: \(error)")
        }
    }
    
    // MARK: - Fetching
    
    /// Retrieves a list of favorite articles stored in Realm.
    /// - Returns: An array of Article objects marked as favorites.
    func getFavoriteArticles() -> [Article] {
        let objects = realm.objects(ArticleObject.self).filter("isFavorite == true")
        return Array(objects.map { $0.toArticle })
    }
    
    /// Retrieves a list of blocked articles stored in Realm.
    /// - Returns: An array of Article objects marked as blocked.
    func getBlockedArticles() -> [Article] {
        let objects = realm.objects(ArticleObject.self).filter("isBlocked == true")
        return Array(objects.map { $0.toArticle })
    }
    
    // MARK: - Favorites
    /// Adds an article to favorites.
    /// - Parameter article: The Article object to be added to favorites.
    func addToFavorites(_ article: Article) {
        do {
            try realm.write {
                if let existingObject = realm.object(ofType: ArticleObject.self, forPrimaryKey: article.id) {
                    existingObject.isFavorite = true
                } else {
                    let object = ArticleObject(article: article, isFavorite: true)
                    realm.add(object)
                }
            }
        } catch {
            print("Failed to add article to favorites: \(error)")
        }
    }
    
    /// Removes an article from favorites.
    /// - Parameter article: The Article object to be removed from favorites.
    func removeFromFavorites(_ article: Article) {
        do {
            try realm.write {
                if let existingObject = realm.object(ofType: ArticleObject.self, forPrimaryKey: article.id) {
                    existingObject.isFavorite = false
                    if !existingObject.isBlocked {
                        realm.delete(existingObject)
                    }
                }
            }
        } catch {
            print("Failed to remove article from favorites: \(error)")
        }
    }
    
    // MARK: - Blocking
    /// Blocks an article. If the article already exists, it updates the isBlocked flag.
    /// - Parameter article: The Article object to be blocked.
    func blockArticle(_ article: Article) {
        do {
            try realm.write {
                if let existingObject = realm.object(ofType: ArticleObject.self, forPrimaryKey: article.id) {
                    existingObject.isBlocked = true
                } else {
                    let object = ArticleObject(article: article, isBlocked: true)
                    realm.add(object)
                }
            }
        } catch {
            print("Failed to block article: \(error)")
        }
    }
    
    /// Unblocks an article. If the article is not a favorite, it will be deleted.
    /// - Parameter article: The Article object to be unblocked.
    func unblockArticle(_ article: Article) {
        do {
            try realm.write {
                if let existingObject = realm.object(ofType: ArticleObject.self, forPrimaryKey: article.id) {
                    existingObject.isBlocked = false
                    if !existingObject.isFavorite {
                        realm.delete(existingObject)
                    }
                }
            }
        } catch {
            print("Failed to unblock article: \(error)")
        }
    }
    
    
    /// MARK: - Observers
    /// Observes changes to favorite articles in Realm and emits updated arrays.
    /// - Returns: A publisher that emits arrays of favorite Article objects.
    func observeFavorites() -> AnyPublisher<[Article], Never> {
        let objects = realm.objects(ArticleObject.self).filter("isFavorite == true")
        return objects
            .collectionPublisher
            .map { Array($0.map { $0.toArticle }) }
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    /// Observes changes to blocked articles in Realm and emits updated arrays.
    /// - Returns: A publisher that emits arrays of blocked Article objects.
    func observeBlocked() -> AnyPublisher<[Article], Never> {
        let objects = realm.objects(ArticleObject.self).filter("isBlocked == true")
        return objects
            .collectionPublisher
            .map { Array($0.map { $0.toArticle }) }
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
} 
