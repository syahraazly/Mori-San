import CoreGraphics

enum LevelCategory {
    case tutorial
    case home
    case family
}

enum LevelInteraction {
    case compact
    case perspective
    case perspectiveCompact
}

struct GameLevel {
    let id: String
    let category: LevelCategory
    let interaction: LevelInteraction
    let platforms: [PlatformModel]
    let player: PlayerModel
    let exitPlatformID: String
    let platformHeightRatio: CGFloat

    var usesPerspective: Bool {
        interaction == .perspective || interaction == .perspectiveCompact
    }

    var allowsCompact: Bool {
        interaction == .compact || interaction == .perspectiveCompact
    }
}
