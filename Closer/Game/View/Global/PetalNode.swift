import SpriteKit

final class PetalNode: SKNode {
    let platformID: String
    private let sprite: SKSpriteNode
    private(set) var isCollected = false

    init(platformID: String) {
        self.platformID = platformID
        let texture = SKTexture(imageNamed: "forget-me-not-petal")
        self.sprite = SKSpriteNode(texture: texture, size: CGSize(width: 44, height: 32))
        super.init()

        name = "petal"
        addChild(sprite)

        // Floating/bobbing idle animation
        let floatUp = SKAction.moveBy(x: 0, y: 5, duration: 0.9)
        floatUp.timingMode = .easeInEaseOut
        let floatDown = SKAction.moveBy(x: 0, y: -5, duration: 0.9)
        floatDown.timingMode = .easeInEaseOut
        let bob = SKAction.sequence([floatUp, floatDown])
        sprite.run(SKAction.repeatForever(bob), withKey: "petalBob")

        // Subtle gentle breathing scale
        let scaleUp = SKAction.scale(to: 1.06, duration: 0.9)
        scaleUp.timingMode = .easeInEaseOut
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.9)
        scaleDown.timingMode = .easeInEaseOut
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        sprite.run(SKAction.repeatForever(pulse), withKey: "petalPulse")
    }

    func collect(completion: @escaping () -> Void) {
        guard !isCollected else { return }
        isCollected = true
        sprite.removeAction(forKey: "petalBob")
        sprite.removeAction(forKey: "petalPulse")

        let lift = SKAction.moveBy(x: 0, y: 28, duration: 0.35)
        lift.timingMode = .easeOut
        let scale = SKAction.scale(to: 1.4, duration: 0.35)
        let fade = SKAction.fadeOut(withDuration: 0.35)
        let rotate = SKAction.rotate(byAngle: .pi / 3, duration: 0.35)

        let collectGroup = SKAction.group([lift, scale, fade, rotate])
        sprite.run(collectGroup) { [weak self] in
            self?.removeFromParent()
            completion()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
