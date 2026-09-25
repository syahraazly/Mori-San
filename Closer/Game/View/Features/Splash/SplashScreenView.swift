import SwiftUI

struct SplashScreenView: View {
    @ObservedObject var appFlow: AppFlowViewModel

    @State private var isPulsing = false
    @State private var isTransitioning = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Solid theme color underlay to prevent black flash
                Color(red: 0.173, green: 0.165, blue: 0.322)
                    .ignoresSafeArea()

                // Background image identical to LaunchScreen
                Image("splashBackground")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()

                VStack(spacing: 0) {
                    // Logo centered horizontally and positioned exactly as in LaunchScreen
                    Image("morichan")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 240, height: 48)
                        .padding(.top, geometry.safeAreaInsets.top + 138)

                    Spacer()

                    // "TAP TO BEGIN" pulsing in the lower section
                    VStack(spacing: 8) {
                        Text("TAP TO BEGIN")
                            .font(.custom("Montserrat-SemiBold", size: 16))
                            .tracking(3.5)
                            .foregroundStyle(Color.white)
                            .shadow(color: Color.black.opacity(0.55), radius: 8, x: 0, y: 2)
                            .opacity(isPulsing ? 1.0 : 0.25)
                            .scaleEffect(isPulsing ? 1.02 : 0.98)
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .padding(.bottom, max(geometry.safeAreaInsets.bottom, 20) + 48)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .ignoresSafeArea()
        .contentShape(Rectangle())
        .onTapGesture {
            handleTapToBegin()
        }
        .opacity(isTransitioning ? 0 : 1)
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1.15)
                .repeatForever(autoreverses: true)
            ) {
                isPulsing = true
            }
        }
    }

    private func handleTapToBegin() {
        guard !isTransitioning else { return }

        HapticManager.playSnapFeedback()

        withAnimation(.easeInOut(duration: 0.35)) {
            isTransitioning = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            appFlow.begin()
        }
    }
}

#Preview {
    SplashScreenView(appFlow: AppFlowViewModel())
}
