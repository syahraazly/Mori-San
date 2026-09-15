import CoreGraphics

enum ForgetMeNotLevelData {
    static let mainLevelOne = GameLevel(
        id: "home-1",
        category: .home,
        interaction: .perspective,
        platforms: [
            PlatformModel(
                id: "platformA",
                horizontalPosition: 0.20,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.20, y: 0.33),
                sidePosition: CGPoint(x: 0.25, y: 0.33)
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
                sidePosition: CGPoint(x: 0.75, y: 0.33)
            )
        ],
        player: PlayerModel(name: "Mori", startingPlatformID: "platformA"),
        exitPlatformID: "",
        platformHeightRatio: 0.35
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
