import CoreGraphics

enum ForgetMeNotLevelData {
    static let mainLevelOne = GameLevel(
        id: "home-1",
        category: .home,
        interaction: .perspective,
        platforms: [
            PlatformModel(
                id: "platformA",
                horizontalPosition: 0.15,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.15, y: 0.33),
                sidePosition: CGPoint(x: 0.82, y: 0.33),
                assetName: "stone2x1"
            ),
            PlatformModel(
                id: "reverseLStone",
                horizontalPosition: 0.39,
                size: CGSize(width: 96, height: 132),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.39, y: 0.382),
                sidePosition: CGPoint(x: 0.30, y: 0.71),
                assetName: "stone2x3",
                walkableSurfaceOffset: CGPoint(x: 0, y: -22),
                blockedConnectionEdges: [.right]
            ),
            PlatformModel(
                id: "frontDeadEnd",
                horizontalPosition: 0.63,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.63, y: 0.33),
                sidePosition: CGPoint(x: 0.54, y: 0.66),
                assetName: "stone2x1"
            ),
            PlatformModel(
                id: "platformC",
                horizontalPosition: 0.584,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.584, y: 0.65),
                sidePosition: CGPoint(x: 0.584, y: 0.33),
                assetName: "stone2x1"
            ),
            PlatformModel(
                id: "lStone",
                horizontalPosition: 0.302,
                size: CGSize(width: 132, height: 96),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.302, y: 0.68),
                sidePosition: CGPoint(x: 0.302, y: 0.361),
                assetName: "stone3x2",
                walkableSurfaceOffset: CGPoint(x: 0, y: -4),
                blockedConnectionEdges: [.left]
            ),
            PlatformModel(
                id: "sideDeadEnd",
                horizontalPosition: 0.076,
                size: CGSize(width: 44, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.076, y: 0.75),
                sidePosition: CGPoint(x: 0.076, y: 0.33),
                assetName: "stone1x1"
            )
        ],
        player: PlayerModel(name: "Mori", startingPlatformID: "platformA"),
        exitPlatformID: "",
        platformHeightRatio: 0.35,
        portals: [
            PortalConfiguration(
                id: "loopPortal",
                platformID: "reverseLStone",
                offset: CGPoint(x: 0, y: 11),
                outcome: .loops(
                    to: PortalDestination(platformID: "platformA", offset: .zero)
                )
            ),
            PortalConfiguration(
                id: "correctPortal",
                platformID: "platformC",
                offset: CGPoint(x: 0, y: 55),
                outcome: .completesLevel
            )
        ],
        backgroundAssetName: "background-chapter-1"
    )

    static let mainLevelTwo = GameLevel(
        id: "home-2",
        category: .home,
        interaction: .perspectiveCompact,
        platforms: [
            PlatformModel(
                id: "platformA",
                horizontalPosition: 0.22,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.22, y: 0.52),
                sidePosition: CGPoint(x: 0.22, y: 0.33)
            ),
            PlatformModel(
                id: "platformB",
                horizontalPosition: 0.62,
                size: CGSize(width: 92, height: 44),
                isDraggable: true,
                remainsDraggableWhenConnected: true,
                frontPosition: CGPoint(x: 0.454, y: 0.33),
                sidePosition: CGPoint(x: 0.62, y: 0.33)
            ),
            PlatformModel(
                id: "platformC",
                horizontalPosition: 0.688,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.688, y: 0.33),
                sidePosition: CGPoint(x: 0.688, y: 0.52)
            )
        ],
        player: PlayerModel(name: "Mori", startingPlatformID: "platformA"),
        exitPlatformID: "platformC",
        platformHeightRatio: 0.35
    )

    static let levels = [mainLevelOne, mainLevelTwo]
}
