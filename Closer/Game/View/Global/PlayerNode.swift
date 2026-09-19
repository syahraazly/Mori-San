import SpriteKit

final class PlayerNode: SKShapeNode {
    private let sprite = SKSpriteNode(imageNamed: "mori-idle-1")

    init(player: PlayerModel) {
        super.init()
        name = player.name.lowercased()
        path = CGPath(ellipseIn: CGRect(x: -18, y: -18, width: 36, height: 36), transform: nil)
        fillColor = .clear
        strokeColor = .clear
        sprite.size = CGSize(width: 48, height: 48)
        addChild(sprite)
        playIdleAnimation()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func playIdleAnimation() {
        playAnimation(named: "moriIdle", assetNames: ["mori-idle-1", "mori-idle-2"], frameDuration: 0.45)
    }

    func playWalkAnimation() {
        playAnimation(named: "moriWalk", assetNames: ["mori-walk-1", "mori-walk-2"], frameDuration: 0.16)
    }

    private func playAnimation(named key: String, assetNames: [String], frameDuration: TimeInterval) {
        sprite.removeAllActions()
        let textures = assetNames.map(SKTexture.init(imageNamed:))
        sprite.run(.repeatForever(.animate(with: textures, timePerFrame: frameDuration)), withKey: key)
    }
}
