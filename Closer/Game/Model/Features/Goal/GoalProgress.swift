struct GoalProgress {
    private(set) var completedLevelIDs: Set<LevelID> = []
    private(set) var claimedPetalLevelIDs: Set<LevelID> = []

    mutating func completeLevel(_ levelID: LevelID) {
        let canonicalID = LevelCatalog.canonicalID(for: levelID)
        completedLevelIDs.insert(canonicalID)
    }

    func isLevelCompleted(_ levelID: LevelID) -> Bool {
        let canonicalID = LevelCatalog.canonicalID(for: levelID)
        return completedLevelIDs.contains(canonicalID)
    }

    mutating func claimPetal(for levelID: LevelID) {
        claimedPetalLevelIDs.insert(LevelCatalog.canonicalID(for: levelID))
    }

    func hasClaimedPetal(for levelID: LevelID) -> Bool {
        claimedPetalLevelIDs.contains(LevelCatalog.canonicalID(for: levelID))
    }

    func petalCount(for goal: FlowerGoal) -> Int {
        goal.levelIDs.filter {
            hasClaimedPetal(for: $0) || isLevelCompleted($0)
        }.count
    }

    func isGoalCompleted(_ goal: FlowerGoal) -> Bool {
        !goal.levelIDs.isEmpty && goal.levelIDs.allSatisfy { isLevelCompleted($0) }
    }
}
