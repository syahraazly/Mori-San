import CoreGraphics

enum TutorialLevelData {
    static let closerLevel = GameLevel(
        id: "tutorial-1",
        category: .tutorial,
        interaction: .compact,
        platforms: [
            PlatformModel(id: "platformA", horizontalPosition: 0.25, size: CGSize(width: 180, height: 50), isDraggable: false, remainsDraggableWhenConnected: false),
            PlatformModel(id: "platformB", horizontalPosition: 0.75, size: CGSize(width: 160, height: 50), isDraggable: true, remainsDraggableWhenConnected: false)
        ],
        player: PlayerModel(name: "Mori", startingPlatformID: "platformA"),
        exitPlatformID: "platformB",
        platformHeightRatio: 0.35
    )

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

    static let levels = [closerLevel, movingBridgeLevel]
}
