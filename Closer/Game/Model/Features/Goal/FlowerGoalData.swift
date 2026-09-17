struct FlowerGoal {
    let id: GoalID
    let title: String
    let levelIDs: [LevelID]

    var totalPetals: Int {
        levelIDs.count
    }

    func completedPetals(with progress: GoalProgress) -> Int {
        progress.petalCount(for: self)
    }

    func progressText(with progress: GoalProgress) -> String {
        "\(completedPetals(with: progress))/\(totalPetals) petals"
    }

    func isCompleted(with progress: GoalProgress) -> Bool {
        !levelIDs.isEmpty && levelIDs.allSatisfy { progress.isLevelCompleted($0) }
    }
}

enum FlowerGoalData {
    static let forgetMeNot = ForgetMeNotLevelData.goal

    static let goals = [forgetMeNot]

    static func goal(for goalID: GoalID) -> FlowerGoal? {
        goals.first { $0.id == goalID }
    }
}

