import CoreGraphics

struct GameLevel {
    let platforms: [PlatformModel]
    let player: PlayerModel
    let exitPlatformID: String
    let platformHeightRatio: CGFloat
}
