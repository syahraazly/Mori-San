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
            case .map, .goal, .gameplay, .levelTransition:
                SpriteKitGameView(appFlow: appFlow)
            case .congratulations(let goalID):
                VStack {
                    Text("Congratulations! Goal: \(goalID)")
                    Button("Kembali ke Map") {
                        appFlow.openMap()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
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
