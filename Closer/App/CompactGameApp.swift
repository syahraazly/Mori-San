import SwiftUI

@main
struct CompactGameApp: App {
    @StateObject private var appFlow = AppFlowViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView(appFlow: appFlow)
        }
    }
}
