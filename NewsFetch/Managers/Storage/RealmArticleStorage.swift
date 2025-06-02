import RealmSwift
import Combine

/// Realm implementation of ArticleStorage
final class RealmArticleStorage: ArticleStorage {
    static let shared = RealmArticleStorage()
    private let realm: Realm
    
    private init() {
        do {
            realm = try Realm()
        } catch {
            fatalError("Failed to initialize Realm: \(error)")
        }
    }
    
    func getFavoriteArticles() -> [Article] {
        let objects = realm.objects(ArticleObject.self).filter("isFavorite == true")
        return Array(objects.map { $0.toArticle })
    }
    
    func getBlockedArticles() -> [Article] {
        let objects = realm.objects(ArticleObject.self).filter("isBlocked == true")
        return Array(objects.map { $0.toArticle })
    }
    
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
    
    func observeFavorites() -> AnyPublisher<[Article], Never> {
        let objects = realm.objects(ArticleObject.self).filter("isFavorite == true")
        return objects
            .collectionPublisher
            .map { Array($0.map { $0.toArticle }) }
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    func observeBlocked() -> AnyPublisher<[Article], Never> {
        let objects = realm.objects(ArticleObject.self).filter("isBlocked == true")
        return objects
            .collectionPublisher
            .map { Array($0.map { $0.toArticle }) }
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
} 