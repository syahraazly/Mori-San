import CoreGraphics

enum BalineseFrangipaniLevelData {
    static let levelOne = GameLevel(
        id: "balinese-1",
        category: .family,
        interaction: .perspectiveCompact,
        platforms: [
            stone(
                id: "start",
                asset: "stone1x1",
                size: CGSize(width: 44, height: 44),
                shape: .single1x1,
                front: CGPoint(x: 0.12, y: 0.72),
                side: CGPoint(x: 0.12, y: 0.72)
            ),
            stone(
                id: "blueBridge",
                asset: "stone2x1",
                size: CGSize(width: 92, height: 44),
                shape: .horizontal1x2,
                front: CGPoint(x: 0.29, y: 0.72),
                side: CGPoint(x: 0.44, y: 0.471),
                draggable: true
            ),
            stone(
                id: "greenTarget",
                asset: "stone1x1",
                size: CGSize(width: 44, height: 44),
                shape: .single1x1,
                front: CGPoint(x: 0.70, y: 0.72),
                side: CGPoint(x: 0.70, y: 0.72)
            ),
            PlatformModel(
                id: "lowerLObstacle",
                horizontalPosition: 0.72,
                size: CGSize(width: 132, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.685, y: 0.471),
                sidePosition: CGPoint(x: 0.685, y: 0.305),
                role: .walkable,
                assetName: "stone3x2",
                visualSize: CGSize(width: 132, height: 96),
                shape: .lShape
            ),
            stone(
                id: "returnPlatform",
                asset: "stone2x1",
                size: CGSize(width: 92, height: 44),
                shape: .horizontal1x2,
                front: CGPoint(x: 0.233, y: 0.139),
                side: CGPoint(x: 0.18, y: 0.471)
            ),
            stone(
                id: "petalStone",
                asset: "stone1x1",
                size: CGSize(width: 44, height: 44),
                shape: .single1x1,
                front: CGPoint(x: 0.46, y: 0.525),
                side: CGPoint(x: 0.685, y: 0.471)
            ),
            
            stone(
                id: "correctPortalPlatform",
                asset: "stone2x1",
                size: CGSize(width: 92, height: 44),
                shape: .horizontal1x2,
                front: CGPoint(x: 0.459, y: 0.139),
                side: CGPoint(x: 0.459, y: 0.139)
            )
        ],
        
        player: PlayerModel(
            name: "Mori",
            startingPlatformID: "start"
        ),
        exitPlatformID: "",
        platformHeightRatio: 0.35,
        snapRules: [
            SnapRule(
                draggablePlatformID: "blueBridge",
                targetPlatformIDs: ["greenTarget"],
                threshold: 42
            )
        ],
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
                    to: PortalDestination(
                        platformID: "returnPlatform",
                        offset: .zero
                    )
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
    
    // Level 3.2:
    static let levelTwo = GameLevel(
        id: "balinese-2",
        category: .family,
        interaction: .perspective,
        
        platforms: [
            stone(
                id: "start",
                asset: "stone1x1",
                size: CGSize(width: 44, height: 44),
                shape: .single1x1,
                front: CGPoint(x: 0.120, y: 0.720),
                side: CGPoint(x: 0.233, y: 0.637)
            ),
            stone(
                id: "pathA",
                asset: "stone2x1",
                size: CGSize(width: 92, height: 44),
                shape: .horizontal1x2,
                front: CGPoint(x: 0.290, y: 0.720),
                side: CGPoint(x: 0.177, y: 0.471),
                draggable: true
            ),
            lStone(
                id: "deadEnd",
                asset: "stone2x3",
                shape: .reverseLShape,
                front: CGPoint(x: 0.685, y: 0.5),
                side: CGPoint(x: 0.798, y: 0.5),
                blockedEdges: [.right]
            ),
            stone(
                id: "fakePortalStone",
                asset: "stone1x1",
                size: CGSize(width: 44, height: 44),
                shape: .single1x1,
                front: CGPoint(x: 0.459, y: 0.470),
                side: CGPoint(x: 0.572, y: 0.470)
            ),
            stone(
                id: "returnPlatform",
                asset: "stone2x1",
                size: CGSize(width: 92, height: 44),
                shape: .horizontal1x2,
                front: CGPoint(x: 0.120, y: 0.305),
                side: CGPoint(x: 0.120, y: 0.305),
                draggable: true
            ),
            stone(
                id: "pathMiddle",
                asset: "stone2x1",
                size: CGSize(width: 92, height: 44),
                shape: .horizontal1x2,
                front: CGPoint(x: 0.290, y: 0.470),
                side: CGPoint(x: 0.742, y: 0.139)
            ),
            stone(
                id: "petalStone",
                asset: "stone1x1",
                size: CGSize(width: 44, height: 44),
                shape: .single1x1,
                front: CGPoint(x: 0.346, y: 0.305),
                side: CGPoint(x: 0.572, y: 0.139)
            ),
            stone(
                id: "wrongPortalStone",
                asset: "stone1x1",
                size: CGSize(width: 44, height: 44),
                shape: .single1x1,
                front: CGPoint(x: 0.685, y: 0.139),
                side: CGPoint(x: 0.798, y: 0.305)
            ),
            stone(
                id: "correctPortalStone",
                asset: "stone1x1",
                size: CGSize(width: 44, height: 44),
                shape: .single1x1,
                front: CGPoint(x: 0.911, y: 0.139),
                side: CGPoint(x: 0.911, y: 0.139)
            )
        ],
        
        player: PlayerModel(
            name: "Mori",
            startingPlatformID: "start"
        ),
        
        exitPlatformID: "",
        
        platformHeightRatio: 0.35,
        
        petalConfiguration: PetalConfiguration(
            platformID: "petalStone",
            assetName: "kamboja-bali-petal"
        ),
        
        portals: [
            PortalConfiguration(
                id: "fakePortal",
                platformID: "fakePortalStone",
                offset: CGPoint(x: 0, y: 30),
                outcome: .loops(
                    to: PortalDestination(
                        platformID: "returnPlatform",
                        offset: .zero
                    )
                ),
                anchor: .walkableSurface
            ),
            
            PortalConfiguration(
                id: "wrongPortal",
                platformID: "wrongPortalStone",
                offset: CGPoint(x: 0, y: 30),
                outcome: .loops(
                    to: PortalDestination(
                        platformID: "returnPlatform",
                        offset: .zero
                    )
                ),
                anchor: .walkableSurface
            ),
            
            PortalConfiguration(
                id: "correctPortal",
                platformID: "correctPortalStone",
                offset: CGPoint(x: 0, y: 30),
                outcome: .completesLevel,
                anchor: .walkableSurface
            )
        ],
        
        backgroundAssetName: "background-chapter-3",
        
        movementMode: .adjacentOnly,
        
        usesProximityConnections: true
    )
    
    // Level 3.3
    static let levelThree = GameLevel(
        id: "balinese-3",
        category: .family,
        interaction: .perspective,
        platforms: [
            PlatformModel(
                id: "LowerLObstacle",
                horizontalPosition: 0.72,
                size: CGSize(width: 132, height: 44),
                isDraggable: true,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.176, y: 0.618),
                sidePosition: CGPoint(x: 0.176, y: 0.222),
                role: .walkable,
                assetName: "stone3x2",
                visualSize: CGSize(width: 132, height: 96),
                shape: .lShape
            ),
            stone(
                id: "start",
                asset: "stone1x1",
                size: CGSize(width: 44, height: 44),
                shape: .single1x1,
                front: CGPoint(x: 0.405, y: 0.62),
                side: CGPoint(x: 0.572, y: 0.222)
            ),
            stone(
                id: "pathA",
                asset: "stone2x1",
                size: CGSize(width: 92, height: 44),
                shape: .horizontal1x2,
                front: CGPoint(x: 0.58, y: 0.62),
                side: CGPoint(x: 0.289, y: 0.554),
                draggable: true
            ),
            stone(
                id: "falsePortalStone",
                asset: "stone2x1",
                size: CGSize(width: 92, height: 44),
                shape: .horizontal1x2,
                front: CGPoint(x: 0.815, y: 0.62),
                side: CGPoint(x: 0.742, y: 0.222)
            ),
            stone(
                id: "pathB",
                asset: "stone1x1",
                size: CGSize(width: 44, height: 44),
                shape: .single1x1,
                front: CGPoint(x: 0.18, y: 0.25),
                side: CGPoint(x: 0.459, y: 0.554)
            ),
            stone(
                id: "petalStone",
                asset: "stone1x1",
                size: CGSize(width: 44, height: 44),
                shape: .single1x1,
                front: CGPoint(x: 0.40, y: 0.25),
                side: CGPoint(x: 0.120, y: 0.554)
            ),
            stone(
                id: "correctPortalStone",
                asset: "stone2x1",
                size: CGSize(width: 92, height: 44),
                shape: .horizontal1x2,
                front: CGPoint(x: 0.854, y: 0.305),
                side: CGPoint(x: 0.702, y: 0.554),
                draggable: true
            )
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
    
    // Level 3.4
    static let levelFour = GameLevel(
        id: "balinese-4",
        category: .family,
        interaction: .perspective,
        
        platforms: [
            
            stone(
                id: "start",
                asset: "stone1x1",
                size: CGSize(width: 44, height: 44),
                shape: .single1x1,
                front: CGPoint(x: 0.120, y: 0.554),
                side: CGPoint(x: 0.120, y: 0.305)
            ),
            stone(
                id: "dragA",
                asset: "stone2x1",
                size: CGSize(width: 92, height: 44),
                shape: .horizontal1x2,
                front: CGPoint(x: 0.2895, y: 0.637),
                side: CGPoint(x: 0.2895, y: 0.554),
                draggable: true
            ),
            stone(
                id: "sideA",
                asset: "stone1x1",
                size: CGSize(width: 44, height: 44),
                shape: .single1x1,
                front: CGPoint(x: 0.798, y: 0.803),
                side: CGPoint(x: 0.459, y: 0.305),
            ),
            stone(
                id: "fakePortalStoneA",
                asset: "stone2x1",
                size: CGSize(width: 92, height: 44),
                shape: .horizontal1x2,
                front: CGPoint(x: 0.741, y: 0.637),
                side: CGPoint(x: 0.6285, y: 0.305)
            ),
            stone(
                id: "returnA",
                asset: "stone1x1",
                size: CGSize(width: 44, height: 44),
                shape: .single1x1,
                front: CGPoint(x: 0.120, y: 0.471),
                side: CGPoint(x: 0.911, y: 0.720),
                draggable: true
            ),
            stone(
                id: "dragB",
                asset: "stone2x1",
                size: CGSize(width: 92, height: 44),
                shape: .horizontal1x2,
                front: CGPoint(x: 0.2895, y: 0.305),
                side: CGPoint(x: 0.798, y: 0.139),
                draggable: true
            ),
            stone(
                id: "pathB",
                asset: "stone1x1",
                size: CGSize(width: 44, height: 44),
                shape: .single1x1,
                front: CGPoint(x: 0.459, y: 0.471),
                side: CGPoint(x: 0.911, y: 0.554)
            ),
            stone(
                id: "fakePortalStoneB",
                asset: "stone2x1",
                size: CGSize(width: 92, height: 44),
                shape: .horizontal1x2,
                front: CGPoint(x: 0.6285, y: 0.471),
                side: CGPoint(x: 0.798, y: 0.139)
            ),
            stone(
                id: "returnB",
                asset: "stone1x1",
                size: CGSize(width: 44, height: 44),
                shape: .single1x1,
                front: CGPoint(x: 0.911, y: 0.803),
                side: CGPoint(x: 0.120, y: 0.554)
            ),
            stone(
                id: "dragC",
                asset: "stone2x1",
                size: CGSize(width: 92, height: 44),
                shape: .horizontal1x2,
                front: CGPoint(x: 0.798, y: 0.139),
                side: CGPoint(x: 0.2895, y: 0.305),
                draggable: true
            ),
            stone(
                id: "petalStone",
                asset: "stone1x1",
                size: CGSize(width: 44, height: 44),
                shape: .single1x1,
                front: CGPoint(x: 0.911, y: 0.637),
                side: CGPoint(x: 0.459, y: 0.554)
            ),
            stone(
                id: "correctPortalStone",
                asset: "stone2x1",
                size: CGSize(width: 92, height: 44),
                shape: .horizontal1x2,
                front: CGPoint(x: 0.854, y: 0.305),
                side: CGPoint(x: 0.741, y: 0.554)
            )
        ],
        
        player: PlayerModel(
            name: "Mori",
            startingPlatformID: "start"
        ),
        
        exitPlatformID: "",
        
        platformHeightRatio: 0.35,
        
        petalConfiguration: PetalConfiguration(
            platformID: "petalStone",
            assetName: "kamboja-bali-petal"
        ),
        
        portals: [
            PortalConfiguration(
                id: "fakePortalA",
                platformID: "fakePortalStoneA",
                offset: CGPoint(x: 0, y: 30),
                outcome: .loops(
                    to: PortalDestination(
                        platformID: "returnA",
                        offset: .zero
                    )
                ),
                anchor: .walkableSurface
            ),
            PortalConfiguration(
                id: "fakePortalB",
                platformID: "fakePortalStoneB",
                offset: CGPoint(x: 0, y: 30),
                outcome: .loops(
                    to: PortalDestination(
                        platformID: "returnB",
                        offset: .zero
                    )
                ),
                anchor: .walkableSurface
            ),
            
            PortalConfiguration(
                id: "correctPortal",
                platformID: "correctPortalStone",
                offset: CGPoint(x: 0, y: 30),
                outcome: .completesLevel,
                anchor: .walkableSurface
            )
        ],
        
        backgroundAssetName: "background-chapter-3",
        
        movementMode: .adjacentOnly,
        
        usesProximityConnections: true
    )
    
    //    Level 3.5
    static let levelFive = GameLevel(
        id: "balinese-5",
        category: .family,
        interaction: .perspective,
        
        platforms: [
            stone(
                id: "start",
                asset: "stone1x1",
                size: CGSize(width: 44, height: 44),
                shape: .single1x1,
                front: CGPoint(x: 0.120, y: 0.720),
                side: CGPoint(x: 0.233, y: 0.637)
            ),
            stone(
                id: "pathA",
                asset: "stone2x1",
                size: CGSize(width: 92, height: 44),
                shape: .horizontal1x2,
                front: CGPoint(x: 0.290, y: 0.720),
                side: CGPoint(x: 0.177, y: 0.388),
                draggable: true
            ),
            lStone(
                id: "deadEnd",
                asset: "stone2x3",
                shape: .reverseLShape,
                front: CGPoint(x: 0.572, y: 0.365),
                side: CGPoint(x: 0.685, y: 0.615),
                blockedEdges: []
            ),
            stone(
                id: "bridgeA",
                asset: "stone2x1",
                size: CGSize(width: 92, height: 44),
                shape: .horizontal1x2,
                front: CGPoint(x: 0.8545, y: 0.388),
                side: CGPoint(x: 0.459, y: 0.388),
            ),
            
            stone(
                id: "lampStone",
                asset: "stone1x1",
                size: CGSize(width: 44, height: 44),
                shape: .single1x1,
                front: CGPoint(x: 0.911, y: 0.554),
                side: CGPoint(x: 0.911, y: 0.637)
            ),
            stone(
                id: "hiddenB",
                asset: "stone1x1",
                size: CGSize(width: 44, height: 44),
                shape: .single1x1,
                front: CGPoint(x: 0.572, y: 0.554),
                side: CGPoint(x: 0.572, y: 0.222)
            ),
            stone(
                id: "bridgeB",
                asset: "stone2x1",
                size: CGSize(width: 92, height: 44),
                shape: .horizontal1x2,
                front: CGPoint(x: 0.741, y: 0.554),
                side: CGPoint(x: 0.798, y: 0.388),
                draggable: false
            ),
            stone(
                id: "hiddenC",
                asset: "stone1x1",
                size: CGSize(width: 44, height: 44),
                shape: .single1x1,
                front: CGPoint(x: 0.572, y: 0.388),
                side: CGPoint(x: 0.346, y: 0.720)
            ),
            PlatformModel(
                id: "reverseLRoute",
                horizontalPosition: 0.72,
                size: CGSize(width: 132, height: 44),
                isDraggable: true,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.346, y: 0.502),
                sidePosition: CGPoint(x: 0.798, y: 0.172),
                role: .walkable,
                assetName: "stone3x2",
                visualSize: CGSize(width: 132, height: 96),
                shape: .lShape
            ),
            stone(
                id: "petalStone",
                asset: "stone1x1",
                size: CGSize(width: 44, height: 44),
                shape: .single1x1,
                front: CGPoint(x: 0.120, y: 0.554),
                side: CGPoint(x: 0.233, y: 0.222)
            ),
            stone(
                id: "correctPortalStone",
                asset: "stone1x1",
                size: CGSize(width: 44, height: 44),
                shape: .single1x1,
                front: CGPoint(x: 0.233, y: 0.305),
                side: CGPoint(x: 0.459, y: 0.720)
            )
        ],
        
        player: PlayerModel(
            name: "Mori",
            startingPlatformID: "start"
        ),
        
        exitPlatformID: "",
        platformHeightRatio: 0.35,
        initialConnections: [
            ConnectionModel(
                firstPlatformID: "start",
                secondPlatformID: "pathA"
            )
        ],
        petalConfiguration: PetalConfiguration(
            platformID: "petalStone",
            assetName: "kamboja-bali-petal",
        ),
        
        //        Portal
        portals: [
            PortalConfiguration(
                id: "correctPortal",
                platformID: "correctPortalStone",
                offset: CGPoint(x: 0, y: 30),
                outcome: .completesLevel,
                anchor: .walkableSurface
            )
        ],
        
        backgroundAssetName: "background-chapter-3",
        
        movementMode: .adjacentOnly,
        
        usesProximityConnections: true,
        
        
        lightRevealConfiguration: LightRevealConfiguration(
            lampPlatformID: "lampStone",
            
            hiddenPlatformIDs: [
                "hiddenB",
                "bridgeB",
                "hiddenC",
                "reverseLRoute",
                "petalStone",
                "correctPortalStone"
            ],
            
            activatedConnections: [
                ConnectionModel(
                    firstPlatformID: "lampStone",
                    secondPlatformID: "hiddenB"
                )
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
