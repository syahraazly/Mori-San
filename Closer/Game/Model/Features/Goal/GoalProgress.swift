struct GoalProgress {
    private(set) var completedLevelIDs: Set<LevelID> = []

    mutating func completeLevel(_ levelID: LevelID) {
        completedLevelIDs.insert(levelID)
    }

    func isLevelCompleted(_ levelID: LevelID) -> Bool {
        completedLevelIDs.contains(levelID)
    }
}
