import CoreGraphics

enum PlatformRole {
    case walkable
    case obstacle
}

enum PlatformEdge: Hashable {
    case left
    case right
}

struct GridOffset: Equatable, Hashable {
    let dx: Int
    let dy: Int
}

enum BlockShape: String, Equatable {
    case single1x1
    case horizontal1x2
    case horizontal1x3
    case lShape
    case reverseLShape

    var occupiedCells: [GridOffset] {
        switch self {
        case .single1x1:
            return [GridOffset(dx: 0, dy: 0)]
        case .horizontal1x2:
            return [GridOffset(dx: 0, dy: 0), GridOffset(dx: 1, dy: 0)]
        case .horizontal1x3:
            return [GridOffset(dx: 0, dy: 0), GridOffset(dx: 1, dy: 0), GridOffset(dx: 2, dy: 0)]
        case .lShape:
            return [GridOffset(dx: 0, dy: 0), GridOffset(dx: 1, dy: 0), GridOffset(dx: 2, dy: 0), GridOffset(dx: 0, dy: 1)]
        case .reverseLShape:
            return [GridOffset(dx: 0, dy: 0), GridOffset(dx: 1, dy: 0), GridOffset(dx: 2, dy: 0), GridOffset(dx: 2, dy: 1)]
        }
    }
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
    let shape: BlockShape

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
        blockedConnectionEdges: Set<PlatformEdge> = [],
        shape: BlockShape = .single1x1
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
        self.shape = shape
    }

    var isWalkable: Bool {
        role == .walkable
    }
}
