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
    private var exitNode: ExitNode?
    private var petalNode: PetalNode?
    private var instructionLabel: SKLabelNode?
    private var perspectiveSwipeStart: CGPoint?
    private var isRestartingLevel = false

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
              moriNode.action(forKey: "moriMove") == nil,
              moriNode.action(forKey: "perspectiveMove") == nil,
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
        case .congratulations(let goalID):
            renderCongratulations(goalID)
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

    private func renderCongratulations(_ goalID: GoalID) {
        removeAllChildren()
        addChild(CongratulationsView(sceneSize: size, goalID: goalID))
    }

    private func renderMap() {
        removeAllChildren()
        addChild(MapView(sceneSize: size))
    }

    private func renderLevel() {
        removeAllChildren()
        platformNodes.removeAll()
        draggedPlatform = nil
        moriNode = nil
        exitNode = nil
        petalNode = nil

        let level = viewModel.currentLevel
        for platform in level.platforms {
            let node = PlatformNode(model: platform)
            node.position = position(for: platform)
            addChild(node)
            platformNodes[platform.id] = node
        }

        viewModel.setConnections(level.initialConnections)

        if level.usesPerspective {
            updatePerspectiveConnections()
        }

        // Add Petal if level defines one
        if let petalConfig = level.petalConfiguration {
            let petal = PetalNode(platformID: petalConfig.platformID)
            petal.position = petalConfig.offset
            petal.zPosition = 10
            platformNodes[petalConfig.platformID]?.addChild(petal)
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
        addChild(mori)
        moriNode = mori

        let exitPlatformID = resolvedExitPlatformID(for: level)
        if level.interaction != .perspective,
           let exitPlatform = level.platforms.first(where: { $0.id == exitPlatformID }) {
            let exit = ExitNode()
            exit.position = level.exitConfiguration?.offset ?? CGPoint(x: 45, y: 55)
            exit.zPosition = 10
            exit.setLocked(viewModel.hasPetalToCollect && !viewModel.hasCollectedPetal)
            platformNodes[exitPlatform.id]?.addChild(exit)
            exitNode = exit
        }

        createInstructionLabel()
        updateInstruction()
        renderChapterProgressHUD()

        checkPetalCollection(at: level.player.startingPlatformID)
    }

    private func renderChapterProgressHUD() {
        let levelID = viewModel.currentLevel.id
        guard let goalID = appFlow.activeGoalID ?? LevelCatalog.goalID(for: levelID),
              let goal = FlowerGoalData.goal(for: goalID),
              let currentLevelIndex = goal.levelIDs.firstIndex(where: { LevelCatalog.canonicalID(for: $0) == LevelCatalog.canonicalID(for: levelID) }) else {
            return
        }

        let hudContainer = SKNode()
        hudContainer.name = "chapterProgressHUD"
        hudContainer.position = CGPoint(x: 24, y: size.height - 40)
        hudContainer.zPosition = 100

        let icon = SKSpriteNode(imageNamed: goal.petalAssetName)
        icon.size = CGSize(width: 28, height: 20)
        icon.position = CGPoint(x: 14, y: 0)
        hudContainer.addChild(icon)

        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = "\(currentLevelIndex + 1)/\(goal.levelIDs.count)"
        label.fontSize = 16
        label.fontColor = SKColor(red: 0.22, green: 0.24, blue: 0.30, alpha: 1.0)
        label.horizontalAlignmentMode = .left
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: 34, y: 0)
        hudContainer.addChild(label)

        addChild(hudContainer)
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
        case .congratulations:
            appFlow.openMap()
            renderCurrentScreen()
        case .map:
            startMapLevel(at: touch.location(in: self))
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
                guard appFlow.isLevelUnlocked(levelID) else { return }
                appFlow.startLevel(levelID)
                return
            }
            touchedNode = node.parent
        }
    }

    private func startMapLevel(at location: CGPoint) {
        var touchedNode: SKNode? = atPoint(location)

        while let node = touchedNode {
            if let name = node.name {
                if name.hasPrefix("start-chapter-") {
                    let chapterID = String(name.dropFirst("start-chapter-".count))
                    appFlow.startChapter(chapterID)
                    return
                } else if name.hasPrefix("start-level-") {
                    let levelID = String(name.dropFirst("start-level-".count))
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
        let exitPlatformID = resolvedExitPlatformID(for: viewModel.currentLevel)

        // Exit touched
        if exitNode(at: touchLocation) != nil {
            if viewModel.hasPetalToCollect && !viewModel.hasCollectedPetal {
                exitNode?.playShake()
                showPetalRequiredNotice()
                return
            }

            if viewModel.moriPlatformID == exitPlatformID {
                enterExit()
                return
            }

            if viewModel.canMoveMori(to: exitPlatformID) {
                moveMori(to: exitPlatformID, completesLevel: true)
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
               petalNode(at: touchLocation) == nil,
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

            if playerNode(at: touchLocation) == nil,
               petalNode(at: touchLocation) == nil {
                perspectiveSwipeStart = touchLocation
            }
            return
        }

        guard let platform = platformNode(at: touchLocation) else { return }

        if viewModel.canMoveMori(to: platform.model.id) {
            moveMori(to: platform.model.id, completesLevel: false)
            return
        }

        guard platform.model.isDraggable else { return }

        guard !viewModel.isConnected
                || (platform.model.remainsDraggableWhenConnected
                    && !viewModel.areConnected(platform.model.id, exitPlatformID)) else {
            return
        }

        draggedPlatform = platform
        dragTouchOffsetX = touchLocation.x - platform.position.x
        didDragPlatform = false
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard case .gameplay = appFlow.screen else { return }
        guard viewModel.currentLevel.allowsCompact else { return }
        guard let touch = touches.first, let platform = draggedPlatform else { return }

        let touchLocation = touch.location(in: self)
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
            didDragPlatform = true
            viewModel.disconnectSnap(for: platform.model.id)
        }

        platform.position.x = constrainedX

        if viewModel.moriPlatformID == platform.model.id {
            moriNode?.position.x += horizontalChange
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard case .gameplay = appFlow.screen else { return }

        if viewModel.currentLevel.usesPerspective {
            if viewModel.currentLevel.interaction == .perspectiveCompact, didDragPlatform {
                if !attemptSnapIfNeeded() {
                    viewModel.disconnectSnap(for: draggedPlatform?.model.id)
                    // Recalculate koneksi berdasarkan posisi aktual setelah drag selesai
                    updatePerspectiveConnectionsUsingActualPositions()
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
            viewModel.disconnectSnap(for: draggedPlatform?.model.id)
        }
        perspectiveSwipeStart = nil
        draggedPlatform = nil
        didDragPlatform = false
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
        let platforms = viewModel.currentLevel.platforms
        var newConnections: [ConnectionModel] = []
        let maximumGap: CGFloat = 25
        let maximumVerticalDifference: CGFloat = 2

        for firstIndex in platforms.indices {
            for secondIndex in platforms.indices.dropFirst(firstIndex + 1) {
                let firstPlatform = platforms[firstIndex]
                let secondPlatform = platforms[secondIndex]
                let firstPosition = position(for: firstPlatform)
                let secondPosition = position(for: secondPlatform)
                let horizontalDistance = abs(firstPosition.x - secondPosition.x)
                let combinedHalfWidths = (firstPlatform.effectiveWidth + secondPlatform.effectiveWidth) / 2
                let edgeGap = horizontalDistance - combinedHalfWidths
                let verticalDifference = abs(firstPosition.y - secondPosition.y)

                if abs(edgeGap) <= maximumGap, verticalDifference <= maximumVerticalDifference {
                    if !isHopPathBlocked(from: firstPosition, to: secondPosition, excluding: [firstPlatform.id, secondPlatform.id], usingLayoutPositions: true) {
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
        let platforms = viewModel.currentLevel.platforms
        var newConnections: [ConnectionModel] = []
        let maximumGap: CGFloat = 25
        let maximumVerticalDifference: CGFloat = 2

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
                let verticalDifference = abs(firstPosition.y - secondPosition.y)

                if abs(edgeGap) <= maximumGap, verticalDifference <= maximumVerticalDifference {
                    if !isHopPathBlocked(from: firstPosition, to: secondPosition, excluding: [firstPlatform.id, secondPlatform.id], usingLayoutPositions: false) {
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
        excluding excludedIDs: Set<String>,
        usingLayoutPositions: Bool = true
    ) -> Bool {
        for (id, node) in platformNodes {
            if excludedIDs.contains(id) { continue }
            guard let model = viewModel.currentLevel.platforms.first(where: { $0.id == id }) else { continue }
            let pos = usingLayoutPositions ? position(for: model) : node.position
            let cellRects = node.occupiedCellRects(at: pos)
            for rect in cellRects {
                let insetRect = rect.insetBy(dx: 2, dy: 2)
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
        guard let petal = petalNode,
              !petal.isCollected,
              platformID == petal.platformID else { return }

        viewModel.collectPetal()
        HapticManager.playSnapFeedback()
        petal.collect { [weak self] in
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
        level.exitConfiguration?.platformID ?? level.exitPlatformID
    }

    private func isMoriSupported(_ mori: PlayerNode) -> Bool {
        platformNodes.values.contains { platform in
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

    private func enterExit() {
        guard let moriNode, !viewModel.hasReachedExit else { return }
        viewModel.markExitReached()
        print("Mori reached the exit")

        if let exitNode {
            let exitCenter = exitNode.convert(CGPoint.zero, to: self)
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

    private func moveMori(to platformID: String, completesLevel: Bool) {
        guard let moriNode, moriNode.action(forKey: "moriMove") == nil else { return }

        if completesLevel && viewModel.moriPlatformID == platformID {
            enterExit()
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
                self?.viewModel.moveMori(to: nextPlatformID)
                self?.checkPetalCollection(at: nextPlatformID)
            }
            movementActions.append(stepArrival)
            previousPosition = destination
        }

        if completesLevel, let exitNode {
            let exitDestination = exitNode.convert(CGPoint.zero, to: self)
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
                self?.enterExit()
            })
        } else {
            movementActions.append(SKAction.run { [weak self, weak moriNode] in
                moriNode?.playIdle()
                self?.updateInstruction()
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
        platformB.run(.group([move, bounce])) { [weak self] in
            // Gunakan posisi aktual (bukan layout) agar koneksi terbentuk
            // berdasarkan posisi fisik balok setelah di-snap
            self?.updatePerspectiveConnectionsUsingActualPositions()
        }
        HapticManager.playSnapFeedback()
        updateInstruction()
        return true
    }

    private func isPlacementValid(for draggablePlatform: PlatformNode, at proposedPosition: CGPoint) -> Bool {
        let proposedRects = draggablePlatform.occupiedCellRects(at: proposedPosition)

        for rect in proposedRects {
            if rect.minX < GameConstants.Layout.horizontalMargin || rect.maxX > size.width - GameConstants.Layout.horizontalMargin {
                return false
            }
        }

        for target in platformNodes.values where target.model.id != draggablePlatform.model.id && !target.model.isDraggable {
            let targetRects = target.occupiedCellRects(at: target.position)
            for pRect in proposedRects {
                for tRect in targetRects {
                    let intersection = pRect.intersection(tRect)
                    if !intersection.isNull && intersection.width > 1 && intersection.height > 1 {
                        return false
                    }
                }
            }
        }

        return true
    }

    private func constrainedPlatformX(
        for draggablePlatform: PlatformNode,
        proposedX: CGFloat,
        previousX: CGFloat
    ) -> CGFloat {
        if draggablePlatform.model.shape == .single1x1 {
            var constrainedX = proposedX
            let halfDraggableWidth = draggablePlatform.model.effectiveWidth / 2

            for target in platformNodes.values where !target.model.isDraggable {
                let halfTargetWidth = target.model.effectiveWidth / 2
                if previousX > target.position.x, proposedX < previousX {
                    let nearestRightPosition = target.position.x + halfTargetWidth + halfDraggableWidth
                    if previousX >= nearestRightPosition, proposedX < nearestRightPosition {
                        constrainedX = max(constrainedX, nearestRightPosition)
                    }
                }

                if previousX < target.position.x, proposedX > previousX {
                    let nearestLeftPosition = target.position.x - halfTargetWidth - halfDraggableWidth
                    if previousX <= nearestLeftPosition, proposedX > nearestLeftPosition {
                        constrainedX = min(constrainedX, nearestLeftPosition)
                    }
                }
            }

            return constrainedX
        }

        let proposedPosition = CGPoint(x: proposedX, y: draggablePlatform.position.y)
        if isPlacementValid(for: draggablePlatform, at: proposedPosition) {
            return proposedX
        }

        var candidateX = previousX
        let step: CGFloat = (proposedX > previousX) ? 1.0 : -1.0

        while (step > 0 ? candidateX < proposedX : candidateX > proposedX) {
            let nextX = candidateX + step
            if isPlacementValid(for: draggablePlatform, at: CGPoint(x: nextX, y: draggablePlatform.position.y)) {
                candidateX = nextX
            } else {
                break
            }
        }

        return candidateX
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

        if !viewModel.isConnected {
            instructionLabel?.text = "Drag Platform B to connect the path"
        } else if resolvedExitPlatformID(for: level) == draggablePlatform.id {
            instructionLabel?.text = "Tap the black hole"
        } else if viewModel.moriPlatformID == level.player.startingPlatformID {
            instructionLabel?.text = "Tap Platform B to move Mori"
        } else if !viewModel.areConnected(draggablePlatform.id, resolvedExitPlatformID(for: level)) {
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

        for target in platformNodes.values where !target.model.isDraggable {
            if let snapRule, !snapRule.targetPlatformIDs.contains(target.model.id) {
                continue
            }
            guard abs(draggablePlatform.position.y - target.position.y) <= 2 else { continue }

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
