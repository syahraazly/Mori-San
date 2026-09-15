import SpriteKit

final class ChapterTransitionView: SKNode {
    init(sceneSize: CGSize) {
        super.init()

        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = "II — BETWEEN"
        title.fontSize = 30
        title.fontColor = SKColor(red: 0.22, green: 0.24, blue: 0.30, alpha: 1.0)
        title.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.72)
        addChild(title)

        let lineWidth = sceneSize.width * 0.48
        let progressLine = SKShapeNode(rectOf: CGSize(width: lineWidth, height: 4), cornerRadius: 2)
        progressLine.fillColor = SKColor(red: 0.68, green: 0.61, blue: 0.75, alpha: 1.0)
        progressLine.strokeColor = .clear
        progressLine.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.48)
        addChild(progressLine)

        let startPoint = SKShapeNode(circleOfRadius: 10)
        startPoint.fillColor = SKColor(red: 0.82, green: 0.42, blue: 0.34, alpha: 1.0)
        startPoint.strokeColor = .clear
        startPoint.position = CGPoint(x: sceneSize.width / 2 - lineWidth / 2, y: sceneSize.height * 0.48)
        addChild(startPoint)

        let destinationPoint = SKShapeNode(circleOfRadius: 10)
        destinationPoint.fillColor = SKColor(red: 0.38, green: 0.31, blue: 0.52, alpha: 1.0)
        destinationPoint.strokeColor = .clear
        destinationPoint.position = CGPoint(x: sceneSize.width / 2 + lineWidth / 2, y: sceneSize.height * 0.48)
        addChild(destinationPoint)

        let mori = PlayerNode(player: TutorialLevelData.closerLevel.player)
        mori.setScale(0.65)
        mori.position = startPoint.position
        addChild(mori)
        mori.run(SKAction.move(to: destinationPoint.position, duration: 0.6))

        let continueLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        continueLabel.text = "Tap to continue"
        continueLabel.fontSize = 16
        continueLabel.fontColor = SKColor(red: 0.22, green: 0.24, blue: 0.30, alpha: 0.8)
        continueLabel.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.26)
        addChild(continueLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
