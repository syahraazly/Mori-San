import SpriteKit

final class PlayerNode: SKShapeNode {
    init(player: PlayerModel) {
        super.init()
        name = player.name.lowercased()
        path = CGPath(ellipseIn: CGRect(x: -18, y: -18, width: 36, height: 36), transform: nil)
        fillColor = .white
        strokeColor = SKColor(red: 0.22, green: 0.24, blue: 0.30, alpha: 1.0)
        lineWidth = 3
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
