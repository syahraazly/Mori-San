import SpriteKit

final class PlayerNode: SKNode {
    private let spriteNode: SKSpriteNode
    private let idleAction: SKAction
    private let walkAction: SKAction
    private(set) var isFacingRight = true

    init(player: PlayerModel) {
        let idleTextures = [
            SKTexture(imageNamed: "mori-idle-1"),
            SKTexture(imageNamed: "mori-idle-2")
        ]
        let walkTextures = [
            SKTexture(imageNamed: "mori-walk-1"),
            SKTexture(imageNamed: "mori-walk-2")
        ]

        let idleAnim = SKAction.animate(with: idleTextures, timePerFrame: 0.35)
        idleAction = SKAction.repeatForever(idleAnim)

        let walkAnim = SKAction.animate(with: walkTextures, timePerFrame: 0.18)
        walkAction = SKAction.repeatForever(walkAnim)

        spriteNode = SKSpriteNode(texture: idleTextures[0], size: CGSize(width: 52, height: 52))
        // Mori asset feet are near the bottom of the frame; offset y: -6 rests feet on platform top
        spriteNode.position = CGPoint(x: 0, y: -6)

        super.init()
        name = player.name.lowercased()

        addChild(spriteNode)
        playIdle()
    }

    func playIdle() {
        spriteNode.removeAction(forKey: "moriAnim")
        spriteNode.run(idleAction, withKey: "moriAnim")
    }

    func playWalk(facingRight: Bool? = nil) {
        if let facingRight {
            setFacing(right: facingRight)
        }
        spriteNode.removeAction(forKey: "moriAnim")
        spriteNode.run(walkAction, withKey: "moriAnim")
    }

    func setFacing(right: Bool) {
        isFacingRight = right
        let currentScale = abs(spriteNode.xScale)
        spriteNode.xScale = right ? currentScale : -currentScale
    }

    func face(horizontalDirection: CGFloat) {
        guard abs(horizontalDirection) > 1 else { return }
        setFacing(right: horizontalDirection > 0)
    }

    func playIdleAnimation() {
        playIdle()
    }

    func playWalkAnimation() {
        playWalk()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
