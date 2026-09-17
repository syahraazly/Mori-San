enum LevelCatalog {
    static let configurations = TutorialLevelData.levels + ForgetMeNotLevelData.levels

    static func canonicalID(for levelID: LevelID) -> LevelID {
        switch levelID {
        case "home-1", "Level 1.1", "level-1.1", "level-1-1", "1.1":
            return "1.1"
        case "home-2", "Level 1.2", "level-1.2", "level-1-2", "1.2":
            return "1.2"
        case "home-3", "Level 1.3", "level-1.3", "level-1-3", "1.3":
            return "1.3"
        case "home-4", "Level 1.4", "level-1.4", "level-1-4", "1.4":
            return "1.4"
        case "home-5", "Level 1.5", "level-1.5", "level-1-5", "1.5":
            return "1.5"
        default:
            return levelID
        }
    }

    static func configuration(for levelID: LevelID) -> LevelConfiguration? {
        let id = canonicalID(for: levelID)
        return configurations.first { canonicalID(for: $0.id) == id }
    }

    static func goalID(for levelID: LevelID) -> GoalID? {
        let id = canonicalID(for: levelID)
        return FlowerGoalData.goals.first { goal in
            goal.levelIDs.contains { canonicalID(for: $0) == id }
        }?.id
    }

    static func nextTutorialLevel(after levelID: LevelID) -> LevelID? {
        let id = canonicalID(for: levelID)
        guard let currentIndex = TutorialLevelData.levels.firstIndex(where: { canonicalID(for: $0.id) == id }) else {
            return nil
        }

        let nextIndex = TutorialLevelData.levels.index(after: currentIndex)
        guard nextIndex < TutorialLevelData.levels.endIndex else { return nil }
        return TutorialLevelData.levels[nextIndex].id
    }
}

