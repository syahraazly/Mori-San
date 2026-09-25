struct MapChapterConfiguration: Identifiable {
    let id: GoalID
    let order: Int
    let progressionTitle: String
    let clue: String

    // Kept in data so the flower can be revealed without making chapter-specific views.
    let flowerAssetName: String
    let flowerDisplayName: String
    let isComingSoon: Bool
    let unlockedPrompt: String
    let backgroundAssetName: String
}

enum MapChapterState: Equatable {
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
            clue: "When was the last time you looked at yourself?",
            flowerAssetName: "forget-me-not-flower",
            flowerDisplayName: "Forget Me Not Flower",
            isComingSoon: false,
            unlockedPrompt: "When was the last time you looked at yourself?",
            backgroundAssetName: "background-chapter-1"
        ),
        MapChapterConfiguration(
            id: "white-lily",
            order: 2,
            progressionTitle: "Everything I wanted",
            clue: "Somewhere, something still feels familiar.",
            flowerAssetName: "white-lily-flower",
            flowerDisplayName: "White Lily Flower",
            isComingSoon: false,
            unlockedPrompt: "What makes a place feel like home?",
            backgroundAssetName: "background-chapter-2"
        ),
        MapChapterConfiguration(
            id: "balinese-frangipani",
            order: 3,
            progressionTitle: "From Dusk till Dawn",
            clue: "Some paths aren't meant to be walked alone.",
            flowerAssetName: "kamboja-bali-flower",
            flowerDisplayName: "Balinese Frangipani Flower",
            isComingSoon: false,
            unlockedPrompt: "Do we ever really need no one?",
            backgroundAssetName: "background-chapter-3"
        ),
        MapChapterConfiguration(
            id: "chapter-4",
            order: 4,
            progressionTitle: "To Be Continued",
            clue: "A new story\nwill bloom soon.",
            flowerAssetName: "",
            flowerDisplayName: "",
            isComingSoon: true,
            unlockedPrompt: "",
            backgroundAssetName: "background-map"
        )
    ]

    static func chapter(for goalID: GoalID) -> MapChapterConfiguration? {
        guard let resolvedGoalID = FlowerGoalData.goal(for: goalID)?.id else { return nil }
        return chapters.first {
            FlowerGoalData.goal(for: $0.id)?.id == resolvedGoalID
        }
    }
}
