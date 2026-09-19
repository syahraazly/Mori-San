import SpriteKit

final class GameScene: SKScene {
    private let appFlow: AppFlowViewModel
    private let viewModel: GameViewModel
    private var renderedScreen: AppFlowViewModel.Screen?
    private var platformNodes: [String: PlatformNode] = [:]
    private var draggedPlatform: PlatformNode?
    private var dragTouchOffsetX: CGFloat = 0
    private var didDragPlatform = false
    private var moriNode: PlayerNode?
    private var portalNodes: [String: ExitNode] = [:]
    private var instructionLabel: SKLabelNode?
    private var perspectiveSwipeStart: CGPoint?
    private var isRestartingLevel = false
    private var mapView: MapView?

    init(size: CGSize, appFlow: AppFlowViewModel) {
        self.appFlow = appFlow
        viewModel = GameViewModel(initialLevel: TutorialLevelData.closerLevel)
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.95, green: 0.90, blue: 0.82, alpha: 1.0)
        renderCurrentScreen()
    }

    override func update(_ currentTime: TimeInterval) {
        renderCurrentScreen()

        guard case .gameplay = appFlow.screen,
              !isRestartingLevel,
              let moriNode,
              !isMoriSupported(moriNode) else {
            return
        }

        handleFall()
    }

    private func renderCurrentScreen() {
        guard renderedScreen != appFlow.screen else { return }
        renderedScreen = appFlow.screen

        switch appFlow.screen {
        case .onboarding, .storyline:
            removeAllChildren()
        case .map:
            renderMap()
        case .goal(let goalID):
            renderGoal(goalID)
        case .levelTransition:
            renderChapterTransition()
        case .gameplay(let levelID):
            guard let configuration = LevelCatalog.configuration(for: levelID) else { return }
            viewModel.loadLevel(configuration)
            renderLevel()
        }
    }

    private func renderGoal(_ goalID: GoalID) {
        removeAllChildren()
        guard let goal = FlowerGoalData.goal(for: goalID) else { return }

        let goalDetailView = GoalDetailView(
            sceneSize: size,
            goal: goal,
            isPlayable: { [weak self] levelID in
                self?.appFlow.isLevelUnlocked(levelID) ?? false
            }
        )
        addChild(goalDetailView)
    }

    private func renderChapterTransition() {
        removeAllChildren()
        addChild(ChapterTransitionView(sceneSize: size))
    }

    private func renderMap() {
        removeAllChildren()
        let mapViewModel = MapViewModel(
            isChapterUnlocked: { [weak self] chapterID in
                self?.appFlow.isChapterUnlocked(chapterID) ?? false
            },
            isChapterCompleted: { [weak self] chapterID in
                self?.appFlow.isChapterCompleted(chapterID) ?? false
            }
        )
        let map = MapView(
            sceneSize: size,
            viewModel: mapViewModel,
            onSelectChapter: { [weak self] chapterID in
                self?.appFlow.openChapter(chapterID)
            }
        )
        addChild(map)
        mapView = map
    }

    private func renderLevel() {
        removeAllChildren()
        platformNodes.removeAll()
        portalNodes.removeAll()
        draggedPlatform = nil
        moriNode = nil

        let level = viewModel.currentLevel
        addBackground(for: level)
        for platform in level.platforms {
            let node = PlatformNode(model: platform)
            node.position = position(for: platform)
            addChild(node)
            platformNodes[platform.id] = node
        }

        viewModel.setConnections(allowedConnections(from: level.initialConnections))

        if level.usesPerspective, level.usesProximityConnections {
            updatePerspectiveConnections()
        }

        guard let startPlatform = level.platforms.first(where: { $0.id == level.player.startingPlatformID }) else { return }

        let mori = PlayerNode(player: level.player)
        let startPosition = position(for: startPlatform)
        mori.position = moriStandingPosition(
            for: startPlatform,
            at: startPosition,
            offset: level.player.startingOffset
        )
        addChild(mori)
        moriNode = mori

        for portal in level.portalConfigurations {
            guard let portalPlatform = platformNodes[portal.platformID] else { continue }

            let portalNode = ExitNode(portalID: portal.id)
            portalNode.position = portalPosition(for: portal, on: portalPlatform)
            portalNode.zPosition = 10
            portalPlatform.addChild(portalNode)
            portalNodes[portal.id] = portalNode
        }

        if level.interaction == .compact {
            createInstructionLabel()
            updateInstruction()
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        switch appFlow.screen {
        case .goal:
            startSelectedLevel(at: touch.location(in: self))
        case .levelTransition:
            if let pendingLevelID = appFlow.pendingLevelID {
                appFlow.startLevel(pendingLevelID)
            }
            renderCurrentScreen()
        case .map:
            mapView?.handleTouchBegan(at: touch.location(in: self))
        case .gameplay:
            handleGameplayTouch(touch)
        case .onboarding, .storyline:
            return
        }
    }

    private func startSelectedLevel(at location: CGPoint) {
        var touchedNode: SKNode? = atPoint(location)

        while let node = touchedNode {
            if let name = node.name, name.hasPrefix("level-") {
                let levelID = String(name.dropFirst("level-".count))
                appFlow.startLevel(levelID)
                return
            }
            touchedNode = node.parent
        }
    }

    private func handleGameplayTouch(_ touch: UITouch) {
        if viewModel.hasReachedExit {
            return
        }

        let touchLocation = touch.location(in: self)

        if let portal = portalConfiguration(at: touchLocation) {
            enter(portal: portal)
            return
        }

        if viewModel.currentLevel.interaction == .perspective {
            if let platform = platformNode(at: touchLocation) {
                moveMoriAcrossPerspectivePath(to: platform.model.id)
                return
            }

            if platformNode(at: touchLocation) == nil,
               portalConfiguration(at: touchLocation) == nil,
               playerNode(at: touchLocation) == nil {
                perspectiveSwipeStart = touchLocation
            }
            return
        }

        if viewModel.currentLevel.interaction == .perspectiveCompact {
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

        guard let platform = platformNode(at: touchLocation), platform.model.isDraggable else { return }

        if viewModel.canMoveMori(to: platform.model.id) {
            moveMori(to: platform.model.id)
            return
        }

        guard !viewModel.isConnected
                || (platform.model.remainsDraggableWhenConnected
                    && !viewModel.areConnected(
                        platform.model.id,
                        viewModel.currentLevel.portalConfigurations.first?.platformID ?? ""
                    )) else {
            return
        }

        draggedPlatform = platform
        dragTouchOffsetX = touchLocation.x - platform.position.x
        didDragPlatform = false
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if case .map = appFlow.screen, let touch = touches.first {
            mapView?.handleTouchMoved(to: touch.location(in: self))
            return
        }

        guard case .gameplay = appFlow.screen else { return }
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
        if case .map = appFlow.screen, let touch = touches.first {
            mapView?.handleTouchEnded(at: touch.location(in: self))
            return
        }

        guard case .gameplay = appFlow.screen else { return }

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
        guard case .gameplay = appFlow.screen else { return }
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

    private func moriStandingPosition(
        for platform: PlatformModel,
        at position: CGPoint,
        offset: CGPoint = .zero
    ) -> CGPoint {
        CGPoint(
            x: position.x + platform.walkableSurfaceOffset.x + offset.x,
            y: position.y + platform.walkableSurfaceOffset.y + 33 + offset.y
        )
    }

    private func moriStandingPosition(
        on platform: PlatformNode,
        offset: CGPoint = .zero
    ) -> CGPoint {
        moriStandingPosition(for: platform.model, at: platform.position, offset: offset)
    }

    private func walkableSurfacePosition(for platform: PlatformModel, at position: CGPoint) -> CGPoint {
        CGPoint(
            x: position.x + platform.walkableSurfaceOffset.x,
            y: position.y + platform.walkableSurfaceOffset.y
        )
    }

    private func walkableSurfacePosition(on platform: PlatformNode) -> CGPoint {
        walkableSurfacePosition(for: platform.model, at: platform.position)
    }

    private func portalPosition(for portal: PortalConfiguration, on platform: PlatformNode) -> CGPoint {
        switch portal.anchor {
        case .platformCenter:
            return portal.offset
        case .walkableSurface:
            return CGPoint(
                x: platform.model.walkableSurfaceOffset.x + portal.offset.x,
                y: platform.model.walkableSurfaceOffset.y + portal.offset.y
            )
        }
    }

    private func allowedConnections(from candidates: [ConnectionModel]) -> [ConnectionModel] {
        candidates.filter { connection in
            guard let firstPlatform = viewModel.currentLevel.platforms.first(where: {
                $0.id == connection.firstPlatformID
            }),
            let secondPlatform = viewModel.currentLevel.platforms.first(where: {
                $0.id == connection.secondPlatformID
            }) else {
                return false
            }

            return connectionIsAllowed(
                between: firstPlatform,
                at: position(for: firstPlatform),
                and: secondPlatform,
                at: position(for: secondPlatform)
            )
        }
    }

    private func connectionIsAllowed(
        between first: PlatformModel,
        at firstPosition: CGPoint,
        and second: PlatformModel,
        at secondPosition: CGPoint
    ) -> Bool {
        guard first.isWalkable, second.isWalkable else { return false }

        let firstEdge: PlatformEdge
        let secondEdge: PlatformEdge
        if walkableSurfacePosition(for: first, at: firstPosition).x
            <= walkableSurfacePosition(for: second, at: secondPosition).x {
            firstEdge = .right
            secondEdge = .left
        } else {
            firstEdge = .left
            secondEdge = .right
        }

        return !first.blockedConnectionEdges.contains(firstEdge)
            && !second.blockedConnectionEdges.contains(secondEdge)
    }

    private func connectionIsAllowed(between first: PlatformNode, and second: PlatformNode) -> Bool {
        connectionIsAllowed(
            between: first.model,
            at: first.position,
            and: second.model,
            at: second.position
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
                let moriDestination = moriStandingPosition(for: platform, at: destination)
                moriNode?.removeAction(forKey: "perspectiveMove")
                moriNode?.run(
                    SKAction.move(to: moriDestination, duration: 0.35),
                    withKey: "perspectiveMove"
                )
            }
        }
    }

    private func updatePerspectiveConnections() {
        guard viewModel.currentLevel.usesProximityConnections else { return }

        let platforms = viewModel.currentLevel.platforms.filter(\.isWalkable)
        var newConnections: [ConnectionModel] = []
        let maximumGap: CGFloat = 10
        let maximumVerticalDifference: CGFloat = 2

        for firstIndex in platforms.indices {
            for secondIndex in platforms.indices.dropFirst(firstIndex + 1) {
                let firstPlatform = platforms[firstIndex]
                let secondPlatform = platforms[secondIndex]
                let firstPosition = walkableSurfacePosition(
                    for: firstPlatform,
                    at: position(for: firstPlatform)
                )
                let secondPosition = walkableSurfacePosition(
                    for: secondPlatform,
                    at: position(for: secondPlatform)
                )
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

        viewModel.setConnections(
            allowedConnections(from: viewModel.currentLevel.initialConnections + newConnections)
        )
    }

    private func moveMoriAcrossPerspectivePath(to platformID: String) {
        guard let moriNode,
              !moriNode.hasActions(),
              viewModel.canMoveMori(to: platformID),
              let path = viewModel.connectionPath(from: viewModel.moriPlatformID, to: platformID) else {
            return
        }

        let actions = path.dropFirst().compactMap { nextPlatformID -> SKAction? in
            guard let platform = platformNodes[nextPlatformID] else { return nil }
            let destination = moriStandingPosition(on: platform)
            return SKAction.move(to: destination, duration: 0.35)
        }

        guard !actions.isEmpty else { return }

        moriNode.playWalkAnimation()
        moriNode.run(SKAction.sequence(actions)) { [weak self] in
            self?.viewModel.moveMori(to: platformID)
            self?.moriNode?.playIdleAnimation()
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

    private func portalConfiguration(at location: CGPoint) -> PortalConfiguration? {
        var touchedNode: SKNode? = atPoint(location)

        while let node = touchedNode {
            if let portal = node as? ExitNode {
                return viewModel.currentLevel.portalConfigurations.first { $0.id == portal.name }
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

    private func isMoriSupported(_ mori: PlayerNode) -> Bool {
        platformNodes.values.contains { platform in
            guard platform.model.isWalkable else { return false }
            let standingPosition = moriStandingPosition(on: platform)
            let horizontalDistance = abs(mori.position.x - standingPosition.x)
            let verticalDistance = abs(mori.position.y - standingPosition.y)
            return horizontalDistance <= platform.model.size.width / 2 + 18
                && verticalDistance <= 12
        }
    }

    private func handleFall() {
        guard let moriNode else { return }
        isRestartingLevel = true
        print("Mori fell. Restarting level.")

        let fall = SKAction.moveBy(x: 0, y: -100, duration: 0.22)
        let disappear = SKAction.fadeOut(withDuration: 0.12)
        moriNode.run(.sequence([.group([fall, disappear]), .wait(forDuration: 0.15)])) { [weak self] in
            guard let self else { return }
            self.viewModel.restartLevel()
            self.renderLevel()
            self.isRestartingLevel = false
        }
    }

    private func enter(portal: PortalConfiguration) {
        moveMori(to: portal.platformID, entering: portal)
    }

    private func moveMori(to platformID: String, entering portal: PortalConfiguration? = nil) {
        let isAlreadyOnPortalPlatform = portal != nil && viewModel.moriPlatformID == platformID
        guard (isAlreadyOnPortalPlatform || viewModel.canMoveMori(to: platformID)),
              let moriNode,
              !moriNode.hasActions(),
              let path = viewModel.connectionPath(from: viewModel.moriPlatformID, to: platformID) else {
            return
        }

        var previousPosition = moriNode.position
        var movementActions: [SKAction] = []

        for nextPlatformID in path.dropFirst() {
            guard let platform = platformNodes[nextPlatformID] else { return }
            let destination = moriStandingPosition(on: platform)
            movementActions.append(movementAction(from: previousPosition, to: destination))
            previousPosition = destination
        }

        if let portal, let portalNode = portalNodes[portal.id] {
            let portalDestination = portalNode.convert(CGPoint.zero, to: self)
            movementActions.append(movementAction(from: previousPosition, to: portalDestination))
        }

        guard !movementActions.isEmpty else { return }

        moriNode.playWalkAnimation()
        movementActions.append(SKAction.run { [weak self] in
            self?.viewModel.moveMori(to: platformID)

            if let portal {
                self?.handlePortalOutcome(portal)
            } else {
                self?.updateInstruction()
                self?.moriNode?.playIdleAnimation()
            }
        })
        moriNode.run(SKAction.sequence(movementActions), withKey: "moriMove")
    }

    private func handlePortalOutcome(_ portal: PortalConfiguration) {
        switch portal.outcome {
        case .completesLevel:
            viewModel.markExitReached()
            print("Mori entered the correct portal")
            appFlow.completeLevel(viewModel.currentLevel.id)

        case .loops(let destination):
            guard let destinationPlatform = platformNodes[destination.platformID],
                  let moriNode else { return }

            let targetPosition = moriStandingPosition(
                on: destinationPlatform,
                offset: destination.offset
            )
            let loop = SKAction.sequence([
                .fadeOut(withDuration: 0.12),
                .move(to: targetPosition, duration: 0),
                .fadeIn(withDuration: 0.12),
                .run { [weak self] in
                    self?.viewModel.moveMori(to: destination.platformID)
                    self?.moriNode?.playIdleAnimation()
                }
            ])
            moriNode.run(loop, withKey: "portalLoop")
        }
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

    @discardableResult
    private func attemptSnapIfNeeded() -> Bool {
        guard let platformB = draggedPlatform else { return false }

        guard let snapTarget = snapTarget(for: platformB) else { return false }
        let snappedPosition = CGPoint(x: snapTarget.position.x, y: platformB.position.y)

        guard connectionIsAllowed(between: snapTarget.platform, and: platformB),
              viewModel.connect(snapTarget.platform.model.id, to: platformB.model.id) else {
            return false
        }

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

        for target in platformNodes.values where !target.model.isDraggable && target.model.isWalkable {
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
        } else if level.portalConfigurations.first?.platformID == draggablePlatform.id {
            instructionLabel?.text = "Tap the black hole"
        } else if viewModel.moriPlatformID == level.player.startingPlatformID {
            instructionLabel?.text = "Tap Platform B to move Mori"
        } else if let portalPlatformID = level.portalConfigurations.first?.platformID,
                  !viewModel.areConnected(draggablePlatform.id, portalPlatformID) {
            instructionLabel?.text = "Drag Platform B to Platform C"
        } else {
            instructionLabel?.text = "Tap the black hole"
        }
    }

    private func snapTarget(for draggablePlatform: PlatformNode) -> (platform: PlatformNode, position: CGPoint)? {
        var nearestTarget: (platform: PlatformNode, position: CGPoint, gap: CGFloat)?
        let snapRule = viewModel.currentLevel.snapRules.first {
            $0.draggablePlatformID == draggablePlatform.model.id
        }
        let snapThreshold = snapRule?.threshold ?? GameConstants.Snap.threshold

        for target in platformNodes.values where !target.model.isDraggable && target.model.isWalkable {
            if let snapRule, !snapRule.targetPlatformIDs.contains(target.model.id) {
                continue
            }
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

            guard gap >= 0, gap <= snapThreshold else { continue }

            if nearestTarget == nil || gap < nearestTarget!.gap {
                nearestTarget = (target, CGPoint(x: snappedX, y: draggablePlatform.position.y), gap)
            }
        }

        guard let nearestTarget else { return nil }
        return (nearestTarget.platform, nearestTarget.position)
    }

    private func addBackground(for level: LevelConfiguration) {
        guard let backgroundAssetName = level.backgroundAssetName else { return }

        let background = SKSpriteNode(imageNamed: backgroundAssetName)
        background.size = size
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -20
        addChild(background)
    }
}
