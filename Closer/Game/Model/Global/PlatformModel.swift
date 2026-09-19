import CoreGraphics

enum PlatformRole {
    case walkable
    case obstacle
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

    init(
        id: String,
        horizontalPosition: CGFloat,
        size: CGSize,
        isDraggable: Bool,
        remainsDraggableWhenConnected: Bool,
        frontPosition: CGPoint? = nil,
        sidePosition: CGPoint? = nil,
        role: PlatformRole = .walkable,
        assetName: String? = nil
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
    }

    var isWalkable: Bool {
        role == .walkable
    }
}
