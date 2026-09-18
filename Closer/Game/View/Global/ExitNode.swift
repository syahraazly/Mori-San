import SpriteKit

final class ExitNode: SKShapeNode {
    private let outerRing: SKShapeNode
    private let blackHole: SKShapeNode
    private let lockIndicator: SKShapeNode
    private(set) var isOpen = true

    override init() {
        outerRing = SKShapeNode(circleOfRadius: 26)
        blackHole = SKShapeNode(circleOfRadius: 19)
        lockIndicator = SKShapeNode(circleOfRadius: 5)

        super.init()
        name = "exit"
        path = CGPath(ellipseIn: CGRect(x: -32, y: -32, width: 64, height: 64), transform: nil)
        fillColor = .clear
        strokeColor = .clear

        outerRing.fillColor = .clear
        outerRing.strokeColor = SKColor(red: 0.38, green: 0.31, blue: 0.52, alpha: 1.0)
        outerRing.lineWidth = 3
        addChild(outerRing)

        blackHole.fillColor = SKColor(red: 0.08, green: 0.08, blue: 0.14, alpha: 1.0)
        blackHole.strokeColor = SKColor(red: 0.70, green: 0.62, blue: 0.85, alpha: 1.0)
        blackHole.lineWidth = 2
        addChild(blackHole)

        lockIndicator.fillColor = SKColor(red: 0.70, green: 0.62, blue: 0.85, alpha: 0.8)
        lockIndicator.strokeColor = .clear
        lockIndicator.alpha = 0
        addChild(lockIndicator)

        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.08, duration: 0.8),
            SKAction.scale(to: 1.0, duration: 0.8)
        ])
        blackHole.run(.repeatForever(pulse), withKey: "holePulse")
    }

    func setLocked(_ locked: Bool) {
        isOpen = !locked
        if locked {
            outerRing.strokeColor = SKColor(red: 0.38, green: 0.35, blue: 0.45, alpha: 0.45)
            blackHole.strokeColor = SKColor(red: 0.45, green: 0.42, blue: 0.52, alpha: 0.5)
            blackHole.fillColor = SKColor(red: 0.12, green: 0.12, blue: 0.16, alpha: 0.8)
            lockIndicator.alpha = 1.0
        } else {
            outerRing.strokeColor = SKColor(red: 0.38, green: 0.31, blue: 0.52, alpha: 1.0)
            blackHole.strokeColor = SKColor(red: 0.70, green: 0.62, blue: 0.85, alpha: 1.0)
            blackHole.fillColor = SKColor(red: 0.08, green: 0.08, blue: 0.14, alpha: 1.0)
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

