import Foundation
import Combine

final class NewsAPIService: APIService {
    private let baseURL = "https://us-central1-server-side-functions.cloudfunctions.net"
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
    }
    
    func fetchNews(page: Int) -> AnyPublisher<[Article], Error> {
        guard var components = URLComponents(string: "\(baseURL)/guardian") else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        components.queryItems = [
            URLQueryItem(name: "page", value: "\(page)")
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
    
    func fetchArticles() async throws -> [Article] {
        let url = URL(string: "\(baseURL)/guardian")!
        var request = URLRequest(url: url)
        request.setValue("hanna-zaitsava", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw APIError.serverError((response as? HTTPURLResponse)?.statusCode ?? 500)
        }
        
        let decodedResponse = try decoder.decode(NewsResponse.self, from: data)
        return decodedResponse.response.results
    }
}
