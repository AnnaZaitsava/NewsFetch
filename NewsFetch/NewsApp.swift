import SwiftUI

@main
struct NewsApp: App {
    init() {
        UISegmentedControl.appearance().setTitleTextAttributes(
            [.foregroundColor: UIColor.blackCustom], for: .normal
        )
        UISegmentedControl.appearance().setTitleTextAttributes(
            [.foregroundColor: UIColor.blackCustom], for: .selected
        )
        
        UINavigationBar.appearance().largeTitleTextAttributes = [
            .foregroundColor: UIColor.blackCustom
        ]
        UINavigationBar.appearance().titleTextAttributes = [
            .foregroundColor: UIColor.blackCustom
        ]
        
        NetworkMonitor.shared.startMonitoring()
    }
    
    var body: some Scene {
        WindowGroup {
            NewsView()
        }
    }
}
