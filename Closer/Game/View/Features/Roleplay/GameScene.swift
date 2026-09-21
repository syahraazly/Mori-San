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
    private var exitNode: ExitNode?
    private var petalNode: PetalNode?
    private var chapterProgressLabel: SKLabelNode?
    private var chapterProgressGoal: FlowerGoal?
    private var instructionLabel: SKLabelNode?
    private var perspectiveSwipeStart: CGPoint?
    private var isRestartingLevel = false
    /// Tracks the exact surface (cell) position Mori is standing on within a multi-cell platform.
    /// nil when Mori is on a single1x1 platform or before the first placement.
    private var moriCurrentSurfacePosition: CGPoint?
    /// Platform touch that has not yet been confirmed as a drag (pending gesture disambiguation).
    private var pendingDragPlatform: PlatformNode?
    private var pendingDragOffsetX: CGFloat = 0
    private var touchBeganLocation: CGPoint = .zero
    private let dragCommitThreshold: CGFloat = 8
    private var mapView: MapView?

    init(size: CGSize, appFlow: AppFlowViewModel) {
        self.appFlow = appFlow
        viewModel = GameViewModel(initialLevel: TutorialLevelData.closerLevel)
        super.init(size: size)
        scaleMode = .resizeFill
        backgroundColor = SKColor(red: 0.95, green: 0.90, blue: 0.82, alpha: 1.0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        renderCurrentScreen()
    }

    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        renderCurrentScreen()

        guard case .gameplay = appFlow.screen,
              !isRestartingLevel,
              let moriNode,
              moriNode.action(forKey: "moriMove") == nil,
              moriNode.action(forKey: "perspectiveMove") == nil,
              moriNode.action(forKey: "portalLoop") == nil,
              !isMoriSupported(moriNode) else {
            return
        }

        handleMoriFall()
    }

    func renderCurrentScreen() {
        let screen = appFlow.screen
        guard renderedScreen != screen else { return }
        renderedScreen = screen

        switch screen {
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
            progress: appFlow.progress,
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
        exitNode = nil
        petalNode = nil
        chapterProgressLabel = nil
        chapterProgressGoal = nil
        moriCurrentSurfacePosition = nil
        pendingDragPlatform = nil
        didDragPlatform = false

        let level = viewModel.currentLevel
        addBackground(for: level)
        createLevelBackButton()
        createChapterProgressHUD(for: level)

        for platform in level.platforms {
            let node = PlatformNode(model: platform)
            node.position = position(for: platform)
            addChild(node)
            platformNodes[platform.id] = node
        }

        viewModel.setConnections(allowedConnections(from: level.initialConnections))

        if level.usesPerspective {
            updatePerspectiveConnections()
        }

        if let petalConfig = level.petalConfiguration,
           let platform = platformNodes[petalConfig.platformID] {
            let petal = PetalNode(
                platformID: petalConfig.platformID,
                assetName: petalConfig.assetName ?? petalAssetName(for: level)
            )
            petal.position = petalConfig.offset
            petal.zPosition = 10
            platform.addChild(petal)
            petalNode = petal
        }

        guard let startPlatform = level.platforms.first(where: { $0.id == level.player.startingPlatformID }),
              let startPlatformNode = platformNodes[startPlatform.id] else { return }

        let mori = PlayerNode(player: level.player)
        let initialLanding = startPlatformNode.landingPosition(approachingFrom: startPlatformNode.position)
        mori.position = CGPoint(
            x: initialLanding.x + level.player.startingOffset.x,
            y: initialLanding.y + level.player.startingOffset.y
        )
        mori.zPosition = 10
        addChild(mori)
        moriNode = mori

        let exitPlatformID = resolvedExitPlatformID(for: level)
        if !level.portalConfigurations.isEmpty {
            for portal in level.portalConfigurations {
                guard let portalPlatformNode = platformNodes[portal.platformID] else { continue }
                let portalNode = ExitNode(portalID: portal.id)
                portalNode.position = portalPosition(for: portal, on: portalPlatformNode)
                portalNode.zPosition = 8
                if case .completesLevel = portal.outcome {
                    portalNode.setLocked(viewModel.hasPetalToCollect && !viewModel.hasCollectedPetal)
                    exitNode = portalNode
                }
                portalPlatformNode.addChild(portalNode)
                portalNodes[portal.id] = portalNode
            }
        } else if level.interaction != .perspective,
                  let exitPlatform = level.platforms.first(where: { $0.id == exitPlatformID }) {
            let exit = ExitNode()
            exit.position = level.exitConfiguration?.offset ?? CGPoint(x: 45, y: 55)
            exit.zPosition = 10
            exit.setLocked(viewModel.hasPetalToCollect && !viewModel.hasCollectedPetal)
            platformNodes[exitPlatform.id]?.addChild(exit)
            exitNode = exit
            portalNodes["exit"] = exit
        }

        createInstructionLabel()
        updateInstruction()

        checkPetalCollection(at: level.player.startingPlatformID)
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
            if node.name == "back-to-map" {
                appFlow.openMap()
                return
            }

            if let name = node.name {
                if name.hasPrefix("level-") {
                    let levelID = String(name.dropFirst("level-".count))
                    guard appFlow.isLevelUnlocked(levelID) else { return }
                    appFlow.startLevel(levelID)
                    return
                } else if name.hasPrefix("start-level-") {
                    let levelID = String(name.dropFirst("start-level-".count))
                    guard appFlow.isLevelUnlocked(levelID) else { return }
                    appFlow.startLevel(levelID)
                    return
                }
            }
            touchedNode = node.parent
        }
    }

    private func handleGameplayTouch(_ touch: UITouch) {
        if viewModel.hasReachedExit {
            return
        }

        let touchLocation = touch.location(in: self)

        if isLevelBackButton(at: touchLocation) {
            returnToLevelChapter()
            return
        }

        let exitPlatformID = resolvedExitPlatformID(for: viewModel.currentLevel)
        let touchedPortal = portalConfiguration(at: touchLocation)

        // Exit / Portal touched
        if exitNode(at: touchLocation) != nil || touchedPortal != nil {
            if let portal = touchedPortal, case .loops = portal.outcome {
                if viewModel.moriPlatformID == portal.platformID {
                    handlePortalOutcome(portal)
                } else if viewModel.canMoveMori(to: portal.platformID) {
                    moveMori(to: portal.platformID, completesLevel: false, portal: portal)
                }
                return
            }

            if viewModel.hasPetalToCollect && !viewModel.hasCollectedPetal {
                exitNode?.playShake()
                showPetalRequiredNotice()
                return
            }

            let targetPlatformID = touchedPortal?.platformID ?? exitPlatformID
            if viewModel.moriPlatformID == targetPlatformID {
                enterExit(portal: touchedPortal)
                return
            }

            if viewModel.canMoveMori(to: targetPlatformID) {
                moveMori(to: targetPlatformID, completesLevel: true, portal: touchedPortal)
            }
            return
        }

        // Petal touched
        if let touchedPetal = petalNode(at: touchLocation) {
            if viewModel.canMoveMori(to: touchedPetal.platformID) {
                if viewModel.currentLevel.usesPerspective {
                    moveMoriAcrossPerspectivePath(to: touchedPetal.platformID)
                } else {
                    moveMori(to: touchedPetal.platformID, completesLevel: false)
                }
                return
            }
        }

        if viewModel.currentLevel.interaction == .perspective {
            if let platform = platformNode(at: touchLocation) {
                moveMoriAcrossPerspectivePath(to: platform.model.id)
                return
            }

            if platformNode(at: touchLocation) == nil,
               exitNode(at: touchLocation) == nil,
               touchedPortal == nil,
               petalNode(at: touchLocation) == nil,
               playerNode(at: touchLocation) == nil {
                perspectiveSwipeStart = touchLocation
            }
            return
        }

        if viewModel.currentLevel.interaction == .perspectiveCompact {
            if let platform = platformNode(at: touchLocation) {
                if platform.model.id == viewModel.moriPlatformID {
                    if platform.model.isDraggable {
                        pendingDragPlatform = platform
                        pendingDragOffsetX = touchLocation.x - platform.position.x
                        touchBeganLocation = touchLocation
                        didDragPlatform = false
                    } else if let targetSurface = platform.closestSurface(to: touchLocation) {
                        walkMoriWithinPlatform(to: targetSurface.position)
                    }
                    return
                }

                if viewModel.canMoveMori(to: platform.model.id) {
                    moveMoriAcrossPerspectivePath(to: platform.model.id)
                    return
                }

                if platform.model.isDraggable {
                    pendingDragPlatform = platform
                    pendingDragOffsetX = touchLocation.x - platform.position.x
                    touchBeganLocation = touchLocation
                    didDragPlatform = false
                    return
                }
            }

            if playerNode(at: touchLocation) == nil {
                perspectiveSwipeStart = touchLocation
            }
            return
        }

        guard let platform = platformNode(at: touchLocation) else {
            if viewModel.currentLevel.usesPerspective,
               playerNode(at: touchLocation) == nil,
               petalNode(at: touchLocation) == nil {
                perspectiveSwipeStart = touchLocation
            }
            return
        }

        // 1. Mori is standing on this platform
        if platform.model.id == viewModel.moriPlatformID {
            if platform.model.isDraggable {
                pendingDragPlatform = platform
                pendingDragOffsetX = touchLocation.x - platform.position.x
                touchBeganLocation = touchLocation
                didDragPlatform = false
            } else if let targetSurface = platform.closestSurface(to: touchLocation) {
                walkMoriWithinPlatform(to: targetSurface.position)
            }
            return
        }

        // 2. Mori is on a different platform, and can move to this platform
        if viewModel.canMoveMori(to: platform.model.id) {
            if viewModel.currentLevel.usesPerspective {
                moveMoriAcrossPerspectivePath(to: platform.model.id)
            } else {
                moveMori(to: platform.model.id, completesLevel: false)
            }
            return
        }

        // 3. Mori is on a different platform, and this platform is draggable
        if platform.model.isDraggable {
            guard !viewModel.isConnected
                    || (platform.model.remainsDraggableWhenConnected
                        && !viewModel.areConnected(platform.model.id, exitPlatformID)) else {
                return
            }

            pendingDragPlatform = platform
            pendingDragOffsetX = touchLocation.x - platform.position.x
            touchBeganLocation = touchLocation
            didDragPlatform = false
            return
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if case .map = appFlow.screen, let touch = touches.first {
            mapView?.handleTouchMoved(to: touch.location(in: self))
            return
        }

        guard case .gameplay = appFlow.screen else { return }
        guard viewModel.currentLevel.allowsCompact else { return }
        guard let touch = touches.first else { return }

        let touchLocation = touch.location(in: self)

        // Promote pending → active drag once finger crosses the commit threshold.
        if draggedPlatform == nil, let pending = pendingDragPlatform {
            let moved = abs(touchLocation.x - touchBeganLocation.x)
            if moved >= dragCommitThreshold {
                draggedPlatform = pending
                dragTouchOffsetX = pendingDragOffsetX
                pendingDragPlatform = nil
            } else {
                return
            }
        }

        guard let platform = draggedPlatform else { return }

        let newX = touchLocation.x - dragTouchOffsetX
        let halfPlatformWidth = platform.model.effectiveWidth / 2
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
            viewModel.disconnectSnappedConnections(for: platform.model.id)
            didDragPlatform = true
            viewModel.disconnectSnap(for: platform.model.id)
            if viewModel.currentLevel.usesPerspective {
                updatePerspectiveConnectionsUsingActualPositions()
            }
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

        defer {
            pendingDragPlatform = nil
        }

        if viewModel.currentLevel.usesPerspective {
            if viewModel.currentLevel.interaction == .perspectiveCompact, didDragPlatform {
                if !attemptSnapIfNeeded() {
                    viewModel.disconnectSnap(for: draggedPlatform?.model.id)
                    updatePerspectiveConnectionsUsingActualPositions()
                }
                draggedPlatform = nil
                didDragPlatform = false
                return
            }

            // Pending never became a drag → treat as tap on that platform.
            if let pending = pendingDragPlatform {
                if pending.model.id == viewModel.moriPlatformID {
                    if let surf = pending.closestSurface(to: touchBeganLocation) {
                        walkMoriWithinPlatform(to: surf.position)
                    }
                } else if viewModel.canMoveMori(to: pending.model.id) {
                    moveMoriAcrossPerspectivePath(to: pending.model.id)
                }
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

        // Pending never became a drag → treat as tap on that platform.
        if let pending = pendingDragPlatform {
            if pending.model.id == viewModel.moriPlatformID {
                if let surf = pending.closestSurface(to: touchBeganLocation) {
                    walkMoriWithinPlatform(to: surf.position)
                }
            } else if viewModel.canMoveMori(to: pending.model.id) {
                moveMori(to: pending.model.id, completesLevel: false)
            }
            draggedPlatform = nil
            didDragPlatform = false
            return
        }

        if didDragPlatform {
            if !attemptSnapIfNeeded() {
                viewModel.disconnectSnap(for: draggedPlatform?.model.id)
            }
        }
        draggedPlatform = nil
        didDragPlatform = false
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard case .gameplay = appFlow.screen else { return }
        if didDragPlatform {
            if !attemptSnapIfNeeded() {
                viewModel.disconnectSnap(for: draggedPlatform?.model.id)
            }
        }
        draggedPlatform = nil
        pendingDragPlatform = nil
        didDragPlatform = false
        perspectiveSwipeStart = nil
    }

    private func position(for platform: PlatformModel) -> CGPoint {
        let level = viewModel.currentLevel
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
        if firstPosition.x <= secondPosition.x {
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
                let currentOffset = CGPoint(
                    x: (moriNode?.position.x ?? node.position.x) - node.position.x,
                    y: (moriNode?.position.y ?? (node.position.y + 55)) - node.position.y
                )
                let moriDestination = CGPoint(x: destination.x + currentOffset.x, y: destination.y + currentOffset.y)
                moriNode?.removeAction(forKey: "perspectiveMove")
                let dx = moriDestination.x - (moriNode?.position.x ?? moriDestination.x)
                if abs(dx) > 1 {
                    moriNode?.setFacing(right: dx > 0)
                }
                moriNode?.run(
                    SKAction.move(to: moriDestination, duration: 0.35),
                    withKey: "perspectiveMove"
                )
            }
        }
    }

    private func updatePerspectiveConnections() {
        let platforms = viewModel.currentLevel.platforms.filter(\.isWalkable)
        var newConnections: [ConnectionModel] = []
        let maximumGap: CGFloat = 25
        let maximumVerticalDifference: CGFloat = 8

        for firstIndex in platforms.indices {
            for secondIndex in platforms.indices.dropFirst(firstIndex + 1) {
                let firstPlatform = platforms[firstIndex]
                let secondPlatform = platforms[secondIndex]
                let firstPosition = position(for: firstPlatform)
                let secondPosition = position(for: secondPlatform)
                let horizontalDistance = abs(firstPosition.x - secondPosition.x)
                let combinedHalfWidths = (firstPlatform.effectiveWidth + secondPlatform.effectiveWidth) / 2
                let edgeGap = horizontalDistance - combinedHalfWidths

                guard let firstNode = platformNodes[firstPlatform.id],
                      let secondNode = platformNodes[secondPlatform.id] else { continue }

                let firstSurfaces = firstNode.playableSurfaces(at: firstPosition)
                let secondSurfaces = secondNode.playableSurfaces(at: secondPosition)

                var matchingPair: (s1: PlatformNode.PlayableSurface, s2: PlatformNode.PlayableSurface)?
                for s1 in firstSurfaces {
                    for s2 in secondSurfaces {
                        if abs(s1.position.y - s2.position.y) <= maximumVerticalDifference {
                            if let current = matchingPair {
                                if abs(s1.position.x - s2.position.x) < abs(current.s1.position.x - current.s2.position.x) {
                                    matchingPair = (s1, s2)
                                }
                            } else {
                                matchingPair = (s1, s2)
                            }
                        }
                    }
                }

                if let pair = matchingPair, abs(edgeGap) <= maximumGap {
                    if connectionIsAllowed(between: firstPlatform, at: firstPosition, and: secondPlatform, at: secondPosition)
                        && !isHopPathBlocked(from: pair.s1.position, to: pair.s2.position, usingLayoutPositions: true) {
                        newConnections.append(
                            ConnectionModel(
                                firstPlatformID: firstPlatform.id,
                                secondPlatformID: secondPlatform.id
                            )
                        )
                    }
                }
            }
        }

        viewModel.setPerspectiveConnections(newConnections)
    }

    /// Sama seperti updatePerspectiveConnections() tapi menggunakan posisi aktual node
    /// (bukan posisi layout frontPosition/sidePosition). Dipanggil setelah snap/drag
    /// agar koneksi benar-benar mencerminkan posisi fisik balok di layar.
    private func updatePerspectiveConnectionsUsingActualPositions() {
        let platforms = viewModel.currentLevel.platforms.filter(\.isWalkable)
        var newConnections: [ConnectionModel] = []
        let maximumGap: CGFloat = 25
        let maximumVerticalDifference: CGFloat = 8

        for firstIndex in platforms.indices {
            for secondIndex in platforms.indices.dropFirst(firstIndex + 1) {
                let firstPlatform = platforms[firstIndex]
                let secondPlatform = platforms[secondIndex]

                guard let firstNode = platformNodes[firstPlatform.id],
                      let secondNode = platformNodes[secondPlatform.id] else { continue }
                let firstPosition = firstNode.position
                let secondPosition = secondNode.position

                let horizontalDistance = abs(firstPosition.x - secondPosition.x)
                let combinedHalfWidths = (firstPlatform.effectiveWidth + secondPlatform.effectiveWidth) / 2
                let edgeGap = horizontalDistance - combinedHalfWidths

                let firstSurfaces = firstNode.playableSurfaces(at: firstPosition)
                let secondSurfaces = secondNode.playableSurfaces(at: secondPosition)

                var matchingPair: (s1: PlatformNode.PlayableSurface, s2: PlatformNode.PlayableSurface)?
                for s1 in firstSurfaces {
                    for s2 in secondSurfaces {
                        if abs(s1.position.y - s2.position.y) <= maximumVerticalDifference {
                            if let current = matchingPair {
                                if abs(s1.position.x - s2.position.x) < abs(current.s1.position.x - current.s2.position.x) {
                                    matchingPair = (s1, s2)
                                }
                            } else {
                                matchingPair = (s1, s2)
                            }
                        }
                    }
                }

                if let pair = matchingPair, abs(edgeGap) <= maximumGap {
                    if connectionIsAllowed(between: firstNode, and: secondNode)
                        && !isHopPathBlocked(from: pair.s1.position, to: pair.s2.position, usingLayoutPositions: false) {
                        newConnections.append(
                            ConnectionModel(
                                firstPlatformID: firstPlatform.id,
                                secondPlatformID: secondPlatform.id
                            )
                        )
                    }
                }
            }
        }

        viewModel.setPerspectiveConnections(newConnections)
    }

    private func isHopPathBlocked(
        from start: CGPoint,
        to end: CGPoint,
        usingLayoutPositions: Bool = true
    ) -> Bool {
        for (id, node) in platformNodes {
            guard let model = viewModel.currentLevel.platforms.first(where: { $0.id == id }) else { continue }
            let pos = usingLayoutPositions ? position(for: model) : node.position
            let cellRects = node.occupiedCellRects(at: pos)
            for rect in cellRects {
                let insetRect = rect.insetBy(dx: 1, dy: 1)
                if lineIntersectsRect(from: start, to: end, rect: insetRect) {
                    return true
                }
            }
        }
        return false
    }

    private func lineIntersectsRect(from p1: CGPoint, to p2: CGPoint, rect: CGRect) -> Bool {
        if rect.contains(p1) || rect.contains(p2) { return true }

        let left = lineIntersectsLine(p1: p1, p2: p2, q1: CGPoint(x: rect.minX, y: rect.minY), q2: CGPoint(x: rect.minX, y: rect.maxY))
        let right = lineIntersectsLine(p1: p1, p2: p2, q1: CGPoint(x: rect.maxX, y: rect.minY), q2: CGPoint(x: rect.maxX, y: rect.maxY))
        let top = lineIntersectsLine(p1: p1, p2: p2, q1: CGPoint(x: rect.minX, y: rect.maxY), q2: CGPoint(x: rect.maxX, y: rect.maxY))
        let bottom = lineIntersectsLine(p1: p1, p2: p2, q1: CGPoint(x: rect.minX, y: rect.minY), q2: CGPoint(x: rect.maxX, y: rect.minY))

        return left || right || top || bottom
    }

    private func lineIntersectsLine(p1: CGPoint, p2: CGPoint, q1: CGPoint, q2: CGPoint) -> Bool {
        func ccw(_ a: CGPoint, _ b: CGPoint, _ c: CGPoint) -> Bool {
            return (c.y - a.y) * (b.x - a.x) > (b.y - a.y) * (c.x - a.x)
        }
        return (ccw(p1, q1, q2) != ccw(p2, q1, q2)) && (ccw(p1, p2, q1) != ccw(p1, p2, q2))
    }

    private func moveMoriAcrossPerspectivePath(to platformID: String) {
        guard let moriNode,
              !moriNode.hasActions(),
              let path = viewModel.connectionPath(from: viewModel.moriPlatformID, to: platformID) else {
            return
        }

        var previousPosition = moriNode.position
        var actions: [SKAction] = []

        for nextPlatformID in path.dropFirst() {
            guard let platform = platformNodes[nextPlatformID] else { return }
            let destination = platform.landingPosition(approachingFrom: previousPosition)
            let start = previousPosition

            let stepAction = SKAction.run { [weak moriNode] in
                let dx = destination.x - start.x
                if abs(dx) > 1 {
                    moriNode?.playWalk(facingRight: dx > 0)
                } else {
                    moriNode?.playWalk()
                }
            }
            actions.append(stepAction)
            actions.append(movementAction(from: previousPosition, to: destination))

            let stepArrival = SKAction.run { [weak self] in
                self?.moriCurrentSurfacePosition = nil
                self?.viewModel.moveMori(to: nextPlatformID)
                self?.checkPetalCollection(at: nextPlatformID)
            }
            actions.append(stepArrival)
            previousPosition = destination
        }

        guard !actions.isEmpty else { return }

        actions.append(SKAction.run { [weak self, weak moriNode] in
            moriNode?.playIdle()
            self?.updateInstruction()
        })

        moriNode.run(SKAction.sequence(actions), withKey: "moriMove")
    }

    private func checkPetalCollection(at platformID: String) {
        guard let petalNode,
              !petalNode.isCollected,
              petalNode.platformID == platformID else {
            return
        }

        viewModel.collectPetal()
        appFlow.claimPetal(for: viewModel.currentLevel.id)
        updateChapterProgressHUD()
        HapticManager.playSnapFeedback()
        petalNode.collect { [weak self] in
            self?.petalNode = nil
        }
        exitNode?.unlockWithAnimation()
        updateInstruction()
    }

    private func showPetalRequiredNotice() {
        instructionLabel?.text = "Ambil kelopak bunga terlebih dahulu!"
        let pulseRed = SKAction.sequence([
            SKAction.run { [weak self] in
                self?.instructionLabel?.fontColor = SKColor(red: 0.85, green: 0.35, blue: 0.30, alpha: 1.0)
            },
            SKAction.scale(to: 1.08, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1),
            SKAction.wait(forDuration: 1.2),
            SKAction.run { [weak self] in
                self?.instructionLabel?.fontColor = SKColor(red: 0.22, green: 0.24, blue: 0.30, alpha: 1.0)
                self?.updateInstruction()
            }
        ])
        instructionLabel?.removeAction(forKey: "noticePulse")
        instructionLabel?.run(pulseRed, withKey: "noticePulse")
    }

    private func petalAssetName(for level: LevelConfiguration) -> String {
        guard let goalID = LevelCatalog.goalID(for: level.id),
              let goal = FlowerGoalData.goal(for: goalID) else {
            return "forget-me-not-petal"
        }
        return goal.petalAssetName
    }

    private func updateChapterProgressHUD() {
        guard let chapterProgressLabel,
              let chapterProgressGoal else {
            return
        }

        chapterProgressLabel.text = "\(appFlow.progress.petalCount(for: chapterProgressGoal))/\(chapterProgressGoal.totalPetals)"
    }

    private func createChapterProgressHUD(for level: LevelConfiguration) {
        guard let goalID = LevelCatalog.goalID(for: level.id),
              let goal = FlowerGoalData.goal(for: goalID) else {
            return
        }

        let hud = SKShapeNode(rectOf: CGSize(width: 108, height: 42), cornerRadius: 14)
        hud.fillColor = SKColor(red: 0.22, green: 0.24, blue: 0.30, alpha: 0.82)
        hud.strokeColor = .white.withAlphaComponent(0.35)
        hud.lineWidth = 2
        hud.position = CGPoint(x: size.width - 64, y: size.height - 42)
        hud.zPosition = 100
        addChild(hud)

        let petal = SKSpriteNode(imageNamed: goal.petalAssetName)
        petal.size = CGSize(width: 28, height: 22)
        petal.position = CGPoint(x: -30, y: 0)
        hud.addChild(petal)

        let count = SKLabelNode(fontNamed: "AvenirNext-Bold")
        count.text = "\(appFlow.progress.petalCount(for: goal))/\(goal.totalPetals)"
        count.fontSize = 16
        count.horizontalAlignmentMode = .left
        count.verticalAlignmentMode = .center
        count.fontColor = .white
        count.position = CGPoint(x: -10, y: 0)
        hud.addChild(count)
        chapterProgressLabel = count
        chapterProgressGoal = goal
    }

    private func createLevelBackButton() {
        let button = SKShapeNode(rectOf: CGSize(width: 118, height: 42), cornerRadius: 14)
        button.name = "back-to-chapter"
        button.fillColor = SKColor(red: 0.38, green: 0.31, blue: 0.52, alpha: 0.92)
        button.strokeColor = .white.withAlphaComponent(0.35)
        button.lineWidth = 2
        button.position = CGPoint(x: 74, y: size.height - 42)
        button.zPosition = 100
        addChild(button)

        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = "‹ Chapter"
        label.fontSize = 16
        label.verticalAlignmentMode = .center
        label.fontColor = .white
        button.addChild(label)
    }

    private func isLevelBackButton(at location: CGPoint) -> Bool {
        var touchedNode: SKNode? = atPoint(location)

        while let node = touchedNode {
            if node.name == "back-to-chapter" {
                return true
            }
            touchedNode = node.parent
        }

        return false
    }

    private func returnToLevelChapter() {
        if let goalID = LevelCatalog.goalID(for: viewModel.currentLevel.id) {
            appFlow.openGoal(goalID)
        } else {
            appFlow.openMap()
        }
    }

    private func addBackground(for level: LevelConfiguration) {
        guard let backgroundAssetName = level.backgroundAssetName else { return }

        let background = SKSpriteNode(imageNamed: backgroundAssetName)
        background.size = size
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -20
        addChild(background)
    }

    private func petalNode(at location: CGPoint) -> PetalNode? {
        var touchedNode: SKNode? = atPoint(location)

        while let node = touchedNode {
            if let petal = node as? PetalNode {
                return petal
            }
            touchedNode = node.parent
        }

        return nil
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

    private func resolvedExitPlatformID(for level: LevelConfiguration) -> String {
        if let exitID = level.exitConfiguration?.platformID {
            return exitID
        }
        for portal in level.portalConfigurations {
            if case .completesLevel = portal.outcome {
                return portal.platformID
            }
        }
        return level.exitPlatformID
    }

    private func isMoriSupported(_ mori: PlayerNode) -> Bool {
        platformNodes.values.contains { platform in
            guard platform.model.isWalkable else { return false }
            let surfaces = platform.playableSurfaces(at: platform.position)
            return surfaces.contains { surface in
                let horizontalDistance = abs(mori.position.x - surface.position.x)
                let verticalDistance = abs(mori.position.y - surface.position.y)
                let tolerance = platform.model.shape == .single1x1
                    ? (platform.model.size.width / 2 + 22)
                    : (surface.cellRect.width / 2 + 12)
                return horizontalDistance <= tolerance
                    && verticalDistance <= 18
            }
        }
    }

    private func handleMoriFall() {
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

    private func handlePortalOutcome(_ portal: PortalConfiguration) {
        switch portal.outcome {
        case .completesLevel:
            enterExit(portal: portal)

        case .loops(let destination):
            guard let destinationPlatform = platformNodes[destination.platformID],
                  let moriNode else { return }

            let targetLanding = destinationPlatform.landingPosition(approachingFrom: destinationPlatform.position)
            let targetPosition = CGPoint(
                x: targetLanding.x + destination.offset.x,
                y: targetLanding.y + destination.offset.y
            )
            let loop = SKAction.sequence([
                .fadeOut(withDuration: 0.12),
                .move(to: targetPosition, duration: 0),
                .fadeIn(withDuration: 0.12),
                .run { [weak self] in
                    self?.moriCurrentSurfacePosition = nil
                    self?.viewModel.moveMori(to: destination.platformID)
                    self?.checkPetalCollection(at: destination.platformID)
                    self?.moriNode?.playIdle()
                }
            ])
            moriNode.run(loop, withKey: "portalLoop")
        }
    }

    private func enterExit(portal: PortalConfiguration? = nil) {
        guard let moriNode, !viewModel.hasReachedExit else { return }

        if let portal, case .loops = portal.outcome {
            handlePortalOutcome(portal)
            return
        }

        viewModel.markExitReached()
        print("Mori reached the exit")

        let targetExitNode = (portal != nil ? portalNodes[portal!.id] : nil) ?? exitNode
        if let targetExitNode {
            let exitCenter = targetExitNode.convert(CGPoint.zero, to: self)
            let moveToCenter = SKAction.move(to: exitCenter, duration: 0.18)
            let shrink = SKAction.scale(to: 0.1, duration: 0.3)
            let spin = SKAction.rotate(byAngle: .pi * 2, duration: 0.3)
            let fade = SKAction.fadeOut(withDuration: 0.3)
            let group = SKAction.group([shrink, spin, fade])
            let enterAnim = SKAction.sequence([moveToCenter, group])
            HapticManager.playSnapFeedback()
            moriNode.run(enterAnim) { [weak self] in
                guard let self else { return }
                self.appFlow.completeLevel(self.viewModel.currentLevel.id)
            }
        } else {
            appFlow.completeLevel(viewModel.currentLevel.id)
        }
    }

    private func moveMori(to platformID: String, completesLevel: Bool, portal: PortalConfiguration? = nil) {
        guard let moriNode, moriNode.action(forKey: "moriMove") == nil else { return }

        if completesLevel && viewModel.moriPlatformID == platformID {
            enterExit(portal: portal)
            return
        }

        guard viewModel.canMoveMori(to: platformID),
              let path = viewModel.connectionPath(from: viewModel.moriPlatformID, to: platformID) else {
            return
        }

        var previousPosition = moriNode.position
        var movementActions: [SKAction] = []

        for nextPlatformID in path.dropFirst() {
            guard let platform = platformNodes[nextPlatformID] else { return }
            let destination = platform.landingPosition(approachingFrom: previousPosition)
            let start = previousPosition

            let faceAction = SKAction.run { [weak moriNode] in
                let dx = destination.x - start.x
                if abs(dx) > 1 {
                    moriNode?.playWalk(facingRight: dx > 0)
                } else {
                    moriNode?.playWalk()
                }
            }
            movementActions.append(faceAction)
            movementActions.append(movementAction(from: previousPosition, to: destination))

            let stepArrival = SKAction.run { [weak self] in
                self?.moriCurrentSurfacePosition = nil
                self?.viewModel.moveMori(to: nextPlatformID)
                self?.checkPetalCollection(at: nextPlatformID)
            }
            movementActions.append(stepArrival)
            previousPosition = destination
        }

        if completesLevel {
            let targetExitNode = (portal != nil ? portalNodes[portal!.id] : nil) ?? exitNode
            if let targetExitNode {
                let exitDestination = targetExitNode.convert(CGPoint.zero, to: self)
                let start = previousPosition
                let faceAction = SKAction.run { [weak moriNode] in
                    let dx = exitDestination.x - start.x
                    if abs(dx) > 1 {
                        moriNode?.playWalk(facingRight: dx > 0)
                    } else {
                        moriNode?.playWalk()
                    }
                }
                movementActions.append(faceAction)
                movementActions.append(movementAction(from: previousPosition, to: exitDestination))
                movementActions.append(SKAction.run { [weak self] in
                    self?.enterExit(portal: portal)
                })
            } else {
                movementActions.append(SKAction.run { [weak self] in
                    self?.enterExit(portal: portal)
                })
            }
        } else {
            movementActions.append(SKAction.run { [weak self, weak moriNode] in
                moriNode?.playIdle()
                if let portal {
                    self?.handlePortalOutcome(portal)
                } else {
                    self?.updateInstruction()
                }
            })
        }

        guard !movementActions.isEmpty else { return }
        moriNode.run(SKAction.sequence(movementActions), withKey: "moriMove")
    }

    private func movementAction(from start: CGPoint, to destination: CGPoint) -> SKAction {
        let distance = hypot(destination.x - start.x, destination.y - start.y)
        let duration = max(0.15, TimeInterval(distance / 220))
        return SKAction.move(to: destination, duration: duration)
    }

    /// Walks Mori to a specific cell landing position within the platform they are already on.
    /// `moriPlatformID` is NOT changed — only the visual position updates.
    /// A no-op if Mori is already at that surface or a movement animation is running.
    private func walkMoriWithinPlatform(to destination: CGPoint) {
        guard let moriNode,
              moriNode.action(forKey: "moriMove") == nil else { return }

        // Already standing on that surface — nothing to do.
        if let current = moriCurrentSurfacePosition,
           abs(current.x - destination.x) < 2, abs(current.y - destination.y) < 2 {
            return
        }

        let start = moriNode.position

        // Mori can only walk along a flat surface at the same height (no vertical drops or climbing cliffs)
        if abs(start.y - destination.y) > 8 {
            return
        }

        // Verify trajectory within platform is not blocked by solid cells
        if isHopPathBlocked(from: start, to: destination, usingLayoutPositions: false) {
            return
        }

        let dx = destination.x - start.x

        let faceAction = SKAction.run { [weak moriNode] in
            if abs(dx) > 1 {
                moriNode?.playWalk(facingRight: dx > 0)
            } else {
                moriNode?.playWalk()
            }
        }
        let moveAction = movementAction(from: start, to: destination)
        let arriveAction = SKAction.run { [weak self, weak moriNode] in
            self?.moriCurrentSurfacePosition = destination
            moriNode?.playIdle()
        }

        moriNode.run(
            SKAction.sequence([faceAction, moveAction, arriveAction]),
            withKey: "moriMove"
        )
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

        // Validate and register the graph link at the exact position that will
        // be rendered after the snap, not at the bridge's pre-snap position.
        guard connectionIsAllowed(
            between: snapTarget.platform.model,
            at: snapTarget.platform.position,
            and: platformB.model,
            at: snappedPosition
        ),
              viewModel.connect(snapTarget.platform.model.id, to: platformB.model.id) else {
            return false
        }

        let snapDeltaX = snappedPosition.x - platformB.position.x
        let move = SKAction.move(to: snappedPosition, duration: GameConstants.Snap.animationDuration)
        let bounce = SKAction.sequence([
            SKAction.scale(to: 1.04, duration: 0.06),
            SKAction.scale(to: 1.0, duration: 0.06)
        ])
        platformB.run(.group([move, bounce])) { [weak self] in
            self?.updatePerspectiveConnectionsUsingActualPositions()
        }
        if viewModel.moriPlatformID == platformB.model.id {
            moriNode?.run(SKAction.moveBy(x: snapDeltaX, y: 0, duration: GameConstants.Snap.animationDuration))
        }
        HapticManager.playSnapFeedback()
        updateInstruction()
        return true
    }

    private func isPlacementValid(for draggablePlatform: PlatformNode, at position: CGPoint) -> Bool {
        let draggableRects = draggablePlatform.occupiedCellRects(at: position)
        for (id, target) in platformNodes where id != draggablePlatform.model.id {
            let targetRects = target.occupiedCellRects(at: target.position)
            for dRect in draggableRects {
                for tRect in targetRects {
                    let intersection = dRect.intersection(tRect)
                    if !intersection.isNull, intersection.width > 1, intersection.height > 1 {
                        return false
                    }
                }
            }
        }
        return true
    }

    private func nearestValidX(
        for draggablePlatform: PlatformNode,
        startX: CGFloat,
        directionX: CGFloat
    ) -> CGFloat {
        let y = draggablePlatform.position.y
        // Already valid — nothing to do.
        if isPlacementValid(for: draggablePlatform, at: CGPoint(x: startX, y: y)) {
            return startX
        }
        // Walk away from the obstacle in steps of 0.5 pt until we find clear air,
        // capped at the full width of the scene so we never loop forever.
        let maxSearch: CGFloat = size.width
        let step: CGFloat = directionX >= startX ? -0.5 : 0.5
        var candidate = startX + step
        var traveled: CGFloat = 0
        while traveled <= maxSearch {
            if isPlacementValid(for: draggablePlatform, at: CGPoint(x: candidate, y: y)) {
                return candidate
            }
            candidate += step
            traveled += abs(step)
        }
        return startX // fallback: return original if nothing found
    }

    private func constrainedPlatformX(
        for draggablePlatform: PlatformNode,
        proposedX: CGFloat,
        previousX: CGFloat
    ) -> CGFloat {
        if draggablePlatform.model.shape == .single1x1 {
            var constrainedX = proposedX
            let halfDraggableWidth = draggablePlatform.model.effectiveWidth / 2

            for target in platformNodes.values where !target.model.isDraggable && target.model.isWalkable {
                let halfTargetWidth = target.model.effectiveWidth / 2
                let nearestRightPosition = target.position.x + halfTargetWidth + halfDraggableWidth
                let nearestLeftPosition  = target.position.x - halfTargetWidth - halfDraggableWidth

                // Draggable is (or was) to the right of target and moving left.
                if proposedX < previousX {
                    // Clamp so we never cross into the target from the right side.
                    if proposedX < nearestRightPosition, previousX >= nearestRightPosition {
                        constrainedX = max(constrainedX, nearestRightPosition)
                    }
                }

                // Draggable is (or was) to the left of target and moving right.
                if proposedX > previousX {
                    // Clamp so we never cross into the target from the left side.
                    if proposedX > nearestLeftPosition, previousX <= nearestLeftPosition {
                        constrainedX = min(constrainedX, nearestLeftPosition)
                    }
                }
            }

            return constrainedX
        }

        // --- Multi-cell path (binary search) ---
        let y = draggablePlatform.position.y
        let proposedPosition = CGPoint(x: proposedX, y: y)

        // Fast path: proposed position is already valid.
        if isPlacementValid(for: draggablePlatform, at: proposedPosition) {
            return proposedX
        }

        // If previousX itself is invalid (fast drag left us in an overlap),
        // recover to the nearest valid position on the safe side first.
        let safeX = nearestValidX(for: draggablePlatform, startX: previousX, directionX: proposedX)

        // If even the recovered position equals proposedX direction we cannot move further.
        guard isPlacementValid(for: draggablePlatform, at: CGPoint(x: safeX, y: y)) else {
            return safeX
        }

        // Binary search between safeX and proposedX for the furthest valid position.
        let movingRight = proposedX > safeX
        var lo = safeX
        var hi = proposedX

        // Run up to 16 iterations — precision ≈ |hi-lo| / 2^16 ≈ 0.002 pt at 100 pt range.
        for _ in 0..<16 {
            let mid = (lo + hi) / 2
            if isPlacementValid(for: draggablePlatform, at: CGPoint(x: mid, y: y)) {
                if movingRight { lo = mid } else { hi = mid }
            } else {
                if movingRight { hi = mid } else { lo = mid }
            }
        }

        return movingRight ? lo : hi
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

        if viewModel.hasPetalToCollect && !viewModel.hasCollectedPetal {
            instructionLabel?.text = "Ambil kelopak bunga Forget-me-not"
            return
        }

        if viewModel.hasPetalToCollect && viewModel.hasCollectedPetal {
            instructionLabel?.text = "Tap black hole untuk keluar"
            return
        }

        guard let draggablePlatform = level.platforms.first(where: { $0.isDraggable }) else {
            return
        }

        let exitPlatformID = resolvedExitPlatformID(for: level)

        if !viewModel.isConnected {
            instructionLabel?.text = "Drag Platform B to connect the path"
        } else if exitPlatformID == draggablePlatform.id {
            instructionLabel?.text = "Tap the black hole"
        } else if viewModel.moriPlatformID == level.player.startingPlatformID {
            instructionLabel?.text = "Tap Platform B to move Mori"
        } else if !viewModel.areConnected(draggablePlatform.id, exitPlatformID) {
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
            let dragSurfaces = draggablePlatform.playableSurfaces(at: draggablePlatform.position)
            let targetSurfaces = target.playableSurfaces(at: target.position)

            let hasHeightMatch = dragSurfaces.contains { dSurf in
                targetSurfaces.contains { tSurf in
                    abs(dSurf.position.y - tSurf.position.y) <= 8
                }
            }
            guard hasHeightMatch else { continue }

            let gap: CGFloat
            let snappedX: CGFloat

            if draggablePlatform.position.x >= target.position.x {
                let targetRightEdge = target.position.x + target.model.effectiveWidth / 2
                let draggableLeftEdge = draggablePlatform.position.x - draggablePlatform.model.effectiveWidth / 2
                gap = draggableLeftEdge - targetRightEdge
                snappedX = targetRightEdge + draggablePlatform.model.effectiveWidth / 2
            } else {
                let targetLeftEdge = target.position.x - target.model.effectiveWidth / 2
                let draggableRightEdge = draggablePlatform.position.x + draggablePlatform.model.effectiveWidth / 2
                gap = targetLeftEdge - draggableRightEdge
                snappedX = targetLeftEdge - draggablePlatform.model.effectiveWidth / 2
            }

            guard gap >= 0, gap <= snapThreshold else { continue }

            if nearestTarget == nil || gap < nearestTarget!.gap {
                nearestTarget = (target, CGPoint(x: snappedX, y: draggablePlatform.position.y), gap)
            }
        }

        guard let nearestTarget else { return nil }
        return (nearestTarget.platform, nearestTarget.position)
    }
}
