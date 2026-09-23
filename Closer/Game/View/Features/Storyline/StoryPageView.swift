import SwiftUI
import UIKit

/// Renders a single StoryBeat: scene background, Mori idle animation,
/// external narration caption, and Mori's inner thought card.
/// Contains no progression logic, gestures, or navigation.
struct StoryPageView: View {
    let beat: StoryBeat

    @State private var idleFrame: Int = 0

    /// True when the beat's named illustration asset exists in the bundle.
    /// Night Indigo + Mori idle are shown as the fallback until art arrives.
    private var hasIllustration: Bool {
        UIImage(named: beat.imageName) != nil
    }

    var body: some View {
        ZStack {
            // ── Background ────────────────────────────────────────────────
            // Night Indigo is the temporary scene colour.
            // When final art arrives, add it to the asset catalog under
            // beat.imageName and it will naturally overlay this colour.
            Color.storyNightIndigo
                .ignoresSafeArea()

            // Final scene illustration — shown only when the asset exists.
            if hasIllustration {
                Image(beat.imageName)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            }

            // ── Content ───────────────────────────────────────────────────
            VStack(alignment: .center, spacing: 0) {

                // Narration — external narrator / world voice (webtoon caption)
                if let narration = beat.narration {
                    NarrationCaption(text: narration)
                        .padding(.top, 8)
                }

                Spacer()

                // Mori idle — main visual until final illustration arrives
                if !hasIllustration {
                    Image(idleFrame == 0 ? "mori-idle-1" : "mori-idle-2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 220)
                }

                Spacer()

                // Thought — Mori's inner voice
                if let thought = beat.thought {
                    ThoughtCard(text: thought)
                        .padding(.bottom, 20)
                }
            }
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        // Restart the idle animation whenever the beat changes.
        .task(id: beat.id) {
            guard !hasIllustration else { return }
            idleFrame = 0
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 550_000_000) // 0.55 s per frame
                guard !Task.isCancelled else { break }
                idleFrame = idleFrame == 0 ? 1 : 0
            }
        }
    }
}

// MARK: - Narration Caption
// Styled as a webtoon/storybook caption panel: solid light card, left-aligned.

private struct NarrationCaption: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 14, weight: .regular))
            .multilineTextAlignment(.leading)
            .foregroundStyle(Color.storyNightIndigo)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.storySoftWhite.opacity(0.92))
            )
    }
}

// MARK: - Thought Card
// Styled as Mori's inner voice: italic, accent colour, translucent card.

private struct ThoughtCard: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 17, weight: .regular))
            .italic()
            .multilineTextAlignment(.center)
            .foregroundStyle(Color.storyAccent)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.08))
            )
    }
}

// MARK: - Storyline-local colour tokens
// Scoped to this file — do not promote to a global design system.

private extension Color {
    /// #30305A — Night Indigo (main dark background)
    static let storyNightIndigo = Color(red: 0.188, green: 0.188, blue: 0.353)
    /// #FFFCF7 — Soft White (narration caption background)
    static let storySoftWhite   = Color(red: 1.000, green: 0.988, blue: 0.969)
    /// #C9D0F2 — Accent (Mori's thought text)
    static let storyAccent      = Color(red: 0.788, green: 0.816, blue: 0.949)
}
