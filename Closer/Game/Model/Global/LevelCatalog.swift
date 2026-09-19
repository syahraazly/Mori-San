enum LevelCatalog {
    static let configurations = TutorialLevelData.levels
        + ForgetMeNotLevelData.levels
        + BalineseFrangipaniLevelData.levels

    static func configuration(for levelID: LevelID) -> LevelConfiguration? {
        configurations.first { $0.id == levelID }
    }

    static func goalID(for levelID: LevelID) -> GoalID? {
        FlowerGoalData.goals.first { $0.levelIDs.contains(levelID) }?.id
    }

    static func nextTutorialLevel(after levelID: LevelID) -> LevelID? {
        guard let currentIndex = TutorialLevelData.levels.firstIndex(where: { $0.id == levelID }) else {
            return nil
        }

        let nextIndex = TutorialLevelData.levels.index(after: currentIndex)
        guard nextIndex < TutorialLevelData.levels.endIndex else { return nil }
        return TutorialLevelData.levels[nextIndex].id
    }
}
