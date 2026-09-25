import SpriteKit

final class GoalDetailView: SKNode {
    private(set) var progressLabel: SKLabelNode?

    init(
        sceneSize: CGSize,
        goal: FlowerGoal,
        progress: GoalProgress? = nil,
        isPlayable: (String) -> Bool
    ) {
        super.init()

        let title = SKLabelNode(fontNamed: "Montserrat-Bold")
        title.text = goal.title
        title.fontSize = 28
        title.fontColor = SKColor(red: 0.22, green: 0.24, blue: 0.30, alpha: 1.0)
        title.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.82)
        addChild(title)

        let completedPetals = progress?.petalCount(for: goal) ?? 0
        let totalPetals = goal.totalPetals
        let progressNode = SKLabelNode(fontNamed: "Montserrat-Medium")
        progressNode.name = "goal-progress-label"
        progressNode.text = "\(completedPetals)/\(totalPetals) petals"
        progressNode.fontSize = 18
        progressNode.fontColor = SKColor(red: 0.38, green: 0.31, blue: 0.52, alpha: 1.0)
        progressNode.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.74)
        addChild(progressNode)
        self.progressLabel = progressNode

        let backButton = SKShapeNode(rectOf: CGSize(width: 104, height: 42), cornerRadius: 14)
        backButton.name = "back-to-map"
        backButton.fillColor = SKColor(red: 0.38, green: 0.31, blue: 0.52, alpha: 1.0)
        backButton.strokeColor = .white.withAlphaComponent(0.35)
        backButton.lineWidth = 2
        backButton.position = CGPoint(x: 68, y: sceneSize.height - 42)
        addChild(backButton)

        let backIconImage = UIImage(
            systemName: "chevron.left",
            withConfiguration: UIImage.SymbolConfiguration(
                pointSize: 16,
                weight: .bold
            )
        )!

        let backIcon = SKSpriteNode(texture: SKTexture(image: backIconImage))
        backIcon.position = CGPoint(x: -20, y: 0)
        backButton.addChild(backIcon)

        let backLabel = SKLabelNode(fontNamed: "Montserrat-Bold")
        backLabel.text = "Map"
        backLabel.fontSize = 16
        backLabel.verticalAlignmentMode = .center
        backLabel.fontColor = .white
        backLabel.position = CGPoint(x: 4, y: 0)
        backButton.addChild(backLabel)
        
        addLevelCategory(
            levelIDs: goal.levelIDs,
            yPosition: sceneSize.height * 0.50,
            sceneWidth: sceneSize.width,
            isPlayable: isPlayable
        )
    }

    private func addLevelCategory(
        levelIDs: [String],
        yPosition: CGFloat,
        sceneWidth: CGFloat,
        isPlayable: (String) -> Bool
    ) {
        let spacing = sceneWidth / CGFloat(levelIDs.count + 1)
        for (index, levelID) in levelIDs.enumerated() {
            let button = SKShapeNode(rectOf: CGSize(width: 62, height: 62), cornerRadius: 14)
            button.name = "level-\(levelID)"
            let playable = isPlayable(levelID)
            button.fillColor = playable
                ? SKColor(red: 0.82, green: 0.42, blue: 0.34, alpha: 1.0)
                : SKColor(red: 0.72, green: 0.68, blue: 0.66, alpha: 1.0)
            button.strokeColor = .white.withAlphaComponent(0.4)
            button.lineWidth = 2
            button.position = CGPoint(x: spacing * CGFloat(index + 1), y: yPosition)
            addChild(button)

            let number = SKLabelNode(fontNamed: "Montserrat-Bold")
            number.text = levelID
            number.fontSize = 18
            number.verticalAlignmentMode = .center
            number.fontColor = .white
            button.addChild(number)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
