import SpriteKit
import UIKit

final class GameViewController: UIViewController {
    private let appFlow: AppFlowViewModel

    private var hasPresentedScene = false

    init(appFlow: AppFlowViewModel) {
        self.appFlow = appFlow
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = GameView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard !hasPresentedScene else { return }
        guard let gameView = view as? GameView else { return }
        gameView.showGameScene(appFlow: appFlow)
        hasPresentedScene = true
    }
}
