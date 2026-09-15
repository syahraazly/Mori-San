import SwiftUI

struct StorylineScreen: View {
    @ObservedObject var appFlow: AppFlowViewModel

    var body: some View {
        ZStack {
            Color(red: 0.95, green: 0.90, blue: 0.82)
                .ignoresSafeArea()
            Text("I — APART")
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(Color(red: 0.22, green: 0.24, blue: 0.30))
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                appFlow.startGame()
            }
        }
    }
}
