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
                assetName: "stone1x1",
                shape: .single1x1
            ),
            PlatformModel(
                id: "pathA",
                horizontalPosition: 0.24,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.28, y: 0.70),
                sidePosition: CGPoint(x: 0.28, y: 0.67),
                assetName: "stone2x1",
                shape: .horizontal1x2
            ),
            PlatformModel(
                id: "junctionB",
                horizontalPosition: 0.45,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.52, y: 0.70),
                sidePosition: CGPoint(x: 0.52, y: 0.67),
                assetName: "stone2x1",
                shape: .horizontal1x2
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
                blockedConnectionEdges: [.right],
                shape: .reverseLShape
            ),
            PlatformModel(
                id: "falsePortalPlatform",
                horizontalPosition: 0.50,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.52, y: 0.50),
                sidePosition: CGPoint(x: 0.76, y: 0.67),
                assetName: "stone2x1",
                shape: .horizontal1x2
            ),
            PlatformModel(
                id: "junctionE",
                horizontalPosition: 0.15,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.15, y: 0.18),
                sidePosition: CGPoint(x: 0.15, y: 0.26),
                assetName: "stone2x1",
                shape: .horizontal1x2
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
                blockedConnectionEdges: [.right],
                shape: .lShape
            ),
            PlatformModel(
                id: "pathF",
                horizontalPosition: 0.44,
                size: CGSize(width: 132, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.44, y: 0.18),
                sidePosition: CGPoint(x: 0.44, y: 0.11),
                assetName: "stone3x1",
                shape: .horizontal1x3
            ),
            PlatformModel(
                id: "pathG",
                horizontalPosition: 0.74,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.74, y: 0.18),
                sidePosition: CGPoint(x: 0.74, y: 0.11),
                assetName: "stone2x1",
                shape: .horizontal1x2
            ),
            PlatformModel(
                id: "correctPortalPlatform",
                horizontalPosition: 0.92,
                size: CGSize(width: 44, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.92, y: 0.18),
                sidePosition: CGPoint(x: 0.92, y: 0.11),
                assetName: "stone1x1",
                shape: .single1x1
            )
        ],
        player: PlayerModel(name: "Mori", startingPlatformID: "start"),
        exitPlatformID: "",
        platformHeightRatio: 0.35,
        initialConnections: [],
        petalConfiguration: PetalConfiguration(
            platformID: "pathG",
            offset: CGPoint(x: 0, y: 48),
            assetName: "kamboja-bali-petal"
        ),
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
        movementMode: .pathfinding,
        usesProximityConnections: true,
        proximityConnectionTolerance: 28
    )

    // Level 3.2: perspective reveals the route beyond the L-shaped dead end.
    static let levelTwo = GameLevel(
        id: "balinese-2",
        category: .family,
        interaction: .perspective,
        platforms: [
            stone(id: "start", asset: "stone1x1", size: CGSize(width: 44, height: 44), shape: .single1x1, front: CGPoint(x: 0.12, y: 0.62), side: CGPoint(x: 0.08, y: 0.20)),
            stone(id: "pathA", asset: "stone2x1", size: CGSize(width: 92, height: 44), shape: .horizontal1x2, front: CGPoint(x: 0.29, y: 0.62), side: CGPoint(x: 0.23, y: 0.50)),
            lStone(id: "deadEnd", asset: "stone2x3", shape: .reverseLShape, front: CGPoint(x: 0.58, y: 0.6484), side: CGPoint(x: 0.80, y: 0.22), blockedEdges: [.right]),
            stone(id: "pathB", asset: "stone1x1", size: CGSize(width: 44, height: 44), shape: .single1x1, front: CGPoint(x: 0.18, y: 0.25), side: CGPoint(x: 0.405, y: 0.50)),
            stone(id: "petalStone", asset: "stone1x1", size: CGSize(width: 44, height: 44), shape: .single1x1, front: CGPoint(x: 0.40, y: 0.25), side: CGPoint(x: 0.518, y: 0.50)),
            stone(id: "portalStone", asset: "stone2x1", size: CGSize(width: 92, height: 44), shape: .horizontal1x2, front: CGPoint(x: 0.75, y: 0.25), side: CGPoint(x: 0.692, y: 0.50))
        ],
        player: PlayerModel(name: "Mori", startingPlatformID: "start"),
        exitPlatformID: "",
        platformHeightRatio: 0.35,
        petalConfiguration: PetalConfiguration(platformID: "petalStone", assetName: "kamboja-bali-petal"),
        portals: [
            PortalConfiguration(id: "correctPortal", platformID: "portalStone", offset: CGPoint(x: 0, y: 30), outcome: .completesLevel, anchor: .walkableSurface)
        ],
        backgroundAssetName: "background-chapter-1",
        movementMode: .adjacentOnly,
        usesProximityConnections: true
    )

    // Level 3.3: the false portal returns Mori to A, where a new POV reveals the petal route.
    static let levelThree = GameLevel(
        id: "balinese-3",
        category: .family,
        interaction: .perspective,
        platforms: [
            lStone(id: "deadEnd", asset: "stone3x2", shape: .lShape, front: CGPoint(x: 0.18, y: 0.6484), side: CGPoint(x: 0.18, y: 0.22), blockedEdges: [.left]),
            stone(id: "start", asset: "stone1x1", size: CGSize(width: 44, height: 44), shape: .single1x1, front: CGPoint(x: 0.405, y: 0.62), side: CGPoint(x: 0.08, y: 0.20)),
            stone(id: "pathA", asset: "stone2x1", size: CGSize(width: 92, height: 44), shape: .horizontal1x2, front: CGPoint(x: 0.58, y: 0.62), side: CGPoint(x: 0.24, y: 0.50)),
            stone(id: "falsePortalStone", asset: "stone2x1", size: CGSize(width: 92, height: 44), shape: .horizontal1x2, front: CGPoint(x: 0.815, y: 0.62), side: CGPoint(x: 0.75, y: 0.20)),
            stone(id: "pathB", asset: "stone1x1", size: CGSize(width: 44, height: 44), shape: .single1x1, front: CGPoint(x: 0.18, y: 0.25), side: CGPoint(x: 0.415, y: 0.50)),
            stone(id: "petalStone", asset: "stone1x1", size: CGSize(width: 44, height: 44), shape: .single1x1, front: CGPoint(x: 0.40, y: 0.25), side: CGPoint(x: 0.528, y: 0.50)),
            stone(id: "correctPortalStone", asset: "stone2x1", size: CGSize(width: 92, height: 44), shape: .horizontal1x2, front: CGPoint(x: 0.75, y: 0.25), side: CGPoint(x: 0.702, y: 0.50))
        ],
        player: PlayerModel(name: "Mori", startingPlatformID: "start"),
        exitPlatformID: "",
        platformHeightRatio: 0.35,
        petalConfiguration: PetalConfiguration(platformID: "petalStone", assetName: "kamboja-bali-petal"),
        portals: [
            PortalConfiguration(id: "falsePortal", platformID: "falsePortalStone", offset: CGPoint(x: 0, y: 30), outcome: .loops(to: PortalDestination(platformID: "pathA", offset: .zero)), anchor: .walkableSurface),
            PortalConfiguration(id: "correctPortal", platformID: "correctPortalStone", offset: CGPoint(x: 0, y: 30), outcome: .completesLevel, anchor: .walkableSurface)
        ],
        backgroundAssetName: "background-chapter-1",
        movementMode: .adjacentOnly,
        usesProximityConnections: true
    )

    // Level 3.4: two perspective changes are needed to reach the petal, then the portal.
    static let levelFour = GameLevel(
        id: "balinese-4",
        category: .family,
        interaction: .perspective,
        platforms: [
            stone(id: "start", asset: "stone1x1", size: CGSize(width: 44, height: 44), shape: .single1x1, front: CGPoint(x: 0.12, y: 0.64), side: CGPoint(x: 0.08, y: 0.20)),
            stone(id: "pathA", asset: "stone2x1", size: CGSize(width: 92, height: 44), shape: .horizontal1x2, front: CGPoint(x: 0.295, y: 0.64), side: CGPoint(x: 0.30, y: 0.22)),
            stone(id: "pathB", asset: "stone1x1", size: CGSize(width: 44, height: 44), shape: .single1x1, front: CGPoint(x: 0.47, y: 0.64), side: CGPoint(x: 0.20, y: 0.50)),
            lStone(id: "deadEnd", asset: "stone2x3", shape: .reverseLShape, front: CGPoint(x: 0.695, y: 0.6684), side: CGPoint(x: 0.80, y: 0.22), blockedEdges: [.right]),
            stone(id: "petalStone", asset: "stone1x1", size: CGSize(width: 44, height: 44), shape: .single1x1, front: CGPoint(x: 0.14, y: 0.30), side: CGPoint(x: 0.549, y: 0.50)),
            stone(id: "pathD", asset: "stone2x1", size: CGSize(width: 92, height: 44), shape: .horizontal1x2, front: CGPoint(x: 0.313, y: 0.30), side: CGPoint(x: 0.375, y: 0.50)),
            stone(id: "pathC", asset: "stone1x1", size: CGSize(width: 44, height: 44), shape: .single1x1, front: CGPoint(x: 0.487, y: 0.30), side: CGPoint(x: 0.45, y: 0.24)),
            stone(id: "portalStone", asset: "stone2x1", size: CGSize(width: 92, height: 44), shape: .horizontal1x2, front: CGPoint(x: 0.662, y: 0.30), side: CGPoint(x: 0.624, y: 0.24))
        ],
        player: PlayerModel(name: "Mori", startingPlatformID: "start"),
        exitPlatformID: "",
        platformHeightRatio: 0.35,
        petalConfiguration: PetalConfiguration(platformID: "petalStone", assetName: "kamboja-bali-petal"),
        portals: [
            PortalConfiguration(id: "correctPortal", platformID: "portalStone", offset: CGPoint(x: 0, y: 30), outcome: .completesLevel, anchor: .walkableSurface)
        ],
        backgroundAssetName: "background-chapter-1",
        movementMode: .adjacentOnly,
        usesProximityConnections: true
    )

    // Level 3.5: final compact/perspective mix, including a loop that returns Mori to the central junction.
    static let levelFive = GameLevel(
        id: "balinese-5",
        category: .family,
        interaction: .perspectiveCompact,
        platforms: [
            stone(id: "start", asset: "stone1x1", size: CGSize(width: 44, height: 44), shape: .single1x1, front: CGPoint(x: 0.10, y: 0.58), side: CGPoint(x: 0.10, y: 0.44)),
            stone(id: "junction", asset: "stone2x1", size: CGSize(width: 92, height: 44), shape: .horizontal1x2, front: CGPoint(x: 0.28, y: 0.58), side: CGPoint(x: 0.28, y: 0.44)),
            stone(id: "bridge", asset: "stone3x1", size: CGSize(width: 132, height: 44), shape: .horizontal1x3, front: CGPoint(x: 0.58, y: 0.70), side: CGPoint(x: 0.58, y: 0.44), draggable: true),
            lStone(id: "upperDeadEnd", asset: "stone2x3", shape: .reverseLShape, front: CGPoint(x: 0.82, y: 0.7273), side: CGPoint(x: 0.82, y: 0.22), blockedEdges: [.right]),
            stone(id: "falsePortalStone", asset: "stone2x1", size: CGSize(width: 92, height: 44), shape: .horizontal1x2, front: CGPoint(x: 0.58, y: 0.30), side: CGPoint(x: 0.58, y: 0.62)),
            lStone(id: "lowerTurn", asset: "stone3x2", shape: .lShape, front: CGPoint(x: 0.30, y: 0.1427), side: CGPoint(x: 0.30, y: 0.1427), blockedEdges: [.right]),
            stone(id: "correctPortalStone", asset: "stone2x1", size: CGSize(width: 92, height: 44), shape: .horizontal1x2, front: CGPoint(x: 0.76, y: 0.30), side: CGPoint(x: 0.76, y: 0.62))
        ],
        player: PlayerModel(name: "Mori", startingPlatformID: "start"),
        exitPlatformID: "",
        platformHeightRatio: 0.35,
        snapRules: [SnapRule(draggablePlatformID: "bridge", targetPlatformIDs: ["upperDeadEnd", "correctPortalStone"], threshold: 42)],
        petalConfiguration: PetalConfiguration(platformID: "bridge", assetName: "kamboja-bali-petal"),
        portals: [
            PortalConfiguration(id: "falsePortal", platformID: "falsePortalStone", offset: CGPoint(x: 0, y: 30), outcome: .loops(to: PortalDestination(platformID: "junction", offset: .zero)), anchor: .walkableSurface),
            PortalConfiguration(id: "correctPortal", platformID: "correctPortalStone", offset: CGPoint(x: 0, y: 30), outcome: .completesLevel, anchor: .walkableSurface)
        ],
        backgroundAssetName: "background-chapter-1",
        movementMode: .pathfinding,
        usesProximityConnections: true
    )

    static let levels = [levelOne, levelTwo, levelThree, levelFour, levelFive]

    private static func stone(
        id: String,
        asset: String,
        size: CGSize,
        shape: BlockShape,
        front: CGPoint,
        side: CGPoint,
        draggable: Bool = false
    ) -> PlatformModel {
        PlatformModel(
            id: id,
            horizontalPosition: front.x,
            size: size,
            isDraggable: draggable,
            remainsDraggableWhenConnected: draggable,
            frontPosition: front,
            sidePosition: side,
            assetName: asset,
            shape: shape
        )
    }

    private static func lStone(
        id: String,
        asset: String,
        shape: BlockShape,
        front: CGPoint,
        side: CGPoint,
        blockedEdges: Set<PlatformEdge>
    ) -> PlatformModel {
        PlatformModel(
            id: id,
            horizontalPosition: front.x,
            size: CGSize(width: 132, height: 96),
            isDraggable: false,
            remainsDraggableWhenConnected: false,
            frontPosition: front,
            sidePosition: side,
            assetName: asset,
            visualSize: CGSize(width: 132, height: 96),
            walkableSurfaceOffset: CGPoint(x: 0, y: -2),
            blockedConnectionEdges: blockedEdges,
            shape: shape
        )
    }
}
