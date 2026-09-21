import SpriteKit

final class CongratulationsView: SKNode {
    init(sceneSize: CGSize, goalID: GoalID) {
        super.init()
        name = "congratulations-screen"

        let goal = FlowerGoalData.goal(for: goalID)
        let chapterTitle = goal?.title ?? "CHAPTER COMPLETED"
        let petalAssetName = goal?.petalAssetName ?? "forget-me-not-petal"

        let background = SKShapeNode(rectOf: sceneSize)
        background.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)
        background.fillColor = SKColor(red: 0.95, green: 0.90, blue: 0.82, alpha: 1.0)
        background.strokeColor = .clear
        background.zPosition = -1
        addChild(background)

        let petalSprite = SKSpriteNode(imageNamed: petalAssetName)
        petalSprite.size = CGSize(width: 64, height: 48)
        petalSprite.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.72)
        addChild(petalSprite)

        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = "CONGRATULATIONS!"
        title.fontSize = 28
        title.fontColor = SKColor(red: 0.22, green: 0.24, blue: 0.30, alpha: 1.0)
        title.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.60)
        addChild(title)

        let subtitle = SKLabelNode(fontNamed: "AvenirNext-Medium")
        subtitle.text = "You completed \(chapterTitle)"
        subtitle.fontSize = 18
        subtitle.fontColor = SKColor(red: 0.38, green: 0.31, blue: 0.52, alpha: 1.0)
        subtitle.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.52)
        addChild(subtitle)

        let continueButton = SKLabelNode(fontNamed: "AvenirNext-Bold")
        continueButton.name = "return-to-map"
        continueButton.text = "Tap to Return to Map"
        continueButton.fontSize = 18
        continueButton.fontColor = SKColor(red: 0.82, green: 0.42, blue: 0.34, alpha: 1.0)
        continueButton.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.32)
        addChild(continueButton)

        // Pulsing animation for button
        let scaleUp = SKAction.scale(to: 1.06, duration: 0.7)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.7)
        continueButton.run(SKAction.repeatForever(SKAction.sequence([scaleUp, scaleDown])))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
