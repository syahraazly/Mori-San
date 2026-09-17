import CoreGraphics

enum ForgetMeNotLevelData {
    static let level1_1 = GameLevel(
        id: "1.1",
        category: .home,
        interaction: .perspectiveCompact,
        platforms: [
            PlatformModel(
                id: "platformA",
                horizontalPosition: 0.20,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.20, y: 0.33),
                sidePosition: CGPoint(x: 0.264, y: 0.33)
            ),
            PlatformModel(
                id: "platformB",
                horizontalPosition: 0.50,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.50, y: 0.52),
                sidePosition: CGPoint(x: 0.50, y: 0.33)
            ),
            PlatformModel(
                id: "platformC",
                horizontalPosition: 0.80,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.80, y: 0.33),
                sidePosition: CGPoint(x: 0.736, y: 0.33)
            )
        ],
        player: PlayerModel(name: "Mori", startingPlatformID: "platformA"),
        exitPlatformID: "platformC",
        platformHeightRatio: 0.35,
        exitConfiguration: ExitConfiguration(platformID: "platformC", offset: CGPoint(x: 0, y: 55))
    )

    static let level1_2 = GameLevel(
        id: "1.2",
        category: .home,
        interaction: .perspectiveCompact,
        platforms: [
            PlatformModel(
                id: "platformA",
                horizontalPosition: 0.18,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.18, y: 0.33),
                sidePosition: CGPoint(x: 0.18, y: 0.55)
            ),
            PlatformModel(
                id: "platformB",
                horizontalPosition: 0.41,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.41, y: 0.33),
                sidePosition: CGPoint(x: 0.38, y: 0.33)
            ),
            PlatformModel(
                id: "platformC",
                horizontalPosition: 0.64,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.64, y: 0.55),
                sidePosition: CGPoint(x: 0.61, y: 0.33)
            ),
            PlatformModel(
                id: "platformD",
                horizontalPosition: 0.87,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.87, y: 0.55),
                sidePosition: CGPoint(x: 0.84, y: 0.55)
            )
        ],
        player: PlayerModel(name: "Mori", startingPlatformID: "platformA"),
        exitPlatformID: "platformD",
        platformHeightRatio: 0.35,
        exitConfiguration: ExitConfiguration(platformID: "platformD", offset: CGPoint(x: 0, y: 55))
    )

    static let level1_3 = GameLevel(
        id: "1.3",
        category: .home,
        interaction: .perspectiveCompact,
        platforms: [
            PlatformModel(
                id: "platformA",
                horizontalPosition: 0.16,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.16, y: 0.33),
                sidePosition: CGPoint(x: 0.16, y: 0.55)
            ),
            PlatformModel(
                id: "platformB",
                horizontalPosition: 0.39,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.39, y: 0.33),
                sidePosition: CGPoint(x: 0.39, y: 0.33)
            ),
            PlatformModel(
                id: "platformTrap",
                horizontalPosition: 0.62,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.62, y: 0.33),
                sidePosition: CGPoint(x: 0.75, y: 0.60)
            ),
            PlatformModel(
                id: "platformBridge",
                horizontalPosition: 0.39,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.39, y: 0.55),
                sidePosition: CGPoint(x: 0.62, y: 0.33)
            ),
            PlatformModel(
                id: "platformD",
                horizontalPosition: 0.62,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.62, y: 0.55),
                sidePosition: CGPoint(x: 0.85, y: 0.55)
            )
        ],
        player: PlayerModel(name: "Mori", startingPlatformID: "platformA"),
        exitPlatformID: "platformD",
        platformHeightRatio: 0.35,
        exitConfiguration: ExitConfiguration(platformID: "platformD", offset: CGPoint(x: 0, y: 55))
    )

    static let level1_4 = GameLevel(
        id: "1.4",
        category: .home,
        interaction: .perspectiveCompact,
        platforms: [
            PlatformModel(
                id: "platformA",
                horizontalPosition: 0.16,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.16, y: 0.25),
                sidePosition: CGPoint(x: 0.16, y: 0.50)
            ),
            PlatformModel(
                id: "platformB",
                horizontalPosition: 0.39,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.39, y: 0.25),
                sidePosition: CGPoint(x: 0.35, y: 0.40)
            ),
            PlatformModel(
                id: "platformC",
                horizontalPosition: 0.42,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.42, y: 0.55),
                sidePosition: CGPoint(x: 0.58, y: 0.40)
            ),
            PlatformModel(
                id: "platformD",
                horizontalPosition: 0.65,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.65, y: 0.55),
                sidePosition: CGPoint(x: 0.58, y: 0.70)
            ),
            PlatformModel(
                id: "platformE",
                horizontalPosition: 0.88,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.88, y: 0.55),
                sidePosition: CGPoint(x: 0.81, y: 0.70)
            )
        ],
        player: PlayerModel(name: "Mori", startingPlatformID: "platformA"),
        exitPlatformID: "platformE",
        platformHeightRatio: 0.35,
        exitConfiguration: ExitConfiguration(platformID: "platformE", offset: CGPoint(x: 0, y: 55))
    )

    static let level1_5 = GameLevel(
        id: "1.5",
        category: .home,
        interaction: .perspectiveCompact,
        platforms: [
            PlatformModel(
                id: "platformA",
                horizontalPosition: 0.16,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.16, y: 0.28),
                sidePosition: CGPoint(x: 0.16, y: 0.65)
            ),
            PlatformModel(
                id: "platformB",
                horizontalPosition: 0.39,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.39, y: 0.28),
                sidePosition: CGPoint(x: 0.30, y: 0.44)
            ),
            PlatformModel(
                id: "platformTrap",
                horizontalPosition: 0.62,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.62, y: 0.28),
                sidePosition: CGPoint(x: 0.75, y: 0.25)
            ),
            PlatformModel(
                id: "platformC",
                horizontalPosition: 0.39,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.39, y: 0.60),
                sidePosition: CGPoint(x: 0.53, y: 0.44)
            ),
            PlatformModel(
                id: "platformD",
                horizontalPosition: 0.62,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.62, y: 0.60),
                sidePosition: CGPoint(x: 0.53, y: 0.65)
            ),
            PlatformModel(
                id: "platformExit",
                horizontalPosition: 0.85,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.85, y: 0.40),
                sidePosition: CGPoint(x: 0.76, y: 0.65)
            )
        ],
        player: PlayerModel(name: "Mori", startingPlatformID: "platformA"),
        exitPlatformID: "platformExit",
        platformHeightRatio: 0.35,
        exitConfiguration: ExitConfiguration(platformID: "platformExit", offset: CGPoint(x: 0, y: 55))
    )

    static let goal = FlowerGoal(
        id: "forget-me-not",
        title: "FORGET ME NOT",
        levelIDs: ["1.1", "1.2", "1.3", "1.4", "1.5"]
    )

    static let levels = [level1_1, level1_2, level1_3, level1_4, level1_5]

    // Backwards-compatible aliases
    static let mainLevelOne = level1_1
    static let mainLevelTwo = level1_2
    static let mainLevelThree = level1_3
    static let mainLevelFour = level1_4
    static let mainLevelFive = level1_5
}
