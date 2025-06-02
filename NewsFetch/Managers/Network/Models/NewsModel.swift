// MARK: - Article Response

struct Article: Codable, Identifiable, Equatable {
    let id: String
    let sectionName: String
    let webTitle: String
    let webUrl: String
    let webPublicationDate: String
    let pillarName: String?
}

// MARK: - API News Response Models

struct NewsResponse: Codable {
    let response: Response
    struct Response: Codable {
        let status: String
        let currentPage: Int
        let pageSize: Int
        let total: Int
        let pages: Int
        let results: [Article]
    }
}

// MARK: - NavigationBlock Response

struct NavigationBlock: Codable, Identifiable {
    let id: Int
    let title: String?
    let subtitle: String?
    let button_title: String?
    let button_symbol: String?
    let title_symbol: String?
    let navigation: String
}

// MARK: - API Navigation Blocks Response Models

struct NavigationResponse: Codable {
    let results: [NavigationBlock]
}
