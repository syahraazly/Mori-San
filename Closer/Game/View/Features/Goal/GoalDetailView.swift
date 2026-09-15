import SpriteKit

final class GoalDetailView: SKNode {
    init(sceneSize: CGSize, goal: FlowerGoal, isPlayable: (String) -> Bool) {
        super.init()

        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = goal.title
        title.fontSize = 28
        title.fontColor = SKColor(red: 0.22, green: 0.24, blue: 0.30, alpha: 1.0)
        title.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.82)
        addChild(title)

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
            button.fillColor = isPlayable(levelID)
                ? SKColor(red: 0.82, green: 0.42, blue: 0.34, alpha: 1.0)
                : SKColor(red: 0.72, green: 0.68, blue: 0.66, alpha: 1.0)
            button.strokeColor = .white.withAlphaComponent(0.4)
            button.lineWidth = 2
            button.position = CGPoint(x: spacing * CGFloat(index + 1), y: yPosition)
            addChild(button)

            let number = SKLabelNode(fontNamed: "AvenirNext-Bold")
            number.text = "\(index + 1)"
            number.fontSize = 22
            number.verticalAlignmentMode = .center
            number.fontColor = .white
            button.addChild(number)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
