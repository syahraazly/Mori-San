import SwiftUI

final class AppFlowViewModel: ObservableObject {
    enum Screen: Equatable {
        case splash
        case onboarding
        case storyline
        case map
        case goal(GoalID)
        case gameplay(LevelID)
        case levelTransition(LevelID)
        case flowerReveal(GoalID)
        case congratulations(GoalID)
    }

    @Published private(set) var screen: Screen = .splash
    @Published private(set) var progress = GoalProgress()
    private(set) var pendingLevelID: LevelID?
    private(set) var activeGoalID: GoalID?

    func openSplash() {
        screen = .splash
    }

    func openStoryline() {
        screen = .storyline
    }

    func startGameplay() {
        if !isLevelCompleted("1.0") {
            activeGoalID = "forget-me-not"
            startLevel("1.0")
        } else if let uncompleted = FlowerGoalData.goal(for: "forget-me-not")?.levelIDs.first(where: { !isLevelCompleted($0) }) {
            activeGoalID = "forget-me-not"
            startLevel(uncompleted)
        } else {
            openChapter("forget-me-not")
        }
    }

    // MARK: - Chapter Navigation

    func openMap() {
        activeGoalID = nil
        pendingLevelID = nil
        screen = .map
    }

    func openGoal(_ goalID: GoalID) {
        guard FlowerGoalData.goal(for: goalID) != nil else { return }
        activeGoalID = goalID
        screen = .goal(goalID)
    }

    func openChapter(_ chapterID: GoalID) {
        guard isChapterUnlocked(chapterID) else { return }

        // Chapter 1.0 is a playable introduction and is intentionally absent
        // from the chapter progression nodes.
        if chapterID == "forget-me-not", !isLevelCompleted("1.0") {
            activeGoalID = chapterID
            startLevel("1.0")
            return
        }

        openGoal(chapterID)
    }

    func startLevel(_ levelID: LevelID) {
        let canonicalID = LevelCatalog.canonicalID(for: levelID)
        guard LevelCatalog.configuration(for: canonicalID) != nil else { return }

        if canonicalID == "1.1", !isLevelCompleted("1.0") {
            activeGoalID = "forget-me-not"
            startLevel("1.0")
            return
        }

        if activeGoalID == nil {
            activeGoalID = LevelCatalog.goalID(for: canonicalID)
        }
        pendingLevelID = nil
        screen = .gameplay(canonicalID)
    }

    // MARK: - Level Completion Transition

    func completeLevel(_ levelID: LevelID) {
        let canonicalID = LevelCatalog.canonicalID(for: levelID)
        progress.completeLevel(canonicalID)

        if let nextTutorialLevelID = LevelCatalog.nextTutorialLevel(after: canonicalID) {
            pendingLevelID = nextTutorialLevelID
            screen = .levelTransition(nextTutorialLevelID)
            return
        }

        let goalID = activeGoalID ?? LevelCatalog.goalID(for: canonicalID)
        if let goalID,
           let goal = FlowerGoalData.goal(for: goalID),
           let currentIndex = goal.levelIDs.firstIndex(where: {
               LevelCatalog.canonicalID(for: $0) == canonicalID
           }),
           currentIndex == goal.levelIDs.index(before: goal.levelIDs.endIndex) {
            screen = .flowerReveal(goalID)
        } else if let goalID {
            openGoal(goalID)
        } else {
            openMap()
        }
    }

    func claimPetal(for levelID: LevelID) {
        progress.claimPetal(for: levelID)
    }

    // MARK: - Chapter Completion / Flower Reveal

    func showCongratulations(for goalID: GoalID) {
        screen = .congratulations(goalID)
    }

    func nextChapterGoalID(after goalID: GoalID) -> GoalID? {
        guard let index = FlowerGoalData.goals.firstIndex(where: { $0.id == goalID }) else {
            return nil
        }
        let nextIndex = FlowerGoalData.goals.index(after: index)
        guard nextIndex < FlowerGoalData.goals.endIndex else { return nil }
        return FlowerGoalData.goals[nextIndex].id
    }

    func startNextChapter(after goalID: GoalID) {
        guard let nextGoalID = nextChapterGoalID(after: goalID) else {
            openMap()
            return
        }
        openGoal(nextGoalID)
    }

    func restartChapter(_ goalID: GoalID) {
        openGoal(goalID)
    }

    func isLevelUnlocked(_ levelID: LevelID) -> Bool {
        let canonicalID = LevelCatalog.canonicalID(for: levelID)
        guard LevelCatalog.configuration(for: canonicalID) != nil else { return false }

        guard let goalID = LevelCatalog.goalID(for: canonicalID),
              let goal = FlowerGoalData.goal(for: goalID),
              let levelIndex = goal.levelIDs.firstIndex(where: {
                  LevelCatalog.canonicalID(for: $0) == canonicalID
              }) else {
            return true
        }

        guard levelIndex > 0 else { return true }
        let previousLevelID = goal.levelIDs[levelIndex - 1]
        return isLevelCompleted(previousLevelID)
    }

    func isLevelCompleted(_ levelID: LevelID) -> Bool {
        progress.isLevelCompleted(LevelCatalog.canonicalID(for: levelID))
    }

    func isGoalCompleted(_ goalID: GoalID) -> Bool {
        guard let goal = FlowerGoalData.goal(for: goalID) else { return false }
        guard !goal.levelIDs.isEmpty else { return false }
        return goal.levelIDs.allSatisfy(isLevelCompleted)
    }

    func isChapterUnlocked(_ chapterID: GoalID) -> Bool {
        guard let goal = FlowerGoalData.goal(for: chapterID),
              let index = FlowerGoalData.goals.firstIndex(where: { $0.id == goal.id }) else {
            return false
        }
        guard index > FlowerGoalData.goals.startIndex else { return true }
        let previousGoal = FlowerGoalData.goals[FlowerGoalData.goals.index(before: index)]
        return isGoalCompleted(previousGoal.id)
    }

    func isChapterCompleted(_ chapterID: GoalID) -> Bool {
        isGoalCompleted(chapterID)
    }
}
