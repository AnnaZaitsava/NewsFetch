import Foundation
import Combine

/// Protocol defining the API service operations
protocol APIService {
    /// Fetch news articles for a specific page
    func fetchNews(page: Int) -> AnyPublisher<[Article], Error>
    
    /// Fetch navigation blocks
    func fetchNavigationBlocks() -> AnyPublisher<[NavigationBlock], Error>
}

/// API-related errors
enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case serverError(Int)
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .serverError(let code):
            return "Server error with code: \(code)"
        case .unknown:
            return "An unknown error occurred"
        }
    }
} 
