import CoreGraphics

enum PlatformRole {
    case walkable
    case obstacle
}

enum PlatformEdge: Hashable {
    case left
    case right
}

struct PlatformModel {
    let id: String
    let horizontalPosition: CGFloat
    let size: CGSize
    let isDraggable: Bool
    let remainsDraggableWhenConnected: Bool
    let frontPosition: CGPoint?
    let sidePosition: CGPoint?
    let role: PlatformRole
    let assetName: String?
    let visualSize: CGSize?
    let walkableSurfaceOffset: CGPoint
    let blockedConnectionEdges: Set<PlatformEdge>

    init(
        id: String,
        horizontalPosition: CGFloat,
        size: CGSize,
        isDraggable: Bool,
        remainsDraggableWhenConnected: Bool,
        frontPosition: CGPoint? = nil,
        sidePosition: CGPoint? = nil,
        role: PlatformRole = .walkable,
        assetName: String? = nil,
        visualSize: CGSize? = nil,
        walkableSurfaceOffset: CGPoint? = nil,
        blockedConnectionEdges: Set<PlatformEdge> = []
    ) {
        self.id = id
        self.horizontalPosition = horizontalPosition
        self.size = size
        self.isDraggable = isDraggable
        self.remainsDraggableWhenConnected = remainsDraggableWhenConnected
        self.frontPosition = frontPosition
        self.sidePosition = sidePosition
        self.role = role
        self.assetName = assetName
        self.visualSize = visualSize
        self.walkableSurfaceOffset = walkableSurfaceOffset
            ?? CGPoint(x: 0, y: size.height / 2)
        self.blockedConnectionEdges = blockedConnectionEdges
    }

    var isWalkable: Bool {
        role == .walkable
    }
}
