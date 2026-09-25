import SpriteKit

final class ExitNode: SKShapeNode {
    private let outerRing: SKShapeNode
    private let blackHole: SKSpriteNode
    private let lockIndicator: SKShapeNode
    private let sparkleNode: SKNode
    private(set) var isOpen = true

    init(portalID: String = "exit") {
        outerRing = SKShapeNode(circleOfRadius: 26)
        blackHole = SKSpriteNode(imageNamed: "blackhole")
        lockIndicator = SKShapeNode(circleOfRadius: 5)
        sparkleNode = SKNode()

        super.init()
        name = portalID
        path = CGPath(ellipseIn: CGRect(x: -32, y: -32, width: 64, height: 64), transform: nil)
        fillColor = .clear
        strokeColor = .clear

        outerRing.fillColor = .clear
        outerRing.strokeColor = SKColor(red: 0.38, green: 0.31, blue: 0.52, alpha: 1.0)
        outerRing.lineWidth = 3
        addChild(outerRing)

        blackHole.size = CGSize(width: 56, height: 56)
        addChild(blackHole)

        addSparkles()

        lockIndicator.fillColor = SKColor(red: 0.70, green: 0.62, blue: 0.85, alpha: 0.8)
        lockIndicator.strokeColor = .clear
        lockIndicator.alpha = 0
        addChild(lockIndicator)

        let twitch = SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 1.04, duration: 0.14),
                SKAction.rotate(toAngle: -0.035, duration: 0.07)
            ]),
            SKAction.group([
                SKAction.scale(to: 0.98, duration: 0.10),
                SKAction.rotate(toAngle: 0.035, duration: 0.07)
            ]),
            SKAction.group([
                SKAction.scale(to: 1.0, duration: 0.12),
                SKAction.rotate(toAngle: 0, duration: 0.07)
            ]),
            SKAction.wait(forDuration: 0.55)
        ])
        blackHole.run(.repeatForever(twitch), withKey: "holeTwitch")
    }

    private func addSparkles() {
        let sparklePositions: [CGPoint] = [
            CGPoint(x: -27, y: 23),
            CGPoint(x: 28, y: 17),
            CGPoint(x: -30, y: -18),
            CGPoint(x: 25, y: -25)
        ]

        for (index, position) in sparklePositions.enumerated() {
            let sparkle = SKLabelNode(fontNamed: "AvenirNext-Bold")
            sparkle.text = index.isMultiple(of: 2) ? "✦" : "✧"
            sparkle.fontSize = index.isMultiple(of: 2) ? 11 : 8
            sparkle.fontColor = SKColor(red: 1.0, green: 0.88, blue: 0.55, alpha: 0.95)
            sparkle.horizontalAlignmentMode = .center
            sparkle.verticalAlignmentMode = .center
            sparkle.position = position
            sparkle.alpha = 0.15
            sparkleNode.addChild(sparkle)

            let delay = 0.16 * Double(index)
            sparkle.run(.repeatForever(.sequence([
                .wait(forDuration: delay),
                .group([
                    .fadeAlpha(to: 1.0, duration: 0.22),
                    .scale(to: 1.2, duration: 0.22)
                ]),
                .group([
                    .fadeAlpha(to: 0.15, duration: 0.48),
                    .scale(to: 0.78, duration: 0.48)
                ])
            ])))
        }

        sparkleNode.zPosition = 2
        addChild(sparkleNode)
    }

    func setLocked(_ locked: Bool) {
        isOpen = !locked
        blackHole.texture = SKTexture(imageNamed: locked ? "blackholeLocked" : "blackhole")
        sparkleNode.alpha = locked ? 0.35 : 1.0
        if locked {
            outerRing.strokeColor = SKColor(red: 0.38, green: 0.35, blue: 0.45, alpha: 0.45)
            blackHole.alpha = 1.0
            lockIndicator.alpha = 0
        } else {
            outerRing.strokeColor = SKColor(red: 0.38, green: 0.31, blue: 0.52, alpha: 1.0)
            blackHole.alpha = 1.0
            lockIndicator.alpha = 0
        }
    }

    func unlockWithAnimation() {
        setLocked(false)
        let expand = SKAction.sequence([
            SKAction.scale(to: 1.25, duration: 0.2),
            SKAction.scale(to: 1.0, duration: 0.15)
        ])
        run(expand)
    }

    func playShake() {
        let left = SKAction.moveBy(x: -6, y: 0, duration: 0.05)
        let right = SKAction.moveBy(x: 12, y: 0, duration: 0.05)
        let reset = SKAction.moveBy(x: -6, y: 0, duration: 0.05)
        run(SKAction.sequence([left, right, reset]))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
