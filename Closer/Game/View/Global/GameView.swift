import SpriteKit

final class GameView: SKView {
    func showGameScene(appFlow: AppFlowViewModel) {
        let scene = GameScene(size: bounds.size, appFlow: appFlow)
        scene.scaleMode = .resizeFill
        presentScene(scene)
    }
}
