import SpriteKit

final class GameView: SKView {
    func showGameScene() {
        let scene = GameScene(size: bounds.size)
        scene.scaleMode = .resizeFill
        presentScene(scene)
    }
}
