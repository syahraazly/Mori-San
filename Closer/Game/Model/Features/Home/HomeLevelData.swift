import CoreGraphics

enum HomeLevelData {
    static let closerLevel = GameLevel(
        id: "home-1",
        category: .home,
        platforms: [
            PlatformModel(id: "platformA", horizontalPosition: 0.25, size: CGSize(width: 180, height: 50), isDraggable: false, remainsDraggableWhenConnected: false),
            PlatformModel(id: "platformB", horizontalPosition: 0.75, size: CGSize(width: 160, height: 50), isDraggable: true, remainsDraggableWhenConnected: false)
        ],
        player: PlayerModel(name: "Mori", startingPlatformID: "platformA"),
        exitPlatformID: "platformB",
        platformHeightRatio: 0.35
    )

    static let movingBridgeLevel = GameLevel(
        id: "home-2",
        category: .home,
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
    static let homeLevelIDs = ["home-1", "home-2", "home-3"]
}
