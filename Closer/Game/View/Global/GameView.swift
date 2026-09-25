import SpriteKit

final class GameView: SKView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(red: 0.95, green: 0.90, blue: 0.82, alpha: 1.0)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = UIColor(red: 0.95, green: 0.90, blue: 0.82, alpha: 1.0)
    }

    func showGameScene(appFlow: AppFlowViewModel) {
        let scene = GameScene(size: bounds.size, appFlow: appFlow)
        scene.scaleMode = .resizeFill
        presentScene(scene)
    }
}
