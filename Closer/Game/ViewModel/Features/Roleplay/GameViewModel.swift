final class GameViewModel {
    enum PerspectivePOV {
        case front
        case side
    }

    private(set) var currentLevel: LevelConfiguration

    private(set) var connections: [ConnectionModel] = []
    private var baseConnections: [ConnectionModel] = []
    private var perspectiveConnections: [ConnectionModel] = []
    private var snapConnections: [ConnectionModel] = []
    private var lightConnections: [ConnectionModel] = []
    private(set) var hasReachedExit = false
    private(set) var hasCollectedPetal = false
    private(set) var isLightRevealed = false
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
    func revealLightRoute() -> Bool {
        guard let lightReveal = currentLevel.lightRevealConfiguration,
              !isLightRevealed else {
            return false
        }

        isLightRevealed = true
        lightConnections = lightReveal.activatedConnections
        rebuildConnections()
        return true
    }

    @discardableResult
    func connect(_ firstPlatformID: String, to secondPlatformID: String) -> Bool {
        // The second platform is the movable platform. Its previous snap link
        // must be replaced when it is snapped to a new target.
        snapConnections.removeAll {
            $0.firstPlatformID == secondPlatformID || $0.secondPlatformID == secondPlatformID
        }

        snapConnections.append(
            ConnectionModel(
                firstPlatformID: firstPlatformID,
                secondPlatformID: secondPlatformID
            )
        )
        rebuildConnections()
        return true
    }

    func disconnectSnap(for platformID: String? = nil) {
        if let platformID {
            snapConnections.removeAll {
                $0.firstPlatformID == platformID || $0.secondPlatformID == platformID
            }
        } else {
            snapConnections.removeAll()
        }
        rebuildConnections()
    }

    // Kept for the gameplay-dev caller that disconnects a bridge as soon as it moves.
    func disconnectSnappedConnections(for platformID: String) {
        disconnectSnap(for: platformID)
    }

    private func rebuildConnections() {
        var resolvedConnections: [ConnectionModel] = []

        for connection in baseConnections + perspectiveConnections + snapConnections + lightConnections
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
        baseConnections = newConnections
        perspectiveConnections = []
        snapConnections = []
        lightConnections = isLightRevealed
            ? currentLevel.lightRevealConfiguration?.activatedConnections ?? []
            : []
        rebuildConnections()
    }

    func setPerspectiveConnections(_ newConnections: [ConnectionModel]) {
        perspectiveConnections = newConnections
        rebuildConnections()
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
        baseConnections = currentLevel.initialConnections
        perspectiveConnections = []
        snapConnections = []
        lightConnections = []
        hasReachedExit = false
        hasCollectedPetal = false
        isLightRevealed = false
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
        guard currentLevel.platforms.first(where: { $0.id == platformID })?.isWalkable == true else {
            return false
        }

        guard let lightReveal = currentLevel.lightRevealConfiguration,
              lightReveal.hiddenPlatformIDs.contains(platformID) else {
            return true
        }

        return isLightRevealed
    }

//    private func rebuildConnections() {
//        var resolvedConnections: [ConnectionModel] = []
//
//        for connection in perspectiveConnections + snapConnections
//        where isWalkable(connection.firstPlatformID) && isWalkable(connection.secondPlatformID) {
//            let alreadyIncluded = resolvedConnections.contains {
//                ($0.firstPlatformID == connection.firstPlatformID
//                    && $0.secondPlatformID == connection.secondPlatformID)
//                    || ($0.firstPlatformID == connection.secondPlatformID
//                        && $0.secondPlatformID == connection.firstPlatformID)
//            }
//
//            if !alreadyIncluded {
//                resolvedConnections.append(connection)
//            }
//        }
//
//        connections = resolvedConnections
//    }

}
