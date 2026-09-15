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
    private var perspectiveSwipeStart: CGPoint?

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
        case .chapterTransition:
            renderChapterTransition()
        case .home:
            renderHome()
        case .playing:
            renderLevel()
        }
    }

    private func renderOnboarding() {
        removeAllChildren()

        let onboardingView = OnboardingView(
            sceneSize: size,
            player: TutorialLevelData.closerLevel.player
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

    private func renderChapterTransition() {
        removeAllChildren()
        addChild(ChapterTransitionView(sceneSize: size))
    }

    private func renderHome() {
        removeAllChildren()
        addChild(HomeView(sceneSize: size))
    }

    private func renderLevel() {
        removeAllChildren()
        platformNodes.removeAll()
        draggedPlatform = nil
        moriNode = nil
        exitNode = nil

        let level = viewModel.currentLevel
        for platform in level.platforms {
            let node = PlatformNode(model: platform)
            node.position = position(for: platform)
            addChild(node)
            platformNodes[platform.id] = node
        }

        if level.usesPerspective {
            updatePerspectiveConnections()
        }

        guard let startPlatform = level.platforms.first(where: { $0.id == level.player.startingPlatformID }) else { return }

        let mori = PlayerNode(player: level.player)
        let startPosition = position(for: startPlatform)
        mori.position = CGPoint(x: startPosition.x, y: startPosition.y + 55)
        addChild(mori)
        moriNode = mori

        guard level.interaction != .perspective,
              let exitPlatform = level.platforms.first(where: { $0.id == level.exitPlatformID }) else {
            return
        }

        let exit = ExitNode()
        exit.position = CGPoint(x: 45, y: 55)
        exit.zPosition = 10
        platformNodes[exitPlatform.id]?.addChild(exit)
        exitNode = exit

        if level.interaction == .compact {
            createInstructionLabel()
            updateInstruction()
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        switch viewModel.screen {
        case .onboarding:
            return
        case .levelSelection:
            startSelectedLevel(at: touch.location(in: self))
        case .chapterTransition:
            viewModel.startPreparedLevel()
            renderCurrentScreen()
        case .home:
            startHomeLevel(at: touch.location(in: self))
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

    private func startHomeLevel(at location: CGPoint) {
        var touchedNode: SKNode? = atPoint(location)

        while let node = touchedNode {
            if node.name == "begin-home-1" {
                viewModel.startMainLevelOne()
                renderCurrentScreen()
                return
            }
            if node.name == "begin-home-2" {
                viewModel.startMainLevel(withID: "home-2")
                renderCurrentScreen()
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

        if viewModel.currentLevel.interaction == .perspective {
            if let platform = platformNode(at: touchLocation) {
                moveMoriAcrossPerspectivePath(to: platform.model.id)
                return
            }

            if platformNode(at: touchLocation) == nil,
               exitNode(at: touchLocation) == nil,
               playerNode(at: touchLocation) == nil {
                perspectiveSwipeStart = touchLocation
            }
            return
        }

        if viewModel.currentLevel.interaction == .perspectiveCompact {
            if exitNode(at: touchLocation) != nil {
                moveMori(to: viewModel.currentLevel.exitPlatformID, completesLevel: true)
                return
            }

            if let platform = platformNode(at: touchLocation) {
                if viewModel.canMoveMori(to: platform.model.id) {
                    moveMoriAcrossPerspectivePath(to: platform.model.id)
                    return
                }

                if platform.model.isDraggable {
                    draggedPlatform = platform
                    dragTouchOffsetX = touchLocation.x - platform.position.x
                    didDragPlatform = false
                }
                return
            }

            if playerNode(at: touchLocation) == nil {
                perspectiveSwipeStart = touchLocation
            }
            return
        }

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
        guard viewModel.currentLevel.allowsCompact else { return }
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

        if viewModel.currentLevel.usesPerspective {
            if viewModel.currentLevel.interaction == .perspectiveCompact, didDragPlatform {
                _ = attemptSnapIfNeeded()
                draggedPlatform = nil
                didDragPlatform = false
                return
            }

            if let start = perspectiveSwipeStart, let touch = touches.first {
                let end = touch.location(in: self)
                if abs(end.x - start.x) >= 35 {
                    animatePerspectiveChange()
                }
            }
            perspectiveSwipeStart = nil
            return
        }

        if didDragPlatform {
            _ = attemptSnapIfNeeded()
        }
        draggedPlatform = nil
        didDragPlatform = false
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard viewModel.screen == .playing else { return }
        perspectiveSwipeStart = nil
        draggedPlatform = nil
    }

    private func position(for platform: PlatformModel) -> CGPoint {
        let level = viewModel.currentLevel

        guard level.usesPerspective else {
            return CGPoint(
                x: size.width * platform.horizontalPosition,
                y: size.height * level.platformHeightRatio
            )
        }

        let normalizedPosition: CGPoint?
        switch viewModel.perspectivePOV {
        case .front:
            normalizedPosition = platform.frontPosition
        case .side:
            normalizedPosition = platform.sidePosition
        }

        guard let normalizedPosition else {
            return CGPoint(
                x: size.width * platform.horizontalPosition,
                y: size.height * level.platformHeightRatio
            )
        }

        return CGPoint(
            x: size.width * normalizedPosition.x,
            y: size.height * normalizedPosition.y
        )
    }

    private func animatePerspectiveChange() {
        viewModel.togglePerspectivePOV()
        updatePerspectiveConnections()

        for platform in viewModel.currentLevel.platforms {
            guard let node = platformNodes[platform.id] else { continue }

            let destination = position(for: platform)
            node.removeAction(forKey: "perspectiveMove")
            node.run(
                SKAction.move(to: destination, duration: 0.35),
                withKey: "perspectiveMove"
            )

            if viewModel.moriPlatformID == platform.id {
                let moriDestination = CGPoint(x: destination.x, y: destination.y + 55)
                moriNode?.removeAction(forKey: "perspectiveMove")
                moriNode?.run(
                    SKAction.move(to: moriDestination, duration: 0.35),
                    withKey: "perspectiveMove"
                )
            }
        }
    }

    private func updatePerspectiveConnections() {
        let platforms = viewModel.currentLevel.platforms
        var newConnections: [ConnectionModel] = []
        let maximumGap: CGFloat = 10
        let maximumVerticalDifference: CGFloat = 2

        for firstIndex in platforms.indices {
            for secondIndex in platforms.indices.dropFirst(firstIndex + 1) {
                let firstPlatform = platforms[firstIndex]
                let secondPlatform = platforms[secondIndex]
                let firstPosition = position(for: firstPlatform)
                let secondPosition = position(for: secondPlatform)
                let horizontalDistance = abs(firstPosition.x - secondPosition.x)
                let combinedHalfWidths = (firstPlatform.size.width + secondPlatform.size.width) / 2
                let edgeGap = horizontalDistance - combinedHalfWidths
                let verticalDifference = abs(firstPosition.y - secondPosition.y)

                if abs(edgeGap) <= maximumGap, verticalDifference <= maximumVerticalDifference {
                    newConnections.append(
                        ConnectionModel(
                            firstPlatformID: firstPlatform.id,
                            secondPlatformID: secondPlatform.id
                        )
                    )
                }
            }
        }

        viewModel.setPerspectiveConnections(newConnections)
    }

    private func moveMoriAcrossPerspectivePath(to platformID: String) {
        guard let moriNode,
              !moriNode.hasActions(),
              let path = viewModel.connectionPath(from: viewModel.moriPlatformID, to: platformID) else {
            return
        }

        let actions = path.dropFirst().compactMap { nextPlatformID -> SKAction? in
            guard let platform = platformNodes[nextPlatformID] else { return nil }
            let destination = CGPoint(x: platform.position.x, y: platform.position.y + 55)
            return SKAction.move(to: destination, duration: 0.35)
        }

        guard !actions.isEmpty else { return }

        moriNode.run(SKAction.sequence(actions)) { [weak self] in
            self?.viewModel.moveMori(to: platformID)
        }
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

    private func playerNode(at location: CGPoint) -> PlayerNode? {
        var touchedNode: SKNode? = atPoint(location)

        while let node = touchedNode {
            if let player = node as? PlayerNode {
                return player
            }
            touchedNode = node.parent
        }

        return nil
    }

    private func moveMori(to platformID: String, completesLevel: Bool) {
        guard viewModel.canMoveMori(to: platformID),
              let moriNode,
              moriNode.action(forKey: "moriMove") == nil,
              let path = viewModel.connectionPath(from: viewModel.moriPlatformID, to: platformID) else {
            return
        }

        var previousPosition = moriNode.position
        var movementActions: [SKAction] = []

        for nextPlatformID in path.dropFirst() {
            guard let platform = platformNodes[nextPlatformID] else { return }
            let destination = CGPoint(x: platform.position.x, y: platform.position.y + 55)
            movementActions.append(movementAction(from: previousPosition, to: destination))
            previousPosition = destination
        }

        if completesLevel, let exitNode {
            let exitDestination = exitNode.convert(CGPoint.zero, to: self)
            movementActions.append(movementAction(from: previousPosition, to: exitDestination))
        }

        guard !movementActions.isEmpty else { return }

        movementActions.append(SKAction.run { [weak self] in
            self?.viewModel.moveMori(to: platformID)

            if completesLevel {
                self?.viewModel.markExitReached()
                print("Mori reached the exit")

                if self?.viewModel.prepareNextLevel() == true {
                    self?.showChapterTransition()
                } else {
                    self?.viewModel.showHome()
                    self?.showHomeTransition()
                }
            } else {
                self?.updateInstruction()
            }
        })
        moriNode.run(SKAction.sequence(movementActions), withKey: "moriMove")
    }

    private func movementAction(from start: CGPoint, to destination: CGPoint) -> SKAction {
        let distance = hypot(destination.x - start.x, destination.y - start.y)
        let duration = max(0.15, TimeInterval(distance / 220))
        return SKAction.move(to: destination, duration: duration)
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

    private func showChapterTransition() {
        run(SKAction.fadeOut(withDuration: 0.3)) { [weak self] in
            guard let self else { return }
            self.alpha = 1
            self.renderCurrentScreen()
        }
    }

    private func showHomeTransition() {
        run(SKAction.fadeOut(withDuration: 0.3)) { [weak self] in
            guard let self else { return }
            self.alpha = 1
            self.renderCurrentScreen()
        }
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
            guard abs(draggablePlatform.position.y - target.position.y) <= 2 else { continue }

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
