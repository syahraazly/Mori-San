import SwiftUI

/// Renders a single StoryBeat: its scene illustration and Mori's thought.
/// Contains no progression logic, gestures, or navigation.
struct StoryPageView: View {
    let beat: StoryBeat

    var body: some View {
        ZStack {
            Color(red: 0.95, green: 0.90, blue: 0.82)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Image(beat.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                if let thought = beat.thought {
                    Text(thought)
                        .font(.system(size: 18, weight: .regular))
                        .italic()
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color(red: 0.38, green: 0.31, blue: 0.52))
                        .padding(.horizontal, 32)
                        .padding(.vertical, 28)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }
}
