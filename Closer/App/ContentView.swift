import SwiftUI

struct ContentView: View {
    @ObservedObject var appFlow: AppFlowViewModel

    var body: some View {
        ZStack {
            switch appFlow.screen {
            case .opening:
                OnboardingScreen(appFlow: appFlow)
            case .chapterOne:
                StorylineScreen(appFlow: appFlow)
            case .game:
                SpriteKitGameView()
            }
        }
        .animation(.easeInOut(duration: 0.35), value: appFlow.screen)
    }
}

private struct SpriteKitGameView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> GameViewController {
        GameViewController()
    }

    func updateUIViewController(_ uiViewController: GameViewController, context: Context) {}
}
