import SpriteKit

final class ExitNode: SKShapeNode {
    init(portalID: String = "exit") {
        super.init()
        name = portalID
        path = CGPath(ellipseIn: CGRect(x: -32, y: -32, width: 64, height: 64), transform: nil)
        fillColor = .clear
        strokeColor = .clear

        let outerRing = SKShapeNode(circleOfRadius: 26)
        outerRing.fillColor = .clear
        outerRing.strokeColor = SKColor(red: 0.38, green: 0.31, blue: 0.52, alpha: 1.0)
        outerRing.lineWidth = 3
        addChild(outerRing)

        let blackHole = SKShapeNode(circleOfRadius: 19)
        blackHole.fillColor = SKColor(red: 0.08, green: 0.08, blue: 0.14, alpha: 1.0)
        blackHole.strokeColor = SKColor(red: 0.70, green: 0.62, blue: 0.85, alpha: 1.0)
        blackHole.lineWidth = 2
        addChild(blackHole)

        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.08, duration: 0.8),
            SKAction.scale(to: 1.0, duration: 0.8)
        ])
        blackHole.run(.repeatForever(pulse))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
