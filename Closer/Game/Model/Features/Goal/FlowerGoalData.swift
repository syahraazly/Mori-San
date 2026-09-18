struct FlowerGoal {
    let id: GoalID
    let title: String
    let levelIDs: [LevelID]
    let petalAssetName: String

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
    static let forgetMeNot = FlowerGoal(
        id: "chapter-1",
        title: "CHAPTER 1",
        levelIDs: ["1.1", "1.2", "1.3", "1.4", "1.5"],
        petalAssetName: "forget-me-not-petal"
    )

    static let whiteLily = WhiteLilyLevelData.goal

    static let kambojaBali = KambojaBaliLevelData.goal

    static let goals = [forgetMeNot, whiteLily, kambojaBali]

    static func goal(for goalID: GoalID) -> FlowerGoal? {
        goals.first {
            $0.id == goalID
            || ($0.id == "chapter-1" && (goalID == "forget-me-not" || goalID == "1"))
            || ($0.id == "chapter-2" && (goalID == "white-lily" || goalID == "2"))
            || ($0.id == "chapter-3" && (goalID == "kamboja-bali" || goalID == "3"))
        }
    }
}

