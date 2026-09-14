import SpriteKit

final class GameScene: SKScene {
    private let viewModel = GameViewModel()
    private var platformNodes: [String: PlatformNode] = [:]
    private var draggedPlatform: PlatformNode?
    private var dragTouchOffsetX: CGFloat = 0
    private var moriNode: PlayerNode?
    private var exitNode: ExitNode?

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.95, green: 0.90, blue: 0.82, alpha: 1.0)
        renderLevel()
    }

    private func renderLevel() {
        let level = viewModel.level
        let platformY = size.height * level.platformHeightRatio

        for platform in level.platforms {
            let node = PlatformNode(model: platform)
            node.position = CGPoint(x: size.width * platform.horizontalPosition, y: platformY)
            addChild(node)
            platformNodes[platform.id] = node
        }

        guard let startPlatform = level.platforms.first(where: { $0.id == level.player.startingPlatformID }),
              let exitPlatform = level.platforms.first(where: { $0.id == level.exitPlatformID }) else { return }

        let mori = PlayerNode(player: level.player)
        mori.position = CGPoint(x: size.width * startPlatform.horizontalPosition, y: platformY + 55)
        addChild(mori)
        moriNode = mori

        let exit = ExitNode()
        exit.position = CGPoint(x: 45, y: 55)
        platformNodes[exitPlatform.id]?.addChild(exit)
        exitNode = exit
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        let touchLocation = touch.location(in: self)

        if exitNode(at: touchLocation) != nil {
            moveMoriToExitIfAllowed()
            return
        }

        guard !viewModel.isConnected else { return }
        guard let platform = platformNode(at: touchLocation), platform.model.isDraggable else { return }

        draggedPlatform = platform
        dragTouchOffsetX = touchLocation.x - platform.position.x
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let platform = draggedPlatform else { return }

        let touchLocation = touch.location(in: self)
        platform.position.x = touchLocation.x - dragTouchOffsetX
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if draggedPlatform != nil {
            attemptSnapIfNeeded()
        }
        draggedPlatform = nil
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        draggedPlatform = nil
    }

    private func platformNode(at location: CGPoint) -> PlatformNode? {
        var touchedNode: SKNode? = atPoint(location)

        while let node = touchedNode {
            if let platform = node as? PlatformNode {
                return platform
            }
            touchedNode = node.parent
        }

        return nil
    }

    private func exitNode(at location: CGPoint) -> ExitNode? {
        var touchedNode: SKNode? = atPoint(location)

        while let node = touchedNode {
            if let exit = node as? ExitNode {
                return exit
            }
            touchedNode = node.parent
        }

        return nil
    }

    private func moveMoriToExitIfAllowed() {
        guard viewModel.canMoveMoriToExit(),
              let moriNode,
              let exitNode,
              !moriNode.hasActions() else { return }

        let exitPositionInScene = exitNode.convert(CGPoint.zero, to: self)
        let move = SKAction.move(to: exitPositionInScene, duration: 0.6)

        moriNode.run(move) { [weak self] in
            self?.viewModel.markExitReached()
            print("Mori reached the exit")
        }
    }

    private func attemptSnapIfNeeded() {
        guard !viewModel.isConnected,
              let platformA = platformNodes["platformA"],
              let platformB = platformNodes["platformB"] else { return }

        let platformARightEdge = platformA.position.x + platformA.model.size.width / 2
        let platformBLeftEdge = platformB.position.x - platformB.model.size.width / 2
        let horizontalGap = platformBLeftEdge - platformARightEdge

        guard horizontalGap >= 0, horizontalGap <= GameConstants.Snap.threshold else { return }

        let snappedX = platformARightEdge + platformB.model.size.width / 2
        let snappedPosition = CGPoint(x: snappedX, y: platformB.position.y)

        guard viewModel.connect(platformA.model.id, to: platformB.model.id) else { return }

        let move = SKAction.move(to: snappedPosition, duration: GameConstants.Snap.animationDuration)
        let bounce = SKAction.sequence([
            SKAction.scale(to: 1.04, duration: 0.06),
            SKAction.scale(to: 1.0, duration: 0.06)
        ])
        platformB.run(.group([move, bounce]))
        HapticManager.playSnapFeedback()
    }
}
