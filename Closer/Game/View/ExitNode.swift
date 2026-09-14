import SpriteKit

final class ExitNode: SKShapeNode {
    override init() {
        super.init()
        name = "exit"
        path = CGPath(roundedRect: CGRect(x: -17, y: -25, width: 34, height: 50), cornerWidth: 8, cornerHeight: 8, transform: nil)
        fillColor = SKColor(red: 0.22, green: 0.24, blue: 0.30, alpha: 1.0)
        strokeColor = .white
        lineWidth = 2
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
