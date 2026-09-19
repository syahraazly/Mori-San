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

        let ch1 = SKLabelNode(fontNamed: "AvenirNext-Bold")
        ch1.name = "start-chapter-chapter-1"
        ch1.text = "Chapter 1: Forget-Me-Not"
        ch1.fontSize = 20
        ch1.fontColor = SKColor(red: 0.22, green: 0.24, blue: 0.30, alpha: 1.0)
        ch1.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.38)
        addChild(ch1)

        let ch2 = SKLabelNode(fontNamed: "AvenirNext-Medium")
        ch2.name = "start-chapter-chapter-2"
        ch2.text = "Chapter 2: White Lily"
        ch2.fontSize = 18
        ch2.fontColor = SKColor(red: 0.38, green: 0.31, blue: 0.52, alpha: 1.0)
        ch2.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.30)
        addChild(ch2)

        let ch3 = SKLabelNode(fontNamed: "AvenirNext-Medium")
        ch3.name = "start-chapter-chapter-3"
        ch3.text = "Chapter 3: Kamboja Bali"
        ch3.fontSize = 18
        ch3.fontColor = SKColor(red: 0.38, green: 0.31, blue: 0.52, alpha: 1.0)
        ch3.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.22)
        addChild(ch3)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
