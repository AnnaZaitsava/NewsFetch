import Network
import Combine

import Foundation
import Network

final class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    
    private lazy var monitor = NWPathMonitor()
    @Published private(set) var isConnected: Bool = true
    
    func startMonitoring() {
        self.monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                var newState = path.status == .satisfied
                guard self?.isConnected != newState else { return }
                
                self?.isConnected = newState
            }
        }
        
        self.monitor.start(queue: DispatchQueue(label: "network-queue"))
    }
}

