import SwiftUI

struct StoryPageView: View {

    let beat: StoryBeat

    var body: some View {
        ZStack {

            // MARK: - Background

            Color.storyNightIndigo
                .ignoresSafeArea()

            // All beats now have fully composed artwork.
            Image(beat.imageName)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            // MARK: - Story Text

            storyText
                .padding(.horizontal, 32)
                .padding(.top, beat.textTopPadding ?? 110)
                .padding(.bottom, 110)
        }
    }

    // MARK: - Text Layout

    @ViewBuilder
    private var storyText: some View {
        switch beat.layout {

        case .topLeading:
            VStack(alignment: .leading) {
                textContent
                Spacer()
            }

        case .centerLeading:
            VStack(alignment: .leading) {
                Spacer()
                textContent
                Spacer()
            }

        case .bottomLeading:
            VStack(alignment: .leading) {
                Spacer()
                textContent
            }
        }
    }

    // MARK: - Text Content

    private var textContent: some View {
        VStack(alignment: .leading, spacing: 28) {

            // Narration
            if let narration = beat.narration {
                Text(narration)
                    .font(
                        .custom("Montserrat-Medium", size: 18)
                    )
                    .foregroundStyle(Color.storySoftWhite)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(5)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
            }

            // Mori's thought
            if let thought = beat.thought {
                Text("\"\(thought)\"")
                    .font(
                        .custom("Montserrat-Italic", size: 17)
                    )
                    .foregroundStyle(Color.storyAccent)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(4)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
            }
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
    }
}

// MARK: - Storyline Colors

private extension Color {

    /// #30305A — Night Indigo
    static let storyNightIndigo = Color(
        red: 0.188,
        green: 0.188,
        blue: 0.353
    )

    /// #FFFCF7 — Soft White
    static let storySoftWhite = Color(
        red: 1.000,
        green: 0.988,
        blue: 0.969
    )

    /// #C9D0F2 — Accent
    static let storyAccent = Color(
        red: 0.788,
        green: 0.816,
        blue: 0.949
    )
}
