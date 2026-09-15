import SpriteKit

final class MapView: SKNode {
    init(sceneSize: CGSize) {
        super.init()

        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = "HOME"
        title.fontSize = 34
        title.fontColor = SKColor(red: 0.22, green: 0.24, blue: 0.30, alpha: 1.0)
        title.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.60)
        addChild(title)

        let subtitle = SKLabelNode(fontNamed: "AvenirNext-Medium")
        subtitle.text = "The journey is about to begin."
        subtitle.fontSize = 17
        subtitle.fontColor = SKColor(red: 0.38, green: 0.31, blue: 0.52, alpha: 1.0)
        subtitle.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.50)
        addChild(subtitle)

        let begin = SKLabelNode(fontNamed: "AvenirNext-Bold")
        begin.name = "begin-home-1"
        begin.text = "Begin"
        begin.fontSize = 20
        begin.fontColor = SKColor(red: 0.22, green: 0.24, blue: 0.30, alpha: 1.0)
        begin.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.38)
        addChild(begin)

        let levelTwo = SKLabelNode(fontNamed: "AvenirNext-Medium")
        levelTwo.name = "begin-home-2"
        levelTwo.text = "Level II"
        levelTwo.fontSize = 16
        levelTwo.fontColor = SKColor(red: 0.38, green: 0.31, blue: 0.52, alpha: 1.0)
        levelTwo.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.31)
        addChild(levelTwo)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
