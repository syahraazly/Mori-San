import SwiftUI

struct ContentView: View {
    @ObservedObject var appFlow: AppFlowViewModel

    var body: some View {
        ZStack {
            Color(red: 0.173, green: 0.165, blue: 0.322)
                .ignoresSafeArea()

            switch appFlow.screen {
            case .splash:
                SplashScreenView(appFlow: appFlow)
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
        .font(.custom("Montserrat-Regular", size: 17, relativeTo: .body))
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
