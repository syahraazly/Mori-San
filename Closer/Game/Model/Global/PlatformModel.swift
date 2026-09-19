import CoreGraphics

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
    let shape: BlockShape

    init(
        id: String,
        horizontalPosition: CGFloat,
        size: CGSize,
        isDraggable: Bool,
        remainsDraggableWhenConnected: Bool,
        frontPosition: CGPoint? = nil,
        sidePosition: CGPoint? = nil,
        shape: BlockShape = .single1x1
    ) {
        self.id = id
        self.horizontalPosition = horizontalPosition
        self.size = size
        self.isDraggable = isDraggable
        self.remainsDraggableWhenConnected = remainsDraggableWhenConnected
        self.frontPosition = frontPosition
        self.sidePosition = sidePosition
        self.shape = shape
    }

    var effectiveWidth: CGFloat {
        if shape == .single1x1 {
            return size.width
        }
        let minDx = shape.occupiedCells.map { $0.dx }.min() ?? 0
        let maxDx = shape.occupiedCells.map { $0.dx }.max() ?? 0
        return CGFloat(maxDx - minDx + 1) * 44.0
    }

    var effectiveHeight: CGFloat {
        if shape == .single1x1 {
            return size.height
        }
        let minDy = shape.occupiedCells.map { $0.dy }.min() ?? 0
        let maxDy = shape.occupiedCells.map { $0.dy }.max() ?? 0
        return CGFloat(maxDy - minDy + 1) * 44.0
    }
}
