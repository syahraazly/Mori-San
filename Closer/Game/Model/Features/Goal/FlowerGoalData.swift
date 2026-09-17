struct FlowerGoal {
    let id: String
    let title: String
    let levelIDs: [String]
}

enum FlowerGoalData {
    static let forgetMeNot = FlowerGoal(
        id: "forget-me-not",
        title: "FORGET ME NOT",
        levelIDs: ["home-1", "home-2", "home-3", "home-4", "home-5"]
    )

    // Later Roleplay tickets will supply the level IDs for these goals.
    static let whiteLily = FlowerGoal(
        id: "white-lily",
        title: "WHITE LILY",
        levelIDs: []
    )

    static let balineseFrangipani = FlowerGoal(
        id: "balinese-frangipani",
        title: "BALINESE FRANGIPANI",
        levelIDs: []
    )

    static let goals = [forgetMeNot, whiteLily, balineseFrangipani]

    static func goal(for goalID: GoalID) -> FlowerGoal? {
        goals.first { $0.id == goalID }
    }
}
