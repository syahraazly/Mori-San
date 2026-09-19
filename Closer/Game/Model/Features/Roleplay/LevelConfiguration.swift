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

enum MoriMovementMode {
    case pathfinding
    case adjacentOnly
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

struct PortalDestination {
    let platformID: String
    let offset: CGPoint
}

enum PortalOutcome {
    case completesLevel
    case loops(to: PortalDestination)
}

enum PortalAnchor {
    case platformCenter
    case walkableSurface
}

struct PortalConfiguration {
    let id: String
    let platformID: String
    let offset: CGPoint
    let outcome: PortalOutcome
    let anchor: PortalAnchor

    init(
        id: String,
        platformID: String,
        offset: CGPoint,
        outcome: PortalOutcome,
        anchor: PortalAnchor = .platformCenter
    ) {
        self.id = id
        self.platformID = platformID
        self.offset = offset
        self.outcome = outcome
        self.anchor = anchor
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
    let portals: [PortalConfiguration]
    let backgroundAssetName: String?
    let movementMode: MoriMovementMode
    let usesProximityConnections: Bool

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
        portals: [PortalConfiguration] = [],
        backgroundAssetName: String? = nil,
        movementMode: MoriMovementMode = .pathfinding,
        usesProximityConnections: Bool = true
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
        self.portals = portals
        self.backgroundAssetName = backgroundAssetName
        self.movementMode = movementMode
        self.usesProximityConnections = usesProximityConnections
    }

    var usesPerspective: Bool {
        interaction == .perspective || interaction == .perspectiveCompact
    }

    var allowsCompact: Bool {
        interaction == .compact || interaction == .perspectiveCompact
    }

    // Keeps the original single-exit levels working while new levels use portals.
    var portalConfigurations: [PortalConfiguration] {
        if !portals.isEmpty {
            return portals
        }

        guard let exitConfiguration,
              !exitPlatformID.isEmpty else {
            return []
        }

        return [
            PortalConfiguration(
                id: "exit",
                platformID: exitConfiguration.platformID,
                offset: exitConfiguration.offset,
                outcome: .completesLevel
            )
        ]
    }
}

typealias LevelConfiguration = GameLevel
