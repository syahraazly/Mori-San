import SpriteKit

final class OnboardingView: SKNode {
    private let mori: PlayerNode
    private let blackHole: ExitNode

    init(sceneSize: CGSize, player: PlayerModel) {
        mori = PlayerNode(player: player)
        blackHole = ExitNode()
        super.init()

        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = "MORI"
        title.fontSize = 42
        title.fontColor = SKColor(red: 0.22, green: 0.24, blue: 0.30, alpha: 1.0)
        title.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.78)
        addChild(title)

        blackHole.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.40)
        addChild(blackHole)

        mori.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.62)
        addChild(mori)
    }

    func play(completion: @escaping () -> Void) {
        let fall = SKAction.move(to: blackHole.position, duration: 1.0)
        let disappear = SKAction.group([
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.scale(to: 0.2, duration: 0.2)
        ])
        mori.run(.sequence([fall, disappear]), completion: completion)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
