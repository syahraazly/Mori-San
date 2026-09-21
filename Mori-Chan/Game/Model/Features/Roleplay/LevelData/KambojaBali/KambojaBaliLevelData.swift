import CoreGraphics

enum KambojaBaliLevelData {
    // Level 3.1: Combining L-shape and Reverse-L in a dual-turn layout
    static let level3_1 = GameLevel(
        id: "3.1",
        category: .family,
        interaction: .perspectiveCompact,
        platforms: [
            PlatformModel(
                id: "platformA",
                horizontalPosition: 0.15,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.15, y: 0.33),
                sidePosition: CGPoint(x: 0.15, y: 0.55),
                shape: .single1x1
            ),
            PlatformModel(
                id: "platformB",
                horizontalPosition: 0.38,
                size: CGSize(width: 92, height: 44),
                isDraggable: true,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.38, y: 0.33),
                sidePosition: CGPoint(x: 0.38, y: 0.33),
                shape: .lShape
            ),
            PlatformModel(
                id: "platformC",
                horizontalPosition: 0.62,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.62, y: 0.52),
                sidePosition: CGPoint(x: 0.62, y: 0.33),
                shape: .reverseLShape
            ),
            PlatformModel(
                id: "platformD",
                horizontalPosition: 0.85,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.85, y: 0.52),
                sidePosition: CGPoint(x: 0.85, y: 0.55),
                shape: .horizontal1x2
            )
        ],
        player: PlayerModel(name: "Mori", startingPlatformID: "platformA"),
        exitPlatformID: "platformD",
        platformHeightRatio: 0.35,
        exitConfiguration: ExitConfiguration(platformID: "platformD", offset: CGPoint(x: 0, y: 55)),
        petalConfiguration: PetalConfiguration(platformID: "platformC", offset: CGPoint(x: 0, y: 48))
    )

    // Level 3.2: Multiple draggable L & Reverse-L pieces in narrow perspective path
    static let level3_2 = GameLevel(
        id: "3.2",
        category: .family,
        interaction: .perspectiveCompact,
        platforms: [
            PlatformModel(
                id: "platformA",
                horizontalPosition: 0.14,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.14, y: 0.28),
                sidePosition: CGPoint(x: 0.14, y: 0.55),
                shape: .single1x1
            ),
            PlatformModel(
                id: "platformB",
                horizontalPosition: 0.35,
                size: CGSize(width: 92, height: 44),
                isDraggable: true,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.35, y: 0.28),
                sidePosition: CGPoint(x: 0.35, y: 0.38),
                shape: .reverseLShape
            ),
            PlatformModel(
                id: "platformTrap",
                horizontalPosition: 0.58,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.58, y: 0.28),
                sidePosition: CGPoint(x: 0.58, y: 0.18),
                shape: .single1x1
            ),
            PlatformModel(
                id: "platformC",
                horizontalPosition: 0.35,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.35, y: 0.55),
                sidePosition: CGPoint(x: 0.58, y: 0.38),
                shape: .lShape
            ),
            PlatformModel(
                id: "platformD",
                horizontalPosition: 0.82,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.82, y: 0.55),
                sidePosition: CGPoint(x: 0.82, y: 0.55),
                shape: .horizontal1x3
            )
        ],
        player: PlayerModel(name: "Mori", startingPlatformID: "platformA"),
        exitPlatformID: "platformD",
        platformHeightRatio: 0.35,
        exitConfiguration: ExitConfiguration(platformID: "platformD", offset: CGPoint(x: 0, y: 55)),
        petalConfiguration: PetalConfiguration(platformID: "platformTrap", offset: CGPoint(x: 0, y: 48))
    )

    // Level 3.3: Tight 5-platform puzzle combining L-shape, 1x3, and Reverse-L
    static let level3_3 = GameLevel(
        id: "3.3",
        category: .family,
        interaction: .perspectiveCompact,
        platforms: [
            PlatformModel(
                id: "platformA",
                horizontalPosition: 0.14,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.14, y: 0.25),
                sidePosition: CGPoint(x: 0.14, y: 0.50),
                shape: .single1x1
            ),
            PlatformModel(
                id: "platformB",
                horizontalPosition: 0.36,
                size: CGSize(width: 92, height: 44),
                isDraggable: true,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.36, y: 0.25),
                sidePosition: CGPoint(x: 0.32, y: 0.40),
                shape: .horizontal1x3
            ),
            PlatformModel(
                id: "platformC",
                horizontalPosition: 0.60,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.60, y: 0.55),
                sidePosition: CGPoint(x: 0.55, y: 0.40),
                shape: .lShape
            ),
            PlatformModel(
                id: "platformD",
                horizontalPosition: 0.60,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.60, y: 0.25),
                sidePosition: CGPoint(x: 0.55, y: 0.70),
                shape: .reverseLShape
            ),
            PlatformModel(
                id: "platformE",
                horizontalPosition: 0.84,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.84, y: 0.55),
                sidePosition: CGPoint(x: 0.78, y: 0.70),
                shape: .horizontal1x2
            )
        ],
        player: PlayerModel(name: "Mori", startingPlatformID: "platformA"),
        exitPlatformID: "platformE",
        platformHeightRatio: 0.35,
        exitConfiguration: ExitConfiguration(platformID: "platformE", offset: CGPoint(x: 0, y: 55)),
        petalConfiguration: PetalConfiguration(platformID: "platformD", offset: CGPoint(x: 0, y: 48))
    )

    // Level 3.4: Complex layout with L-shape, Reverse-L, and 1x3 pieces requiring dual-POV alignment
    static let level3_4 = GameLevel(
        id: "3.4",
        category: .family,
        interaction: .perspectiveCompact,
        platforms: [
            PlatformModel(
                id: "platformA",
                horizontalPosition: 0.14,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.14, y: 0.28),
                sidePosition: CGPoint(x: 0.14, y: 0.65),
                shape: .single1x1
            ),
            PlatformModel(
                id: "platformB",
                horizontalPosition: 0.36,
                size: CGSize(width: 92, height: 44),
                isDraggable: true,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.36, y: 0.28),
                sidePosition: CGPoint(x: 0.28, y: 0.44),
                shape: .lShape
            ),
            PlatformModel(
                id: "platformC",
                horizontalPosition: 0.58,
                size: CGSize(width: 92, height: 44),
                isDraggable: true,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.58, y: 0.60),
                sidePosition: CGPoint(x: 0.50, y: 0.44),
                shape: .reverseLShape
            ),
            PlatformModel(
                id: "platformD",
                horizontalPosition: 0.58,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.58, y: 0.28),
                sidePosition: CGPoint(x: 0.72, y: 0.25),
                shape: .horizontal1x3
            ),
            PlatformModel(
                id: "platformExit",
                horizontalPosition: 0.84,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.84, y: 0.40),
                sidePosition: CGPoint(x: 0.76, y: 0.65),
                shape: .single1x1
            )
        ],
        player: PlayerModel(name: "Mori", startingPlatformID: "platformA"),
        exitPlatformID: "platformExit",
        platformHeightRatio: 0.35,
        exitConfiguration: ExitConfiguration(platformID: "platformExit", offset: CGPoint(x: 0, y: 55)),
        petalConfiguration: PetalConfiguration(platformID: "platformD", offset: CGPoint(x: 0, y: 48))
    )

    // Level 3.5: Master level combining all 5 block shapes in a multi-stage puzzle
    static let level3_5 = GameLevel(
        id: "3.5",
        category: .family,
        interaction: .perspectiveCompact,
        platforms: [
            PlatformModel(
                id: "platformA",
                horizontalPosition: 0.12,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.12, y: 0.25),
                sidePosition: CGPoint(x: 0.12, y: 0.60),
                shape: .single1x1
            ),
            PlatformModel(
                id: "platformB",
                horizontalPosition: 0.34,
                size: CGSize(width: 92, height: 44),
                isDraggable: true,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.34, y: 0.25),
                sidePosition: CGPoint(x: 0.28, y: 0.42),
                shape: .lShape
            ),
            PlatformModel(
                id: "platformC",
                horizontalPosition: 0.56,
                size: CGSize(width: 92, height: 44),
                isDraggable: true,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.56, y: 0.55),
                sidePosition: CGPoint(x: 0.48, y: 0.42),
                shape: .reverseLShape
            ),
            PlatformModel(
                id: "platformTrap",
                horizontalPosition: 0.56,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.56, y: 0.25),
                sidePosition: CGPoint(x: 0.68, y: 0.22),
                shape: .horizontal1x2
            ),
            PlatformModel(
                id: "platformBridge",
                horizontalPosition: 0.78,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.78, y: 0.55),
                sidePosition: CGPoint(x: 0.68, y: 0.60),
                shape: .horizontal1x3
            ),
            PlatformModel(
                id: "platformExit",
                horizontalPosition: 0.88,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.88, y: 0.40),
                sidePosition: CGPoint(x: 0.82, y: 0.60),
                shape: .single1x1
            )
        ],
        player: PlayerModel(name: "Mori", startingPlatformID: "platformA"),
        exitPlatformID: "platformExit",
        platformHeightRatio: 0.35,
        exitConfiguration: ExitConfiguration(platformID: "platformExit", offset: CGPoint(x: 0, y: 55)),
        petalConfiguration: PetalConfiguration(platformID: "platformTrap", offset: CGPoint(x: 0, y: 48))
    )

    static let goal = FlowerGoal(
        id: "chapter-3",
        title: "CHAPTER 3: KAMBOJA BALI",
        levelIDs: ["3.1", "3.2", "3.3", "3.4", "3.5"],
        petalAssetName: "kamboja-bali-petal"
    )

    static let levels = [level3_1, level3_2, level3_3, level3_4, level3_5]
}
