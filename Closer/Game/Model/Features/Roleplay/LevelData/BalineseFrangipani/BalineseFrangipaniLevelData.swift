import CoreGraphics

enum BalineseFrangipaniLevelData {
    static let levelOne = GameLevel(
        id: "balinese-1",
        category: .family,
        interaction: .perspectiveCompact,
        platforms: [
            stone(id: "start", asset: "stone1x1", size: CGSize(width: 44, height: 44), shape: .single1x1, front: CGPoint(x: 0.12, y: 0.65), side: CGPoint(x: 0.12, y: 0.65)),
            stone(id: "blueBridge", asset: "stone2x1", size: CGSize(width: 92, height: 44), shape: .horizontal1x2, front: CGPoint(x: 0.29, y: 0.65), side: CGPoint(x: 0.50, y: 0.37), draggable: true),
            stone(id: "greenTarget", asset: "stone1x1", size: CGSize(width: 44, height: 44), shape: .single1x1, front: CGPoint(x: 0.70, y: 0.65), side: CGPoint(x: 0.70, y: 0.65)),
            stone(id: "returnPlatform", asset: "stone2x1", size: CGSize(width: 92, height: 44), shape: .horizontal1x2, front: CGPoint(x: 0.20, y: 0.18), side: CGPoint(x: 0.20, y: 0.18)),
            stone(id: "petalStone", asset: "stone1x1", size: CGSize(width: 44, height: 44), shape: .single1x1, front: CGPoint(x: 0.37, y: 0.18), side: CGPoint(x: 0.37, y: 0.18)),
            stone(id: "correctPortalPlatform", asset: "stone2x1", size: CGSize(width: 92, height: 44), shape: .horizontal1x2, front: CGPoint(x: 0.54, y: 0.18), side: CGPoint(x: 0.54, y: 0.18)),
            PlatformModel(
                id: "lowerLObstacle",
                horizontalPosition: 0.77,
                size: CGSize(width: 132, height: 96),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.77, y: 0.32),
                sidePosition: CGPoint(x: 0.77, y: 0.32),
                role: .obstacle,
                assetName: "stone3x2",
                visualSize: CGSize(width: 132, height: 96),
                shape: .lShape
            )
        ],
        player: PlayerModel(name: "Mori", startingPlatformID: "start"),
        exitPlatformID: "",
        platformHeightRatio: 0.35,
        snapRules: [SnapRule(draggablePlatformID: "blueBridge", targetPlatformIDs: ["greenTarget"], threshold: 42)],
        petalConfiguration: PetalConfiguration(
            platformID: "petalStone",
            offset: CGPoint(x: 0, y: 48),
            assetName: "kamboja-bali-petal"
        ),
        portals: [
            PortalConfiguration(
                id: "loopPortal",
                platformID: "greenTarget",
                offset: CGPoint(x: 0, y: 30),
                outcome: .loops(
                    to: PortalDestination(platformID: "returnPlatform", offset: .zero)
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
        backgroundAssetName: "background-chapter-3",
        movementMode: .adjacentOnly,
        usesProximityConnections: true
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
        backgroundAssetName: "background-chapter-3",
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
        backgroundAssetName: "background-chapter-3",
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
        backgroundAssetName: "background-chapter-3",
        movementMode: .adjacentOnly,
        usesProximityConnections: true
    )

    // Level 3.5: the lamp reveals a route, then a petal-driven POV change opens the exit.
    static let levelFive = GameLevel(
        id: "balinese-5",
        category: .family,
        interaction: .perspective,
        platforms: [
            stone(id: "start", asset: "stone1x1", size: CGSize(width: 44, height: 44), shape: .single1x1, front: CGPoint(x: 0.10, y: 0.58), side: CGPoint(x: 0.10, y: 0.58)),
            stone(id: "pathA", asset: "stone1x1", size: CGSize(width: 44, height: 44), shape: .single1x1, front: CGPoint(x: 0.213, y: 0.58), side: CGPoint(x: 0.213, y: 0.58)),
            stone(id: "lampStone", asset: "stone1x1", size: CGSize(width: 44, height: 44), shape: .single1x1, front: CGPoint(x: 0.326, y: 0.58), side: CGPoint(x: 0.326, y: 0.58)),
            stone(id: "hiddenB", asset: "stone1x1", size: CGSize(width: 44, height: 44), shape: .single1x1, front: CGPoint(x: 0.439, y: 0.58), side: CGPoint(x: 0.439, y: 0.58)),
            stone(id: "hiddenC", asset: "stone1x1", size: CGSize(width: 44, height: 44), shape: .single1x1, front: CGPoint(x: 0.552, y: 0.58), side: CGPoint(x: 0.552, y: 0.58)),
            stone(id: "pathD", asset: "stone1x1", size: CGSize(width: 44, height: 44), shape: .single1x1, front: CGPoint(x: 0.70, y: 0.40), side: CGPoint(x: 0.665, y: 0.58)),
            stone(id: "petalStone", asset: "stone1x1", size: CGSize(width: 44, height: 44), shape: .single1x1, front: CGPoint(x: 0.813, y: 0.40), side: CGPoint(x: 0.778, y: 0.58)),
            stone(id: "correctPortalStone", asset: "stone1x1", size: CGSize(width: 44, height: 44), shape: .single1x1, front: CGPoint(x: 0.90, y: 0.40), side: CGPoint(x: 0.90, y: 0.38)),
            PlatformModel(
                id: "lightObstacle",
                horizontalPosition: 0.62,
                size: CGSize(width: 132, height: 96),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.62, y: 0.30),
                sidePosition: CGPoint(x: 0.77, y: 0.30),
                role: .obstacle,
                assetName: "stone3x2",
                visualSize: CGSize(width: 132, height: 96),
                shape: .lShape
            )
        ],
        player: PlayerModel(name: "Mori", startingPlatformID: "start"),
        exitPlatformID: "",
        platformHeightRatio: 0.35,
        initialConnections: [
            ConnectionModel(firstPlatformID: "start", secondPlatformID: "pathA"),
            ConnectionModel(firstPlatformID: "pathA", secondPlatformID: "lampStone")
        ],
        petalConfiguration: PetalConfiguration(
            platformID: "petalStone",
            assetName: "kamboja-bali-petal",
            perspectivePositionOverrides: [
                PerspectivePositionOverride(platformID: "hiddenB", frontPosition: CGPoint(x: 0.24, y: 0.30)),
                PerspectivePositionOverride(platformID: "pathD", frontPosition: CGPoint(x: 0.665, y: 0.58)),
                PerspectivePositionOverride(platformID: "petalStone", frontPosition: CGPoint(x: 0.778, y: 0.58)),
                PerspectivePositionOverride(platformID: "correctPortalStone", frontPosition: CGPoint(x: 0.439, y: 0.58))
            ]
        ),
        portals: [
            PortalConfiguration(id: "correctPortal", platformID: "correctPortalStone", offset: CGPoint(x: 0, y: 30), outcome: .completesLevel, anchor: .walkableSurface)
        ],
        backgroundAssetName: "background-chapter-3",
        movementMode: .adjacentOnly,
        usesProximityConnections: true,
        lightRevealConfiguration: LightRevealConfiguration(
            lampPlatformID: "lampStone",
            hiddenPlatformIDs: ["hiddenB", "hiddenC", "pathD", "petalStone", "correctPortalStone"],
            activatedConnections: [
                ConnectionModel(firstPlatformID: "lampStone", secondPlatformID: "hiddenB")
            ]
        )
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
