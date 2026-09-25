import CoreGraphics

enum TutorialLevelData {
    /// Chapter 1.0: a playable introduction shown before level 1.1.
    /// It is intentionally not part of the chapter progression nodes.
    static let chapter1Tutorial = GameLevel(
        id: "1.0",
        category: .tutorial,
        interaction: .perspectiveCompact,
        platforms: [
            PlatformModel(
                id: "tutorialStart",
                horizontalPosition: 0.20,
                size: CGSize(width: 88, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.20, y: 0.35),
                sidePosition: CGPoint(x: 0.20, y: 0.35),
                assetName: "stone2x1"
            ),
            PlatformModel(
                id: "tutorialBridge",
                horizontalPosition: 0.37,
                size: CGSize(width: 44, height: 44),
                isDraggable: true,
                remainsDraggableWhenConnected: true,
                frontPosition: CGPoint(x: 0.37, y: 0.35),
                sidePosition: CGPoint(x: 0.37, y: 0.35),
                assetName: "stone1x1"
            ),
            PlatformModel(
                id: "tutorialPetal",
                horizontalPosition: 0.70,
                size: CGSize(width: 88, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.70, y: 0.35),
                sidePosition: CGPoint(x: 0.70, y: 0.35),
                assetName: "stone2x1"
            ),
            PlatformModel(
                id: "tutorialPortal",
                horizontalPosition: 0.87,
                size: CGSize(width: 44, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.87, y: 0.56),
                sidePosition: CGPoint(x: 0.87, y: 0.35),
                assetName: "stone1x1"
            )
        ],
        player: PlayerModel(name: "Mori", startingPlatformID: "tutorialStart"),
        exitPlatformID: "tutorialPortal",
        platformHeightRatio: 0.35,
        snapRules: [
            SnapRule(
                draggablePlatformID: "tutorialBridge",
                targetPlatformIDs: ["tutorialPetal"],
                threshold: 18
            )
        ],
        initialConnections: [
            ConnectionModel(firstPlatformID: "tutorialStart", secondPlatformID: "tutorialBridge")
        ],
        petalConfiguration: PetalConfiguration(
            platformID: "tutorialPetal",
            offset: CGPoint(x: 0, y: 48),
            assetName: "forget-me-not-petal"
        ),
        portals: [
            PortalConfiguration(
                id: "tutorial-correct",
                platformID: "tutorialPortal",
                offset: CGPoint(x: 0, y: 30),
                outcome: .completesLevel,
                anchor: .walkableSurface
            )
        ],
        backgroundAssetName: "background-chapter-1",
        movementMode: .adjacentOnly
    )

    // Compatibility aliases for the existing tutorial transition/scene setup.
    static let closerLevel = chapter1Tutorial

    static let movingBridgeLevel = GameLevel(
        id: "tutorial-2",
        category: .tutorial,
        interaction: .compact,
        platforms: [
            PlatformModel(id: "platformA", horizontalPosition: 0.12, size: CGSize(width: 100, height: 50), isDraggable: false, remainsDraggableWhenConnected: false),
            PlatformModel(id: "platformB", horizontalPosition: 0.50, size: CGSize(width: 100, height: 50), isDraggable: true, remainsDraggableWhenConnected: true),
            PlatformModel(id: "platformC", horizontalPosition: 0.88, size: CGSize(width: 100, height: 50), isDraggable: false, remainsDraggableWhenConnected: false)
        ],
        player: PlayerModel(name: "Mori", startingPlatformID: "platformA"),
        exitPlatformID: "platformC",
        platformHeightRatio: 0.35
    )

    static let levels = [chapter1Tutorial]
}
