final class GameViewModel {
    let level = LevelData.closerLevel

    private(set) var connections: [ConnectionModel] = []
    private(set) var hasReachedExit = false

    var isConnected: Bool {
        !connections.isEmpty
    }

    @discardableResult
    func connect(_ firstPlatformID: String, to secondPlatformID: String) -> Bool {
        guard !isConnected else { return false }

        connections.append(
            ConnectionModel(
                firstPlatformID: firstPlatformID,
                secondPlatformID: secondPlatformID
            )
        )
        return true
    }

    func canMoveMoriToExit() -> Bool {
        isConnected && !hasReachedExit
    }

    func markExitReached() {
        hasReachedExit = true
    }
}
