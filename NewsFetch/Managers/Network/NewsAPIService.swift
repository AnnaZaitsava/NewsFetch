import Foundation
import Combine

final class NewsAPIService: APIService {
    private let baseURL = "https://us-central1-server-side-functions.cloudfunctions.net"
    private let session: URLSession
    private let decoder: JSONDecoder
    
    // MARK: - Initialization
    /// Initializes the service with a URLSession and JSONDecoder.
       /// - Parameters:
       ///   - session: The URLSession to use for network requests. Defaults to `.shared`.
    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
    }
    
    // MARK: - News Fetching
        
        /// Fetches a page of news articles from the API.
        /// - Parameter page: The page number to fetch (1-based index).
        /// - Returns: A publisher emitting an array of `Article` objects or an error.
    func fetchNews(page: Int) -> AnyPublisher<[Article], Error> {
        guard var components = URLComponents(string: "\(baseURL)/guardian") else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        components.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "page-size", value: "20")
        ]
        
        guard let url = components.url else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.setValue("hanna-zaitsava", forHTTPHeaderField: "Authorization")
        
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.unknown
                }
                
                if (200..<300).contains(httpResponse.statusCode) {
                    return data
                } else {
                    throw APIError.serverError(httpResponse.statusCode)
                }
            }
            .decode(type: NewsResponse.self, decoder: decoder)
            .map { $0.response.results }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Navigation Blocks
        
        /// Fetches navigation blocks from the API.
        /// - Returns: A publisher emitting an array of `NavigationBlock` objects or an error.
    func fetchNavigationBlocks() -> AnyPublisher<[NavigationBlock], Error> {
        guard let url = URL(string: "\(baseURL)/navigation") else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.setValue("hanna-zaitsava", forHTTPHeaderField: "Authorization")
        
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.unknown
                }
                
                if (200..<300).contains(httpResponse.statusCode) {
                    return data
                } else {
                    throw APIError.serverError(httpResponse.statusCode)
                }
            }
            .decode(type: NavigationResponse.self, decoder: decoder)
            .map { $0.results }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
