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

struct SnapRule {
    let draggablePlatformID: String
    let targetPlatformIDs: [String]
    let threshold: CGFloat
}

struct ExitConfiguration {
    let platformID: String
    let offset: CGPoint
}

struct PetalConfiguration {
    let platformID: String
    let offset: CGPoint

    init(platformID: String, offset: CGPoint = CGPoint(x: 0, y: 48)) {
        self.platformID = platformID
        self.offset = offset
    }
}

struct GameLevel {
    let id: String
    let category: LevelCategory
    let interaction: LevelInteraction
    let platforms: [PlatformModel]
    let player: PlayerModel
    let exitPlatformID: String
    let platformHeightRatio: CGFloat
    let snapRules: [SnapRule]
    let initialConnections: [ConnectionModel]
    let exitConfiguration: ExitConfiguration?
    let petalConfiguration: PetalConfiguration?

    init(
        id: LevelID,
        category: LevelCategory,
        interaction: LevelInteraction,
        platforms: [PlatformModel],
        player: PlayerModel,
        exitPlatformID: String,
        platformHeightRatio: CGFloat,
        snapRules: [SnapRule] = [],
        initialConnections: [ConnectionModel] = [],
        exitConfiguration: ExitConfiguration? = nil,
        petalConfiguration: PetalConfiguration? = nil
    ) {
        self.id = id
        self.category = category
        self.interaction = interaction
        self.platforms = platforms
        self.player = player
        self.exitPlatformID = exitPlatformID
        self.platformHeightRatio = platformHeightRatio
        self.snapRules = snapRules
        self.initialConnections = initialConnections
        self.exitConfiguration = exitConfiguration
        self.petalConfiguration = petalConfiguration
    }

    var usesPerspective: Bool {
        interaction == .perspective || interaction == .perspectiveCompact
    }

    var allowsCompact: Bool {
        interaction == .compact || interaction == .perspectiveCompact
    }
}

typealias LevelConfiguration = GameLevel
