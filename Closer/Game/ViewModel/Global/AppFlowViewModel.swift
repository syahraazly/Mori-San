import SwiftUI

final class AppFlowViewModel: ObservableObject {
    enum Screen: Equatable {
        case onboarding
        case storyline
        case map
        case goal(GoalID)
        case gameplay(LevelID)
        case levelTransition(LevelID)
    }

    @Published private(set) var screen: Screen = .onboarding
    @Published private(set) var progress = GoalProgress()
    private(set) var pendingLevelID: LevelID?

    func openStoryline() {
        screen = .storyline
    }

    func openMap() {
        screen = .map
    }

    func openGoal(_ goalID: GoalID) {
        guard FlowerGoalData.goal(for: goalID) != nil else { return }
        screen = .goal(goalID)
    }

    func startLevel(_ levelID: LevelID) {
        guard LevelCatalog.configuration(for: levelID) != nil else { return }
        pendingLevelID = nil
        screen = .gameplay(levelID)
    }

    func completeLevel(_ levelID: LevelID) {
        progress.completeLevel(levelID)

        if let nextTutorialLevelID = LevelCatalog.nextTutorialLevel(after: levelID) {
            pendingLevelID = nextTutorialLevelID
            screen = .levelTransition(nextTutorialLevelID)
        } else if let goalID = LevelCatalog.goalID(for: levelID) {
            openGoal(goalID)
        } else {
            openMap()
        }
    }

    func isLevelUnlocked(_ levelID: LevelID) -> Bool {
        guard LevelCatalog.configuration(for: levelID) != nil else { return false }

        guard let goalID = LevelCatalog.goalID(for: levelID),
              let goal = FlowerGoalData.goal(for: goalID),
              let levelIndex = goal.levelIDs.firstIndex(of: levelID) else {
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
}
