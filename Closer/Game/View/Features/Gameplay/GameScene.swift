import SpriteKit

final class GameScene: SKScene {
    private let viewModel = GameViewModel()
    private var platformNodes: [String: PlatformNode] = [:]
    private var draggedPlatform: PlatformNode?
    private var dragTouchOffsetX: CGFloat = 0
    private var didDragPlatform = false
    private var moriNode: PlayerNode?
    private var exitNode: ExitNode?
    private var instructionLabel: SKLabelNode?

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.95, green: 0.90, blue: 0.82, alpha: 1.0)
        renderCurrentScreen()
    }

    private func renderCurrentScreen() {
        switch viewModel.screen {
        case .onboarding:
            renderOnboarding()
        case .levelSelection:
            renderLevelSelection()
        case .playing:
            renderLevel()
        }
    }

    private func renderOnboarding() {
        removeAllChildren()

        let onboardingView = OnboardingView(
            sceneSize: size,
            player: HomeLevelData.closerLevel.player
        )
        addChild(onboardingView)

        onboardingView.play { [weak self] in
            self?.viewModel.showLevelSelection()
            self?.renderCurrentScreen()
        }
    }

    private func renderLevelSelection() {
        removeAllChildren()

        let levelSelectionView = LevelSelectionView(
            sceneSize: size,
            isPlayable: { [weak self] levelID in
                self?.viewModel.isPlayableLevel(levelID) ?? false
            }
        )
        addChild(levelSelectionView)
    }

    private func renderLevel() {
        removeAllChildren()
        platformNodes.removeAll()
        draggedPlatform = nil
        moriNode = nil
        exitNode = nil

        let level = viewModel.currentLevel
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

        createInstructionLabel()
        updateInstruction()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        switch viewModel.screen {
        case .onboarding:
            return
        case .levelSelection:
            startSelectedLevel(at: touch.location(in: self))
        case .playing:
            handleGameplayTouch(touch)
        }
    }

    private func startSelectedLevel(at location: CGPoint) {
        var touchedNode: SKNode? = atPoint(location)

        while let node = touchedNode {
            if let name = node.name, name.hasPrefix("level-") {
                let levelID = String(name.dropFirst("level-".count))
                if viewModel.startLevel(withID: levelID) {
                    renderCurrentScreen()
                }
                return
            }
            touchedNode = node.parent
        }
    }

    private func handleGameplayTouch(_ touch: UITouch) {
        if viewModel.hasReachedExit {
            viewModel.showLevelSelection()
            renderCurrentScreen()
            return
        }

        let touchLocation = touch.location(in: self)

        if exitNode(at: touchLocation) != nil {
            moveMori(to: viewModel.currentLevel.exitPlatformID, completesLevel: true)
            return
        }

        guard let platform = platformNode(at: touchLocation), platform.model.isDraggable else { return }

        if viewModel.canMoveMori(to: platform.model.id) {
            moveMori(to: platform.model.id, completesLevel: false)
            return
        }

        guard !viewModel.isConnected
                || (platform.model.remainsDraggableWhenConnected
                    && !viewModel.areConnected(platform.model.id, viewModel.currentLevel.exitPlatformID)) else {
            return
        }

        draggedPlatform = platform
        dragTouchOffsetX = touchLocation.x - platform.position.x
        didDragPlatform = false
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard viewModel.screen == .playing else { return }
        guard let touch = touches.first, let platform = draggedPlatform else { return }

        let touchLocation = touch.location(in: self)
        let newX = touchLocation.x - dragTouchOffsetX
        let halfPlatformWidth = platform.model.size.width / 2
        let minimumX = halfPlatformWidth + GameConstants.Layout.horizontalMargin
        let maximumX = size.width - halfPlatformWidth - GameConstants.Layout.horizontalMargin
        let screenBoundedX = min(max(newX, minimumX), maximumX)
        let constrainedX = constrainedPlatformX(
            for: platform,
            proposedX: screenBoundedX,
            previousX: platform.position.x
        )
        let horizontalChange = constrainedX - platform.position.x

        if abs(horizontalChange) > 1 {
            didDragPlatform = true
        }

        platform.position.x = constrainedX

        if viewModel.moriPlatformID == platform.model.id {
            moriNode?.position.x += horizontalChange
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard viewModel.screen == .playing else { return }
        if didDragPlatform {
            _ = attemptSnapIfNeeded()
        }
        draggedPlatform = nil
        didDragPlatform = false
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard viewModel.screen == .playing else { return }
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

    private func moveMori(to platformID: String, completesLevel: Bool) {
        guard viewModel.canMoveMori(to: platformID),
              let moriNode,
              !moriNode.hasActions() else { return }

        let destination: CGPoint
        if completesLevel, let exitNode {
            destination = exitNode.convert(CGPoint.zero, to: self)
        } else if let destinationPlatform = platformNodes[platformID] {
            destination = CGPoint(
                x: destinationPlatform.position.x,
                y: destinationPlatform.position.y + 55
            )
        } else {
            return
        }

        let move = SKAction.move(to: destination, duration: 0.6)

        moriNode.run(move) { [weak self] in
            self?.viewModel.moveMori(to: platformID)

            if completesLevel {
                self?.viewModel.markExitReached()
                print("Mori reached the exit")

                if self?.viewModel.advanceToNextLevel() == true {
                    self?.renderLevel()
                } else {
                    self?.showLevelComplete()
                }
            } else {
                self?.updateInstruction()
            }
        }
    }

    private func showLevelComplete() {
        let message = SKLabelNode(fontNamed: "AvenirNext-Bold")
        message.text = "Path restored."
        message.fontSize = 28
        message.fontColor = SKColor(red: 0.22, green: 0.24, blue: 0.30, alpha: 1.0)
        message.position = CGPoint(x: size.width / 2, y: size.height * 0.7)
        message.alpha = 0
        addChild(message)

        message.run(SKAction.fadeIn(withDuration: 0.2))
    }

    @discardableResult
    private func attemptSnapIfNeeded() -> Bool {
        guard let platformB = draggedPlatform else { return false }

        guard let snapTarget = snapTarget(for: platformB) else { return false }
        let snappedPosition = CGPoint(x: snapTarget.position.x, y: platformB.position.y)

        guard viewModel.connect(snapTarget.platform.model.id, to: platformB.model.id) else { return false }

        let move = SKAction.move(to: snappedPosition, duration: GameConstants.Snap.animationDuration)
        let bounce = SKAction.sequence([
            SKAction.scale(to: 1.04, duration: 0.06),
            SKAction.scale(to: 1.0, duration: 0.06)
        ])
        platformB.run(.group([move, bounce]))
        HapticManager.playSnapFeedback()
        updateInstruction()
        return true
    }

    private func constrainedPlatformX(
        for draggablePlatform: PlatformNode,
        proposedX: CGFloat,
        previousX: CGFloat
    ) -> CGFloat {
        var constrainedX = proposedX
        let halfDraggableWidth = draggablePlatform.model.size.width / 2

        for target in platformNodes.values where !target.model.isDraggable {
            if previousX > target.position.x, proposedX < previousX {
                let nearestRightPosition = target.position.x + target.model.size.width / 2 + halfDraggableWidth
                if previousX >= nearestRightPosition, proposedX < nearestRightPosition {
                    constrainedX = max(constrainedX, nearestRightPosition)
                }
            }

            if previousX < target.position.x, proposedX > previousX {
                let nearestLeftPosition = target.position.x - target.model.size.width / 2 - halfDraggableWidth
                if previousX <= nearestLeftPosition, proposedX > nearestLeftPosition {
                    constrainedX = min(constrainedX, nearestLeftPosition)
                }
            }
        }

        return constrainedX
    }

    private func createInstructionLabel() {
        let label = SKLabelNode(fontNamed: "AvenirNext-Medium")
        label.fontSize = 16
        label.fontColor = SKColor(red: 0.22, green: 0.24, blue: 0.30, alpha: 1.0)
        label.horizontalAlignmentMode = .center
        label.position = CGPoint(x: size.width / 2, y: size.height * 0.82)
        label.zPosition = 10
        addChild(label)
        instructionLabel = label
    }

    private func updateInstruction() {
        let level = viewModel.currentLevel
        guard let draggablePlatform = level.platforms.first(where: { $0.isDraggable }) else { return }

        if !viewModel.isConnected {
            instructionLabel?.text = "Drag Platform B to connect the path"
        } else if level.exitPlatformID == draggablePlatform.id {
            instructionLabel?.text = "Tap the black hole"
        } else if viewModel.moriPlatformID == level.player.startingPlatformID {
            instructionLabel?.text = "Tap Platform B to move Mori"
        } else if !viewModel.areConnected(draggablePlatform.id, level.exitPlatformID) {
            instructionLabel?.text = "Drag Platform B to Platform C"
        } else {
            instructionLabel?.text = "Tap the black hole"
        }
    }

    private func snapTarget(for draggablePlatform: PlatformNode) -> (platform: PlatformNode, position: CGPoint)? {
        var nearestTarget: (platform: PlatformNode, position: CGPoint, gap: CGFloat)?

        for target in platformNodes.values where !target.model.isDraggable {
            let gap: CGFloat
            let snappedX: CGFloat

            if draggablePlatform.position.x >= target.position.x {
                let targetRightEdge = target.position.x + target.model.size.width / 2
                let draggableLeftEdge = draggablePlatform.position.x - draggablePlatform.model.size.width / 2
                gap = draggableLeftEdge - targetRightEdge
                snappedX = targetRightEdge + draggablePlatform.model.size.width / 2
            } else {
                let targetLeftEdge = target.position.x - target.model.size.width / 2
                let draggableRightEdge = draggablePlatform.position.x + draggablePlatform.model.size.width / 2
                gap = targetLeftEdge - draggableRightEdge
                snappedX = targetLeftEdge - draggablePlatform.model.size.width / 2
            }

            guard gap >= 0, gap <= GameConstants.Snap.threshold else { continue }

            if nearestTarget == nil || gap < nearestTarget!.gap {
                nearestTarget = (target, CGPoint(x: snappedX, y: draggablePlatform.position.y), gap)
            }
        }

        guard let nearestTarget else { return nil }
        return (nearestTarget.platform, nearestTarget.position)
    }
}
