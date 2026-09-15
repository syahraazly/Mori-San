final class GameViewModel {
    enum PerspectivePOV {
        case front
        case side
    }

    enum Screen {
        case onboarding
        case levelSelection
        case chapterTransition
        case home
        case playing
    }

    private let levels = TutorialLevelData.levels
    private let mainLevels = HomeProgressData.levels
    private var pendingLevel: GameLevel?

    private(set) var currentLevel: GameLevel
    private(set) var screen: Screen = .playing

    private(set) var connections: [ConnectionModel] = []
    private(set) var hasReachedExit = false
    private(set) var moriPlatformID: String
    private(set) var perspectivePOV: PerspectivePOV = .front

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

        return connectionPath(from: moriPlatformID, to: platformID) != nil
    }

    func areConnected(_ firstPlatformID: String, _ secondPlatformID: String) -> Bool {
        connections.contains {
            ($0.firstPlatformID == firstPlatformID && $0.secondPlatformID == secondPlatformID)
                || ($0.firstPlatformID == secondPlatformID && $0.secondPlatformID == firstPlatformID)
        }
    }

    func connectionPath(from startPlatformID: String, to targetPlatformID: String) -> [String]? {
        var platformsToVisit = [startPlatformID]
        var visitedPlatformIDs: Set<String> = [startPlatformID]
        var previousPlatformID: [String: String] = [:]

        while !platformsToVisit.isEmpty {
            let currentPlatformID = platformsToVisit.removeFirst()

            if currentPlatformID == targetPlatformID {
                var path = [targetPlatformID]
                var platformID = targetPlatformID

                while let previousID = previousPlatformID[platformID] {
                    path.append(previousID)
                    platformID = previousID
                }

                return path.reversed()
            }

            for connection in connections {
                let neighbourID: String?
                if connection.firstPlatformID == currentPlatformID {
                    neighbourID = connection.secondPlatformID
                } else if connection.secondPlatformID == currentPlatformID {
                    neighbourID = connection.firstPlatformID
                } else {
                    neighbourID = nil
                }

                guard let neighbourID, !visitedPlatformIDs.contains(neighbourID) else { continue }
                visitedPlatformIDs.insert(neighbourID)
                previousPlatformID[neighbourID] = currentPlatformID
                platformsToVisit.append(neighbourID)
            }
        }

        return nil
    }

    func setPerspectiveConnections(_ newConnections: [ConnectionModel]) {
        connections = newConnections
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

    func showHome() {
        screen = .home
    }

    func startMainLevelOne() {
        startMainLevel(withID: "home-1")
    }

    func startMainLevel(withID levelID: String) {
        guard let level = mainLevels.first(where: { $0.id == levelID }) else { return }

        currentLevel = level
        connections = []
        hasReachedExit = false
        moriPlatformID = currentLevel.player.startingPlatformID
        perspectivePOV = .front
        screen = .playing
    }

    func togglePerspectivePOV() {
        perspectivePOV = perspectivePOV == .front ? .side : .front
    }

    func startLevel(withID levelID: String) -> Bool {
        guard let level = levels.first(where: { $0.id == levelID }) else { return false }

        currentLevel = level
        connections = []
        hasReachedExit = false
        moriPlatformID = currentLevel.player.startingPlatformID
        perspectivePOV = .front
        screen = .playing
        return true
    }

    func isPlayableLevel(_ levelID: String) -> Bool {
        levels.contains(where: { $0.id == levelID })
    }

    @discardableResult
    func prepareNextLevel() -> Bool {
        guard let currentIndex = levels.firstIndex(where: { $0.id == currentLevel.id }) else { return false }
        let remainingLevels = levels.dropFirst(currentIndex + 1)
        guard let nextLevel = remainingLevels.first(where: { $0.category == currentLevel.category }) else {
            return false
        }

        pendingLevel = nextLevel
        screen = .chapterTransition
        return true
    }

    func startPreparedLevel() {
        guard let pendingLevel else { return }

        currentLevel = pendingLevel
        self.pendingLevel = nil
        connections = []
        hasReachedExit = false
        moriPlatformID = currentLevel.player.startingPlatformID
        perspectivePOV = .front
        screen = .playing
    }
}
