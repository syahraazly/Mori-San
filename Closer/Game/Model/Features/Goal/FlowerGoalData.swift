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
}
