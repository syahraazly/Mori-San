struct MapChapterConfiguration: Identifiable {
    let id: GoalID
    let order: Int
    let clue: String

    // Kept in data so the flower can be revealed without making chapter-specific views.
    let flowerAssetName: String
    let flowerDisplayName: String
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
            clue: "Small blue petals,\nin places you've been,\nbut not forgotten.",
            flowerAssetName: "forgetmenotFlower",
            flowerDisplayName: "Forget Me Not"
        ),
        MapChapterConfiguration(
            id: "white-lily",
            order: 2,
            clue: "Pure light\nthat blooms anew,\neven in silence.",
            flowerAssetName: "lilyputihFlower",
            flowerDisplayName: "White Lily"
        ),
        MapChapterConfiguration(
            id: "balinese-frangipani",
            order: 3,
            clue: "Warm petals\nthat carry memories\nacross time.",
            flowerAssetName: "kambojabaliFlower",
            flowerDisplayName: "Balinese Frangipani"
        )
    ]
}
