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

struct PetalConfiguration {
    let platformID: String
    let offset: CGPoint
    let assetName: String?
    let perspectivePositionOverrides: [PerspectivePositionOverride]

    init(
        platformID: String,
        offset: CGPoint = CGPoint(x: 0, y: 48),
        assetName: String? = nil,
        perspectivePositionOverrides: [PerspectivePositionOverride] = []
    ) {
        self.platformID = platformID
        self.offset = offset
        self.assetName = assetName
        self.perspectivePositionOverrides = perspectivePositionOverrides
    }
}

/// Optional position changes applied after a petal is collected.
/// This lets a level expose a new perspective route without level-specific code.
struct PerspectivePositionOverride {
    let platformID: String
    let frontPosition: CGPoint?
    let sidePosition: CGPoint?

    init(
        platformID: String,
        frontPosition: CGPoint? = nil,
        sidePosition: CGPoint? = nil
    ) {
        self.platformID = platformID
        self.frontPosition = frontPosition
        self.sidePosition = sidePosition
    }
}

/// Describes a route that only exists after Mori activates its lamp platform.
/// The level data owns which platforms and connections are revealed.
struct LightRevealConfiguration {
    let lampPlatformID: String
    let hiddenPlatformIDs: [String]
    let activatedConnections: [ConnectionModel]
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
    let petalConfiguration: PetalConfiguration?
    let portals: [PortalConfiguration]
    let backgroundAssetName: String?
    let movementMode: MoriMovementMode
    let usesProximityConnections: Bool
    let proximityConnectionTolerance: CGFloat
    let lightRevealConfiguration: LightRevealConfiguration?

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
        petalConfiguration: PetalConfiguration? = nil,
        portals: [PortalConfiguration] = [],
        backgroundAssetName: String? = nil,
        movementMode: MoriMovementMode = .pathfinding,
        usesProximityConnections: Bool = true,
        proximityConnectionTolerance: CGFloat = 10,
        lightRevealConfiguration: LightRevealConfiguration? = nil
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
        self.portals = portals
        self.backgroundAssetName = backgroundAssetName
        self.movementMode = movementMode
        self.usesProximityConnections = usesProximityConnections
        self.proximityConnectionTolerance = proximityConnectionTolerance
        self.lightRevealConfiguration = lightRevealConfiguration
    }

    var usesPerspective: Bool {
        interaction == .perspective || interaction == .perspectiveCompact
    }

    var allowsCompact: Bool {
        interaction == .compact ||
        interaction == .perspectiveCompact ||
        interaction == .perspective
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
