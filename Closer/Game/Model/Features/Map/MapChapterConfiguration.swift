struct MapChapterConfiguration: Identifiable {
    let id: GoalID
    let order: Int
    let progressionTitle: String
    let clue: String

    // Kept in data so the flower can be revealed without making chapter-specific views.
    let flowerAssetName: String
    let flowerDisplayName: String
    let isComingSoon: Bool
}

enum MapChapterState {
    case locked
    case unlocked
    case completed
}

enum MapChapterData {
    static let chapters = [
        MapChapterConfiguration(
            id: "forget-me-not",
            order: 1,
            progressionTitle: "Scars to your beautiful",
            clue: "Small blue petals,\nin places you've been,\nbut not forgotten.",
            flowerAssetName: "forget-me-not-flower",
            flowerDisplayName: "Forget-Me-Not",
            isComingSoon: false
        ),
        MapChapterConfiguration(
            id: "white-lily",
            order: 2,
            progressionTitle: "Everything I wanted",
            clue: "Pure light\nthat blooms anew,\neven in silence.",
            flowerAssetName: "white-lily-flower",
            flowerDisplayName: "White Lily",
            isComingSoon: false
        ),
        MapChapterConfiguration(
            id: "balinese-frangipani",
            order: 3,
            progressionTitle: "From Dusk till Dawn",
            clue: "Warm petals\nthat carry memories\nacross time.",
            flowerAssetName: "kamboja-bali-flower",
            flowerDisplayName: "Balinese Frangipani",
            isComingSoon: false
        ),
        MapChapterConfiguration(
            id: "chapter-4",
            order: 4,
            progressionTitle: "To Be Continued",
            clue: "A new story\nwill bloom soon.",
            flowerAssetName: "",
            flowerDisplayName: "",
            isComingSoon: true
        )
    ]

    static func chapter(for goalID: GoalID) -> MapChapterConfiguration? {
        guard let resolvedGoalID = FlowerGoalData.goal(for: goalID)?.id else { return nil }
        return chapters.first {
            FlowerGoalData.goal(for: $0.id)?.id == resolvedGoalID
        }
    }
}
