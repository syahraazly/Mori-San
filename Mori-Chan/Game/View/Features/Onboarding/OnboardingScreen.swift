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
                } else if step == 2 {
                    VStack(spacing: 12) {
                        Text("Somewhere beyond the distance...")
                        HomeSymbol()
                    }
                } else {
                    Text("MORI-SAN")
                        .font(.system(size: 42, weight: .bold))
                    Text("Bring the world closer.")
                        .font(.system(size: 18, weight: .medium))

                    Button("Begin") {
                        appFlow.openStoryline()
                    }
                    .font(.system(size: 18, weight: .bold))
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
            guard step < 3 else { return }
            withAnimation(.easeInOut(duration: 0.45)) {
                step += 1
            }
            showNextStep(after: 1.5)
        }
    }
}

private struct HomeSymbol: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            Rectangle().frame(width: 34, height: 26)
            Triangle().frame(width: 48, height: 30).offset(y: -24)
        }
        .foregroundStyle(Color(red: 0.38, green: 0.31, blue: 0.52))
        .frame(width: 52, height: 58)
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
