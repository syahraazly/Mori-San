struct GoalProgress {
    private(set) var completedLevelIDs: Set<LevelID> = []

    mutating func completeLevel(_ levelID: LevelID) {
        let canonicalID = LevelCatalog.canonicalID(for: levelID)
        completedLevelIDs.insert(canonicalID)
    }

    func isLevelCompleted(_ levelID: LevelID) -> Bool {
        let canonicalID = LevelCatalog.canonicalID(for: levelID)
        return completedLevelIDs.contains(canonicalID)
    }

    func petalCount(for goal: FlowerGoal) -> Int {
        goal.levelIDs.filter { isLevelCompleted($0) }.count
    }

    func isGoalCompleted(_ goal: FlowerGoal) -> Bool {
        !goal.levelIDs.isEmpty && goal.levelIDs.allSatisfy { isLevelCompleted($0) }
    }
}

