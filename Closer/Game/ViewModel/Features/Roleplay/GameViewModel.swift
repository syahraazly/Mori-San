final class GameViewModel {
    enum PerspectivePOV {
        case front
        case side
    }

    private(set) var currentLevel: LevelConfiguration

    private(set) var connections: [ConnectionModel] = []
    // Perspective/proximity links are recalculated as the world changes POV.
    // A movable platform keeps its latest snap link until it moves to another target.
    private var generatedConnections: [ConnectionModel] = []
    private var snappedConnections: [ConnectionModel] = []
    private(set) var hasReachedExit = false
    private(set) var hasCollectedPetal = false
    private(set) var moriPlatformID: String
    private(set) var perspectivePOV: PerspectivePOV = .front

    init(initialLevel: LevelConfiguration) {
        currentLevel = initialLevel
        moriPlatformID = currentLevel.player.startingPlatformID
    }

    var isConnected: Bool {
        !connections.isEmpty
    }

    var hasPetalToCollect: Bool {
        currentLevel.petalConfiguration != nil
    }

    var isExitUnlocked: Bool {
        !hasPetalToCollect || hasCollectedPetal
    }

    func collectPetal() {
        hasCollectedPetal = true
    }

    @discardableResult
    func connect(_ firstPlatformID: String, to secondPlatformID: String) -> Bool {
        // `secondPlatformID` is the platform being snapped by GameScene.
        // Replacing only its older snap link preserves Moving Bridge behavior
        // while allowing other compacted platforms to stay connected.
        snappedConnections.removeAll {
            $0.firstPlatformID == secondPlatformID || $0.secondPlatformID == secondPlatformID
        }
        snappedConnections.append(
            ConnectionModel(
                firstPlatformID: firstPlatformID,
                secondPlatformID: secondPlatformID
            )
        )
        rebuildConnections()
        return true
    }

    func disconnectSnappedConnections(for platformID: String) {
        snappedConnections.removeAll {
            $0.firstPlatformID == platformID || $0.secondPlatformID == platformID
        }
        rebuildConnections()
    }

    func canMoveMori(to platformID: String) -> Bool {
        guard !hasReachedExit,
              platformID != moriPlatformID,
              isWalkable(platformID) else { return false }

        guard let path = connectionPath(from: moriPlatformID, to: platformID) else {
            return false
        }

        switch currentLevel.movementMode {
        case .pathfinding:
            return true
        case .adjacentOnly:
            return path.count == 2
        }
    }

    func areConnected(_ firstPlatformID: String, _ secondPlatformID: String) -> Bool {
        connections.contains {
            ($0.firstPlatformID == firstPlatformID && $0.secondPlatformID == secondPlatformID)
                || ($0.firstPlatformID == secondPlatformID && $0.secondPlatformID == firstPlatformID)
        }
    }

    func connectionPath(from startPlatformID: String, to targetPlatformID: String) -> [String]? {
        guard isWalkable(startPlatformID), isWalkable(targetPlatformID) else { return nil }

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

                guard let neighbourID,
                      isWalkable(neighbourID),
                      !visitedPlatformIDs.contains(neighbourID) else { continue }
                visitedPlatformIDs.insert(neighbourID)
                previousPlatformID[neighbourID] = currentPlatformID
                platformsToVisit.append(neighbourID)
            }
        }

        return nil
    }

    func setConnections(_ newConnections: [ConnectionModel]) {
        generatedConnections = newConnections
        rebuildConnections()
    }

    func setPerspectiveConnections(_ newConnections: [ConnectionModel]) {
        setConnections(currentLevel.initialConnections + newConnections)
    }

    func moveMori(to platformID: String) {
        guard isWalkable(platformID) else { return }
        moriPlatformID = platformID
    }

    func markExitReached() {
        hasReachedExit = true
    }

    func loadLevel(_ configuration: LevelConfiguration) {
        currentLevel = configuration
        connections = []
        generatedConnections = []
        snappedConnections = []
        hasReachedExit = false
        hasCollectedPetal = false
        moriPlatformID = currentLevel.player.startingPlatformID
        perspectivePOV = .front
    }

    func restartLevel() {
        loadLevel(currentLevel)
    }

    func togglePerspectivePOV() {
        perspectivePOV = perspectivePOV == .front ? .side : .front
    }

    private func isWalkable(_ platformID: String) -> Bool {
        currentLevel.platforms.first(where: { $0.id == platformID })?.isWalkable == true
    }

    private func rebuildConnections() {
        var resolvedConnections: [ConnectionModel] = []

        for connection in generatedConnections + snappedConnections
        where isWalkable(connection.firstPlatformID) && isWalkable(connection.secondPlatformID) {
            let alreadyIncluded = resolvedConnections.contains {
                ($0.firstPlatformID == connection.firstPlatformID
                    && $0.secondPlatformID == connection.secondPlatformID)
                    || ($0.firstPlatformID == connection.secondPlatformID
                        && $0.secondPlatformID == connection.firstPlatformID)
            }

            if !alreadyIncluded {
                resolvedConnections.append(connection)
            }
        }

        connections = resolvedConnections
    }

}
