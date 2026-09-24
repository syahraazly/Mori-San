protocol MapChapterProgressProviding {
    func isChapterUnlocked(_ chapterID: GoalID) -> Bool
    func isChapterCompleted(_ chapterID: GoalID) -> Bool
}

final class MapViewModel {
    let chapters: [MapChapterConfiguration]

    private let isChapterUnlocked: (GoalID) -> Bool
    private let isChapterCompleted: (GoalID) -> Bool
    private let petalCount: (GoalID) -> Int

    init(
        chapters: [MapChapterConfiguration] = MapChapterData.chapters,
        isChapterUnlocked: @escaping (GoalID) -> Bool,
        isChapterCompleted: @escaping (GoalID) -> Bool,
        petalCount: @escaping (GoalID) -> Int = { _ in 0 }
    ) {
        self.chapters = chapters.sorted { $0.order < $1.order }
        self.isChapterUnlocked = isChapterUnlocked
        self.isChapterCompleted = isChapterCompleted
        self.petalCount = petalCount
    }

    convenience init(
        chapters: [MapChapterConfiguration] = MapChapterData.chapters,
        progress: MapChapterProgressProviding
    ) {
        self.init(
            chapters: chapters,
            isChapterUnlocked: progress.isChapterUnlocked,
            isChapterCompleted: progress.isChapterCompleted
        )
    }

    func state(for chapter: MapChapterConfiguration) -> MapChapterState {
        if isChapterCompleted(chapter.id) {
            return .completed
        }

        return isChapterUnlocked(chapter.id) ? .unlocked : .locked
    }

    func collectedPetals(for chapter: MapChapterConfiguration) -> Int {
        petalCount(chapter.id)
    }
}

// Small in-memory provider for Map development and the four requested states.
struct MapPreviewProgress: MapChapterProgressProviding {
    let unlockedChapterIDs: Set<GoalID>
    let completedChapterIDs: Set<GoalID>

    func isChapterUnlocked(_ chapterID: GoalID) -> Bool {
        unlockedChapterIDs.contains(chapterID) || completedChapterIDs.contains(chapterID)
    }

    func isChapterCompleted(_ chapterID: GoalID) -> Bool {
        completedChapterIDs.contains(chapterID)
    }

    static let scenarioA = MapPreviewProgress(
        unlockedChapterIDs: ["forget-me-not"],
        completedChapterIDs: []
    )
    static let scenarioB = MapPreviewProgress(
        unlockedChapterIDs: ["white-lily"],
        completedChapterIDs: ["forget-me-not"]
    )
    static let scenarioC = MapPreviewProgress(
        unlockedChapterIDs: ["balinese-frangipani"],
        completedChapterIDs: ["forget-me-not", "white-lily"]
    )
    static let scenarioD = MapPreviewProgress(
        unlockedChapterIDs: [],
        completedChapterIDs: ["forget-me-not", "white-lily", "balinese-frangipani"]
    )
}
