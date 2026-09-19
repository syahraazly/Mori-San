import SwiftUI

final class AppFlowViewModel: ObservableObject {
    enum Screen: Equatable {
        case onboarding
        case storyline
        case map
        case goal(GoalID)
        case gameplay(LevelID)
        case levelTransition(LevelID)
        case congratulations(GoalID)
    }

    @Published private(set) var screen: Screen = .onboarding
    @Published private(set) var progress = GoalProgress()
    private(set) var pendingLevelID: LevelID?
    private(set) var activeGoalID: GoalID?

    func openStoryline() {
        screen = .storyline
    }

    func openMap() {
        activeGoalID = nil
        screen = .map
    }

    func openGoal(_ goalID: GoalID) {
        startChapter(goalID)
    }

    func startChapter(_ goalID: GoalID) {
        guard let goal = FlowerGoalData.goal(for: goalID),
              let firstLevelID = goal.levelIDs.first else { return }
        activeGoalID = goal.id
        startLevel(firstLevelID)
    }

    func startLevel(_ levelID: LevelID) {
        let canonicalID = LevelCatalog.canonicalID(for: levelID)
        guard LevelCatalog.configuration(for: canonicalID) != nil else { return }
        if activeGoalID == nil {
            activeGoalID = LevelCatalog.goalID(for: canonicalID)
        }
        pendingLevelID = nil
        screen = .gameplay(canonicalID)
    }

    func completeLevel(_ levelID: LevelID) {
        let canonicalID = LevelCatalog.canonicalID(for: levelID)
        progress.completeLevel(canonicalID)

        if let nextTutorialLevelID = LevelCatalog.nextTutorialLevel(after: canonicalID) {
            pendingLevelID = nextTutorialLevelID
            screen = .levelTransition(nextTutorialLevelID)
            return
        }

        let targetGoalID = activeGoalID ?? LevelCatalog.goalID(for: canonicalID)
        if let goalID = targetGoalID,
           let goal = FlowerGoalData.goal(for: goalID),
           let currentIndex = goal.levelIDs.firstIndex(where: { LevelCatalog.canonicalID(for: $0) == canonicalID }) {
            let nextIndex = currentIndex + 1
            if nextIndex < goal.levelIDs.count {
                startLevel(goal.levelIDs[nextIndex])
            } else {
                screen = .congratulations(goal.id)
            }
        } else {
            openMap()
        }
    }

    func isLevelUnlocked(_ levelID: LevelID) -> Bool {
        let canonicalID = LevelCatalog.canonicalID(for: levelID)
        guard LevelCatalog.configuration(for: canonicalID) != nil else { return false }

        guard let goalID = LevelCatalog.goalID(for: canonicalID),
              let goal = FlowerGoalData.goal(for: goalID),
              let levelIndex = goal.levelIDs.firstIndex(where: { LevelCatalog.canonicalID(for: $0) == canonicalID }) else {
            return true
        }

        guard levelIndex > 0 else { return true }
        let previousLevelID = goal.levelIDs[levelIndex - 1]
        return isLevelCompleted(previousLevelID)
    }

    func isLevelCompleted(_ levelID: LevelID) -> Bool {
        progress.isLevelCompleted(levelID)
    }

    func isGoalCompleted(_ goalID: GoalID) -> Bool {
        guard let goal = FlowerGoalData.goal(for: goalID) else { return false }
        return goal.levelIDs.allSatisfy(isLevelCompleted)
    }

    func petalCount(for goalID: GoalID) -> Int {
        guard let goal = FlowerGoalData.goal(for: goalID) else { return 0 }
        return progress.petalCount(for: goal)
    }
}
