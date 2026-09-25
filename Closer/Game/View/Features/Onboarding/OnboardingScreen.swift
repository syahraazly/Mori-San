import SwiftUI

struct OnboardingScreen: View {
    @ObservedObject var appFlow: AppFlowViewModel
    @State private var step = 0

    var body: some View {
        ZStack {
            Color(red: 0.95, green: 0.90, blue: 0.82)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                if step == 0 {
                    Text("The world was once connected.")
                } else if step == 1 {
                    Text("Until the paths drifted apart.")
                } else {
                    Text("MORI-SAN")
                        .font(.custom("Montserrat-Bold", size: 42))
                    Text("Bring the world closer.")
                        .font(.custom("Montserrat-Medium", size: 18))

                    Button("Begin") {
                        appFlow.openStoryline()
                    }
                    .font(.custom("Montserrat-Bold", size: 18))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 34)
                    .padding(.vertical, 14)
                    .background(Color(red: 0.82, green: 0.42, blue: 0.34), in: RoundedRectangle(cornerRadius: 14))
                    .padding(.top, 20)
                }
            }
            .multilineTextAlignment(.center)
            .foregroundStyle(Color(red: 0.22, green: 0.24, blue: 0.30))
            .padding(32)
            .transition(.opacity)
        }
        .onAppear {
            showNextStep(after: 1.5)
        }
    }

    private func showNextStep(after delay: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            guard step < 2 else { return }
            withAnimation(.easeInOut(duration: 0.45)) {
                step += 1
            }
            showNextStep(after: 1.5)
        }
    }
}

