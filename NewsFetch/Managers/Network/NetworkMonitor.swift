import Network
import Combine

/// Service that monitors network connectivity status
final class NetworkMonitor: ObservableObject {
    /// Published property indicating if the device has an active internet connection
    @Published private(set) var isConnected = true
    
    /// Published property containing the current connection type
    @Published private(set) var connectionType: ConnectionType = .unknown
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor", qos: .background)
    
    /// Connection types that can be detected
    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }
    
    init() {
        setupMonitor()
    }
    
    deinit {
        monitor.cancel()
    }
    
    private func setupMonitor() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isConnected = path.status == .satisfied
                self.connectionType = self.checkConnectionType(path)
            }
        }
        
        monitor.start(queue: queue)
    }
    
    private func checkConnectionType(_ path: NWPath) -> ConnectionType {
        if path.usesInterfaceType(.wifi) {
            return .wifi
        } else if path.usesInterfaceType(.cellular) {
            return .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            return .ethernet
        } else {
            return .unknown
        }
    }
} 