import SpriteKit

final class PlatformNode: SKShapeNode {
    let model: PlatformModel

    static let cellSize: CGFloat = 44.0

    init(model: PlatformModel) {
        self.model = model
        super.init()

        if model.shape == .single1x1 {
            path = CGPath(
                roundedRect: CGRect(origin: CGPoint(x: -model.size.width / 2, y: -model.size.height / 2), size: model.size),
                cornerWidth: 10,
                cornerHeight: 10,
                transform: nil
            )
        } else {
            let mutablePath = CGMutablePath()
            let cells = model.shape.occupiedCells
            let cellSize = PlatformNode.cellSize

            let minDx = cells.map { $0.dx }.min() ?? 0
            let maxDx = cells.map { $0.dx }.max() ?? 0

            let totalCols = CGFloat(maxDx - minDx + 1)
            let offsetX = -(totalCols * cellSize) / 2
            let offsetY = -cellSize / 2

            for cell in cells {
                let cellRect = CGRect(
                    x: offsetX + CGFloat(cell.dx - minDx) * cellSize,
                    y: offsetY + CGFloat(cell.dy) * cellSize,
                    width: cellSize,
                    height: cellSize
                )
                let cellPath = CGPath(
                    roundedRect: cellRect,
                    cornerWidth: 8,
                    cornerHeight: 8,
                    transform: nil
                )
                mutablePath.addPath(cellPath)
            }
            path = mutablePath
        }

        name = model.id
        fillColor = model.assetName == nil && model.isWalkable
            ? (model.isDraggable
                ? SKColor(red: 0.86, green: 0.50, blue: 0.39, alpha: 1.0)
                : SKColor(red: 0.78, green: 0.39, blue: 0.31, alpha: 1.0))
            : .clear
        strokeColor = model.assetName == nil ? .white.withAlphaComponent(0.35) : .clear
        lineWidth = 2

        if let assetName = model.assetName {
            let texture = SKTexture(imageNamed: assetName)
            let asset = SKSpriteNode(texture: texture)
            let textureSize = texture.size()
            let visualBounds = model.visualSize ?? model.size

            if textureSize.width > 0, textureSize.height > 0 {
                let scale = min(
                    visualBounds.width / textureSize.width,
                    visualBounds.height / textureSize.height
                )
                asset.size = CGSize(
                    width: textureSize.width * scale,
                    height: textureSize.height * scale
                )
            } else {
                asset.size = visualBounds
            }
            addChild(asset)
        }
    }

    func occupiedCellRects(at position: CGPoint) -> [CGRect] {
        if model.shape == .single1x1 {
            return [CGRect(origin: CGPoint(x: position.x - model.size.width / 2, y: position.y - model.size.height / 2), size: model.size)]
        }

        let cells = model.shape.occupiedCells
        let cellSize = PlatformNode.cellSize

        let minDx = cells.map { $0.dx }.min() ?? 0
        let maxDx = cells.map { $0.dx }.max() ?? 0

        let totalCols = CGFloat(maxDx - minDx + 1)
        let offsetX = position.x - (totalCols * cellSize) / 2
        let offsetY = position.y - cellSize / 2

        return cells.map { cell in
            CGRect(
                x: offsetX + CGFloat(cell.dx - minDx) * cellSize,
                y: offsetY + CGFloat(cell.dy) * cellSize,
                width: cellSize,
                height: cellSize
            )
        }
    }

    struct PlayableSurface {
        let position: CGPoint
        let cellRect: CGRect
    }

    func playableSurfaces(at position: CGPoint) -> [PlayableSurface] {
        if model.shape == .single1x1 {
            let rect = CGRect(
                origin: CGPoint(x: position.x - model.size.width / 2, y: position.y - model.size.height / 2),
                size: model.size
            )
            return [
                PlayableSurface(
                    position: CGPoint(
                        x: position.x + model.walkableSurfaceOffset.x,
                        y: position.y + model.walkableSurfaceOffset.y + 33
                    ),
                    cellRect: rect
                )
            ]
        }

        let rects = occupiedCellRects(at: position)
        let cells = model.shape.occupiedCells
        let minDx = cells.map { $0.dx }.min() ?? 0

        var topCellsByCol: [Int: CGRect] = [:]
        for (index, cell) in cells.enumerated() {
            let col = cell.dx - minDx
            let cellRect = rects[index]

            // An L's vertical wall is solid geometry, not a landing surface.
            // Keep only exposed cells on its horizontal arm.
            let hasCellAbove = cells.contains {
                $0.dx == cell.dx && $0.dy > cell.dy
            }
            if hasCellAbove {
                continue
            }

            if let existing = topCellsByCol[col] {
                if cellRect.maxY > existing.maxY {
                    topCellsByCol[col] = cellRect
                }
            } else {
                topCellsByCol[col] = cellRect
            }
        }

        let sortedCols = topCellsByCol.keys.sorted()
        return sortedCols.compactMap { col in
            guard let cellRect = topCellsByCol[col] else { return nil }
            return PlayableSurface(
                position: CGPoint(
                    x: cellRect.midX + model.walkableSurfaceOffset.x,
                    y: cellRect.midY + model.walkableSurfaceOffset.y + 33
                ),
                cellRect: cellRect
            )
        }
    }

    func landingPosition(at position: CGPoint, approachingFrom fromPosition: CGPoint) -> CGPoint {
        let surfaces = playableSurfaces(at: position)
        guard !surfaces.isEmpty else {
            return CGPoint(x: position.x, y: position.y + 55)
        }
        if surfaces.count == 1 {
            return surfaces[0].position
        }

        let heightMatchingSurfaces = surfaces.filter { abs($0.position.y - fromPosition.y) <= 8 }
        let candidateSurfaces = heightMatchingSurfaces.isEmpty ? surfaces : heightMatchingSurfaces

        let closest = candidateSurfaces.min { a, b in
            hypot(a.position.x - fromPosition.x, a.position.y - fromPosition.y) <
            hypot(b.position.x - fromPosition.x, b.position.y - fromPosition.y)
        }
        return closest?.position ?? surfaces[0].position
    }

    func landingPosition(approachingFrom fromPosition: CGPoint) -> CGPoint {
        landingPosition(at: position, approachingFrom: fromPosition)
    }

    /// Returns the playable surface whose landing position is closest to `touchPoint`.
    /// Returns `nil` for single1x1 platforms (only one surface; use `landingPosition` instead).
    /// Used to let Mori walk to a specific cell when the user taps inside a multi-cell platform.
    func closestSurface(to touchPoint: CGPoint) -> PlayableSurface? {
        guard model.shape != .single1x1 else { return nil }
        let surfaces = playableSurfaces(at: position)
        return surfaces.min { a, b in
            hypot(a.position.x - touchPoint.x, a.position.y - touchPoint.y) <
            hypot(b.position.x - touchPoint.x, b.position.y - touchPoint.y)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
