import Foundation

struct FlowerCelebrationInfo {
    let goalID: GoalID
    let flowerName: String
    let chapterRoman: String
    let chapterSubtitle: String
    let flowerAssetName: String
    let petalAssetName: String
    let totalPetals: Int
    let speechBubbleText: String
    let aboutTitle: String
    let aboutDescription: String
    let moriLearnedQuote: String
    let playAgainSubtitle: String

    static func info(for goalID: GoalID) -> FlowerCelebrationInfo {
        let normalized = FlowerGoalData.goal(for: goalID)?.id ?? goalID
        switch normalized {
        case "chapter-2":
            return FlowerCelebrationInfo(
                goalID: "chapter-2",
                flowerName: "White Lily",
                chapterRoman: "Chapter II",
                chapterSubtitle: "in Chapter II",
                flowerAssetName: "white-lily-flower",
                petalAssetName: "white-lily-petal",
                totalPetals: 6,
                speechBubbleText: "We grew\nstronger\ntogether.",
                aboutTitle: "About White Lily",
                aboutDescription: "White Lily symbolizes pure renewal and resilience, showing that even after the deepest silence, hope gently blossoms. It reminds us that every ending is simply a quiet prelude to beginning anew.",
                moriLearnedQuote: "Mori learned that standing tall does not mean never trembling. Grace is found in moving forward anyway.",
                playAgainSubtitle: "Play Chapter II again"
            )
        case "chapter-3":
            return FlowerCelebrationInfo(
                goalID: "chapter-3",
                flowerName: "Kamboja Bali",
                chapterRoman: "Chapter III",
                chapterSubtitle: "in Chapter III",
                flowerAssetName: "kamboja-bali-flower",
                petalAssetName: "kamboja-bali-petal",
                totalPetals: 5,
                speechBubbleText: "You found\nyour light,\nMori.",
                aboutTitle: "About Kamboja Bali",
                aboutDescription: "Kamboja Bali symbolizes eternal devotion and inner peace, carrying a fragrant blessing that lingers in the air. It reflects the beauty of embracing our true journey with humility and warmth.",
                moriLearnedQuote: "Mori learned that the greatest warmth comes from within. Wherever you go, you carry your own gentle light.",
                playAgainSubtitle: "Play Chapter III again"
            )
        default:
            return FlowerCelebrationInfo(
                goalID: "chapter-1",
                flowerName: "Forget Me Not",
                chapterRoman: "Chapter I",
                chapterSubtitle: "in Chapter I",
                flowerAssetName: "forget-me-not-flower",
                petalAssetName: "forget-me-not-petal",
                totalPetals: 5,
                speechBubbleText: "Thank you\nfor walking\nwith me.",
                aboutTitle: "About Forget Me Not",
                aboutDescription: "Forget Me Not symbolizes a lasting memory, a quiet reminder that even the smallest moments still matter. No matter where you go, the kindness, people, and places you've encountered will always be a part of you.",
                moriLearnedQuote: "Mori learned that every step, even the small ones, leaves a trace. Nothing truly disappears.",
                playAgainSubtitle: "Play Chapter I again"
            )
        }
    }
}
