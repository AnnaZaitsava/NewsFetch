import RealmSwift

class ArticleObject: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var sectionName: String
    @Persisted var webTitle: String
    @Persisted var webUrl: String
    @Persisted var webPublicationDate: String
    @Persisted var pillarName: String?
    @Persisted var isFavorite: Bool
    @Persisted var isBlocked: Bool
    
    // MARK: - Initialization
    convenience init(article: Article, isFavorite: Bool = false, isBlocked: Bool = false) {
        self.init()
        self.id = article.id
        self.sectionName = article.sectionName
        self.webTitle = article.webTitle
        self.webUrl = article.webUrl
        self.webPublicationDate = article.webPublicationDate
        self.pillarName = article.pillarName
        self.isFavorite = isFavorite
        self.isBlocked = isBlocked
    }
    
    // MARK: Mapping
    var toArticle: Article {
        Article(
            id: id,
            sectionName: sectionName,
            webTitle: webTitle,
            webUrl: webUrl,
            webPublicationDate: webPublicationDate,
            pillarName: pillarName
        )
    }
} 
