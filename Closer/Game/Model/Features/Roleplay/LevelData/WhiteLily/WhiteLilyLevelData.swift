import CoreGraphics

enum WhiteLilyLevelData {
    // Level 2.1: Introduction of 1x2 shape
    static let level2_1 = GameLevel(
        id: "2.1",
        category: .family,
        interaction: .perspectiveCompact,
        platforms: [
            PlatformModel(
                id: "platformA",
                horizontalPosition: 0.18,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.18, y: 0.33),
                sidePosition: CGPoint(x: 0.18, y: 0.55),
                shape: .single1x1
            ),
            PlatformModel(
                id: "platformB",
                horizontalPosition: 0.45,
                size: CGSize(width: 92, height: 44),
                isDraggable: true,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.45, y: 0.33),
                sidePosition: CGPoint(x: 0.45, y: 0.33),
                shape: .horizontal1x2
            ),
            PlatformModel(
                id: "platformC",
                horizontalPosition: 0.82,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.82, y: 0.55),
                sidePosition: CGPoint(x: 0.68, y: 0.33),
                shape: .single1x1
            )
        ],
        player: PlayerModel(name: "Mori", startingPlatformID: "platformA"),
        exitPlatformID: "platformC",
        platformHeightRatio: 0.35,
        exitConfiguration: ExitConfiguration(platformID: "platformC", offset: CGPoint(x: 0, y: 55)),
        petalConfiguration: PetalConfiguration(platformID: "platformB", offset: CGPoint(x: 0, y: 48))
    )

    // Level 2.2: Introduction of 1x3 shape
    static let level2_2 = GameLevel(
        id: "2.2",
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
                horizontalPosition: 0.48,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.43, y: 0.33),
                sidePosition: CGPoint(x: 0.45, y: 0.33),
                shape: .horizontal1x3
            ),
            PlatformModel(
                id: "platformC",
                horizontalPosition: 0.85,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.85, y: 0.55),
                sidePosition: CGPoint(x: 0.73, y: 0.33),
                shape: .single1x1
            )
        ],
        player: PlayerModel(name: "Mori", startingPlatformID: "platformA"),
        exitPlatformID: "platformC",
        platformHeightRatio: 0.35,
        exitConfiguration: ExitConfiguration(platformID: "platformC", offset: CGPoint(x: 0, y: 55)),
        petalConfiguration: PetalConfiguration(platformID: "platformB", offset: CGPoint(x: 0, y: 48))
    )

    // Level 2.3: Introduction of L-shape piece
    static let level2_3 = GameLevel(
        id: "2.3",
        category: .family,
        interaction: .perspectiveCompact,
        platforms: [
            PlatformModel(
                id: "platformA",
                horizontalPosition: 0.16,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.16, y: 0.33),
                sidePosition: CGPoint(x: 0.16, y: 0.55),
                shape: .single1x1
            ),
            PlatformModel(
                id: "platformB",
                horizontalPosition: 0.42,
                size: CGSize(width: 92, height: 44),
                isDraggable: true,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.42, y: 0.33),
                sidePosition: CGPoint(x: 0.42, y: 0.33),
                shape: .lShape
            ),
            PlatformModel(
                id: "platformC",
                horizontalPosition: 0.65,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.65, y: 0.55),
                sidePosition: CGPoint(x: 0.65, y: 0.33),
                shape: .single1x1
            ),
            PlatformModel(
                id: "platformD",
                horizontalPosition: 0.86,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.86, y: 0.55),
                sidePosition: CGPoint(x: 0.84, y: 0.55),
                shape: .single1x1
            )
        ],
        player: PlayerModel(name: "Mori", startingPlatformID: "platformA"),
        exitPlatformID: "platformD",
        platformHeightRatio: 0.35,
        exitConfiguration: ExitConfiguration(platformID: "platformD", offset: CGPoint(x: 0, y: 55)),
        petalConfiguration: PetalConfiguration(platformID: "platformC", offset: CGPoint(x: 0, y: 48))
    )

    // Level 2.4: Introduction of Reverse-L shape piece
    static let level2_4 = GameLevel(
        id: "2.4",
        category: .family,
        interaction: .perspectiveCompact,
        platforms: [
            PlatformModel(
                id: "platformA",
                horizontalPosition: 0.15,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.15, y: 0.25),
                sidePosition: CGPoint(x: 0.15, y: 0.50),
                shape: .single1x1
            ),
            PlatformModel(
                id: "platformB",
                horizontalPosition: 0.38,
                size: CGSize(width: 92, height: 44),
                isDraggable: true,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.38, y: 0.25),
                sidePosition: CGPoint(x: 0.35, y: 0.40),
                shape: .reverseLShape
            ),
            PlatformModel(
                id: "platformC",
                horizontalPosition: 0.62,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.62, y: 0.55),
                sidePosition: CGPoint(x: 0.58, y: 0.40),
                shape: .horizontal1x2
            ),
            PlatformModel(
                id: "platformD",
                horizontalPosition: 0.86,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.86, y: 0.55),
                sidePosition: CGPoint(x: 0.81, y: 0.70),
                shape: .single1x1
            )
        ],
        player: PlayerModel(name: "Mori", startingPlatformID: "platformA"),
        exitPlatformID: "platformD",
        platformHeightRatio: 0.35,
        exitConfiguration: ExitConfiguration(platformID: "platformD", offset: CGPoint(x: 0, y: 55)),
        petalConfiguration: PetalConfiguration(platformID: "platformC", offset: CGPoint(x: 0, y: 48))
    )

    // Level 2.5: Combining 1x2 and L-shape pieces
    static let level2_5 = GameLevel(
        id: "2.5",
        category: .family,
        interaction: .perspectiveCompact,
        platforms: [
            PlatformModel(
                id: "platformA",
                horizontalPosition: 0.15,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.15, y: 0.28),
                sidePosition: CGPoint(x: 0.15, y: 0.65),
                shape: .single1x1
            ),
            PlatformModel(
                id: "platformB",
                horizontalPosition: 0.38,
                size: CGSize(width: 92, height: 44),
                isDraggable: true,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.38, y: 0.28),
                sidePosition: CGPoint(x: 0.30, y: 0.44),
                shape: .horizontal1x2
            ),
            PlatformModel(
                id: "platformTrap",
                horizontalPosition: 0.60,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.60, y: 0.28),
                sidePosition: CGPoint(x: 0.75, y: 0.25),
                shape: .single1x1
            ),
            PlatformModel(
                id: "platformC",
                horizontalPosition: 0.38,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.38, y: 0.60),
                sidePosition: CGPoint(x: 0.53, y: 0.44),
                shape: .lShape
            ),
            PlatformModel(
                id: "platformExit",
                horizontalPosition: 0.85,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.85, y: 0.40),
                sidePosition: CGPoint(x: 0.76, y: 0.65),
                shape: .single1x1
            )
        ],
        player: PlayerModel(name: "Mori", startingPlatformID: "platformA"),
        exitPlatformID: "platformExit",
        platformHeightRatio: 0.35,
        exitConfiguration: ExitConfiguration(platformID: "platformExit", offset: CGPoint(x: 0, y: 55)),
        petalConfiguration: PetalConfiguration(platformID: "platformTrap", offset: CGPoint(x: 0, y: 48))
    )

    // Level 2.6: Combining 1x3 and Reverse-L pieces in multi-step planning
    static let level2_6 = GameLevel(
        id: "2.6",
        category: .family,
        interaction: .perspectiveCompact,
        platforms: [
            PlatformModel(
                id: "platformA",
                horizontalPosition: 0.14,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.14, y: 0.35),
                sidePosition: CGPoint(x: 0.14, y: 0.55),
                shape: .single1x1
            ),
            PlatformModel(
                id: "platformB",
                horizontalPosition: 0.36,
                size: CGSize(width: 92, height: 44),
                isDraggable: true,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.36, y: 0.35),
                sidePosition: CGPoint(x: 0.36, y: 0.35),
                shape: .reverseLShape
            ),
            PlatformModel(
                id: "platformBridge",
                horizontalPosition: 0.60,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.60, y: 0.55),
                sidePosition: CGPoint(x: 0.60, y: 0.35),
                shape: .horizontal1x3
            ),
            PlatformModel(
                id: "platformExit",
                horizontalPosition: 0.86,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.86, y: 0.55),
                sidePosition: CGPoint(x: 0.86, y: 0.55),
                shape: .single1x1
            )
        ],
        player: PlayerModel(name: "Mori", startingPlatformID: "platformA"),
        exitPlatformID: "platformExit",
        platformHeightRatio: 0.35,
        exitConfiguration: ExitConfiguration(platformID: "platformExit", offset: CGPoint(x: 0, y: 55)),
        petalConfiguration: PetalConfiguration(platformID: "platformBridge", offset: CGPoint(x: 0, y: 48))
    )

    static let goal = FlowerGoal(
        id: "chapter-2",
        title: "CHAPTER 2: WHITE LILY",
        levelIDs: ["2.1", "2.2", "2.3", "2.4", "2.5", "2.6"],
        petalAssetName: "white-lily-petal"
    )

    static let levels = [level2_1, level2_2, level2_3, level2_4, level2_5, level2_6]
}
