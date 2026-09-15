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
        guard goalID == FlowerGoalData.forgetMeNot.id else { return }
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
              goalID == FlowerGoalData.forgetMeNot.id,
              let levelIndex = FlowerGoalData.forgetMeNot.levelIDs.firstIndex(of: levelID) else {
            return true
        }

        guard levelIndex > 0 else { return true }
        let previousLevelID = FlowerGoalData.forgetMeNot.levelIDs[levelIndex - 1]
        return isLevelCompleted(previousLevelID)
    }

    func isLevelCompleted(_ levelID: LevelID) -> Bool {
        progress.isLevelCompleted(levelID)
    }

    func isGoalCompleted(_ goalID: GoalID) -> Bool {
        guard goalID == FlowerGoalData.forgetMeNot.id else { return false }
        return FlowerGoalData.forgetMeNot.levelIDs.allSatisfy(isLevelCompleted)
    }
}
