import CoreGraphics

enum LevelCategory {
    case home
    case family
}

struct GameLevel {
    let id: String
    let category: LevelCategory
    let platforms: [PlatformModel]
    let player: PlayerModel
    let exitPlatformID: String
    let platformHeightRatio: CGFloat
}
