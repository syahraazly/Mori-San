import SwiftUI

struct ContentView: View {
    @ObservedObject var appFlow: AppFlowViewModel

    var body: some View {
        ZStack {
            switch appFlow.screen {
            case .onboarding:
                OnboardingScreen(appFlow: appFlow)
            case .storyline:
                StorylineScreen(appFlow: appFlow)
            case .goal(let goalID):
                ChapterProgressionView(appFlow: appFlow, goalID: goalID)
            case .map, .gameplay, .levelTransition, .flowerReveal, .congratulations:
                SpriteKitGameView(appFlow: appFlow)
                    .ignoresSafeArea()
            }
        }
        .animation(.easeInOut(duration: 0.35), value: appFlow.screen)
    }
}

private struct SpriteKitGameView: UIViewControllerRepresentable {
    let appFlow: AppFlowViewModel

    func makeUIViewController(context: Context) -> GameViewController {
        GameViewController(appFlow: appFlow)
    }

    func updateUIViewController(_ uiViewController: GameViewController, context: Context) {}
}
