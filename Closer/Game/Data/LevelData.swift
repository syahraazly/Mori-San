import CoreGraphics

enum LevelData {
    static let closerLevel = GameLevel(
        platforms: [
            PlatformModel(id: "platformA", horizontalPosition: 0.25, size: CGSize(width: 180, height: 50), isDraggable: false),
            PlatformModel(id: "platformB", horizontalPosition: 0.75, size: CGSize(width: 160, height: 50), isDraggable: true)
        ],
        player: PlayerModel(name: "Mori", startingPlatformID: "platformA"),
        exitPlatformID: "platformB",
        platformHeightRatio: 0.35
    )
}
