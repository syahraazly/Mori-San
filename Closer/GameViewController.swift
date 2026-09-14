import SpriteKit
import UIKit

final class GameViewController: UIViewController {

    private var hasPresentedScene = false

    override func loadView() {
        view = GameView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard !hasPresentedScene else { return }
        guard let gameView = view as? GameView else { return }
        gameView.showGameScene()
        hasPresentedScene = true
    }
}
