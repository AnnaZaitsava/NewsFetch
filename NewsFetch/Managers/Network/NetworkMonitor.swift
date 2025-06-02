import Network
import Combine

import Foundation
import Network

final class NetworkMonitor: ObservableObject {
    
    //MARK: - Singleton
    static let shared = NetworkMonitor()
    
    // MARK: - Properties
    private lazy var monitor = NWPathMonitor()
    /// Current network  status.
    @Published private(set) var isConnected: Bool = true
    
    
    // MARK: - Lifecycle & Configuration
    
    /// Starts monitoring network changes and updates `isConnected` when status changes.
    func startMonitoring() {
        self.monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                let newState = path.status == .satisfied
                guard self?.isConnected != newState else { return }
                
                self?.isConnected = newState
            }
        }
        
        self.monitor.start(queue: DispatchQueue(label: "network-queue"))
    }
}

