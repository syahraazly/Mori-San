final class GameViewModel {
    enum Screen {
        case onboarding
        case levelSelection
        case playing
    }

    private let levels = HomeLevelData.levels

    private(set) var currentLevel: GameLevel
    private(set) var screen: Screen = .onboarding

    private(set) var connections: [ConnectionModel] = []
    private(set) var hasReachedExit = false
    private(set) var moriPlatformID: String

    init() {
        currentLevel = levels[0]
        moriPlatformID = currentLevel.player.startingPlatformID
    }

    var isConnected: Bool {
        !connections.isEmpty
    }

    @discardableResult
    func connect(_ firstPlatformID: String, to secondPlatformID: String) -> Bool {
        if connections.contains(where: {
            ($0.firstPlatformID == firstPlatformID && $0.secondPlatformID == secondPlatformID)
                || ($0.firstPlatformID == secondPlatformID && $0.secondPlatformID == firstPlatformID)
        }) {
            return false
        }

        connections = [
            ConnectionModel(
                firstPlatformID: firstPlatformID,
                secondPlatformID: secondPlatformID
            )
        ]
        return true
    }

    func canMoveMori(to platformID: String) -> Bool {
        guard !hasReachedExit, platformID != moriPlatformID else { return false }

        return areConnected(moriPlatformID, platformID)
    }

    func areConnected(_ firstPlatformID: String, _ secondPlatformID: String) -> Bool {
        connections.contains {
            ($0.firstPlatformID == firstPlatformID && $0.secondPlatformID == secondPlatformID)
                || ($0.firstPlatformID == secondPlatformID && $0.secondPlatformID == firstPlatformID)
        }
    }

    func moveMori(to platformID: String) {
        moriPlatformID = platformID
    }

    func markExitReached() {
        hasReachedExit = true
    }

    func showLevelSelection() {
        screen = .levelSelection
    }

    func startLevel(withID levelID: String) -> Bool {
        guard let level = levels.first(where: { $0.id == levelID }) else { return false }

        currentLevel = level
        connections = []
        hasReachedExit = false
        moriPlatformID = currentLevel.player.startingPlatformID
        screen = .playing
        return true
    }

    func isPlayableLevel(_ levelID: String) -> Bool {
        levels.contains(where: { $0.id == levelID })
    }

    @discardableResult
    func advanceToNextLevel() -> Bool {
        guard let currentIndex = levels.firstIndex(where: { $0.id == currentLevel.id }) else { return false }
        let remainingLevels = levels.dropFirst(currentIndex + 1)
        guard let nextLevel = remainingLevels.first(where: { $0.category == currentLevel.category }) else {
            return false
        }

        currentLevel = nextLevel
        connections = []
        hasReachedExit = false
        moriPlatformID = currentLevel.player.startingPlatformID
        return true
    }
}
