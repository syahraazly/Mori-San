import CoreGraphics

enum BalineseFrangipaniLevelData {
    static let levelOne = GameLevel(
        id: "balinese-1",
        category: .family,
        interaction: .perspective,
        platforms: [
            PlatformModel(
                id: "start",
                horizontalPosition: 0.10,
                size: CGSize(width: 44, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.10, y: 0.70),
                sidePosition: CGPoint(x: 0.10, y: 0.67),
                assetName: "stone1x1"
            ),
            PlatformModel(
                id: "pathA",
                horizontalPosition: 0.24,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.28, y: 0.70),
                sidePosition: CGPoint(x: 0.28, y: 0.67),
                assetName: "stone2x1"
            ),
            PlatformModel(
                id: "junctionB",
                horizontalPosition: 0.45,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.52, y: 0.70),
                sidePosition: CGPoint(x: 0.52, y: 0.67),
                assetName: "stone2x1"
            ),
            PlatformModel(
                id: "reverseLStone",
                horizontalPosition: 0.83,
                size: CGSize(width: 132, height: 96),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.83, y: 0.7282),
                sidePosition: CGPoint(x: 0.83, y: 0.45),
                assetName: "stone2x3",
                visualSize: CGSize(width: 132, height: 96),
                walkableSurfaceOffset: CGPoint(x: 0, y: -2),
                blockedConnectionEdges: [.right]
            ),
            PlatformModel(
                id: "falsePortalPlatform",
                horizontalPosition: 0.50,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.52, y: 0.50),
                sidePosition: CGPoint(x: 0.76, y: 0.67),
                assetName: "stone2x1"
            ),
            PlatformModel(
                id: "junctionE",
                horizontalPosition: 0.15,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.15, y: 0.18),
                sidePosition: CGPoint(x: 0.15, y: 0.26),
                assetName: "stone2x1"
            ),
            PlatformModel(
                id: "lStone",
                horizontalPosition: 0.45,
                size: CGSize(width: 132, height: 96),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.70, y: 0.48),
                sidePosition: CGPoint(x: 0.45, y: 0.2882),
                assetName: "stone3x2",
                visualSize: CGSize(width: 132, height: 96),
                walkableSurfaceOffset: CGPoint(x: 0, y: -2),
                blockedConnectionEdges: [.right]
            ),
            PlatformModel(
                id: "pathF",
                horizontalPosition: 0.44,
                size: CGSize(width: 132, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.44, y: 0.18),
                sidePosition: CGPoint(x: 0.44, y: 0.11),
                assetName: "stone3x1"
            ),
            PlatformModel(
                id: "pathG",
                horizontalPosition: 0.74,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.74, y: 0.18),
                sidePosition: CGPoint(x: 0.74, y: 0.11),
                assetName: "stone2x1"
            ),
            PlatformModel(
                id: "correctPortalPlatform",
                horizontalPosition: 0.92,
                size: CGSize(width: 44, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.92, y: 0.18),
                sidePosition: CGPoint(x: 0.92, y: 0.11),
                assetName: "stone1x1"
            )
        ],
        player: PlayerModel(name: "Mori", startingPlatformID: "start"),
        exitPlatformID: "",
        platformHeightRatio: 0.35,
        initialConnections: [],
        portals: [
            PortalConfiguration(
                id: "loopPortal",
                platformID: "falsePortalPlatform",
                offset: CGPoint(x: 0, y: 30),
                outcome: .loops(
                    to: PortalDestination(platformID: "junctionE", offset: .zero)
                ),
                anchor: .walkableSurface
            ),
            PortalConfiguration(
                id: "correctPortal",
                platformID: "correctPortalPlatform",
                offset: CGPoint(x: 0, y: 30),
                outcome: .completesLevel,
                anchor: .walkableSurface
            )
        ],
        backgroundAssetName: "background-chapter-1",
        movementMode: .adjacentOnly,
        usesProximityConnections: true
    )

    static let levels = [levelOne]
}
