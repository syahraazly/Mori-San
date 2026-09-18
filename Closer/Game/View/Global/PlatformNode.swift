import SpriteKit

final class PlatformNode: SKShapeNode {
    let model: PlatformModel

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
            let cellWidth: CGFloat = 44
            let cellHeight: CGFloat = 44

            let minDx = cells.map { $0.dx }.min() ?? 0
            let maxDx = cells.map { $0.dx }.max() ?? 0
            let minDy = cells.map { $0.dy }.min() ?? 0
            let maxDy = cells.map { $0.dy }.max() ?? 0

            let totalCols = CGFloat(maxDx - minDx + 1)
            let totalRows = CGFloat(maxDy - minDy + 1)
            let offsetX = -(totalCols * cellWidth) / 2
            let offsetY = -(totalRows * cellHeight) / 2

            for cell in cells {
                let cellRect = CGRect(
                    x: offsetX + CGFloat(cell.dx - minDx) * cellWidth,
                    y: offsetY + CGFloat(cell.dy - minDy) * cellHeight,
                    width: cellWidth,
                    height: cellHeight
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
        fillColor = model.isDraggable
            ? SKColor(red: 0.86, green: 0.50, blue: 0.39, alpha: 1.0)
            : SKColor(red: 0.78, green: 0.39, blue: 0.31, alpha: 1.0)
        strokeColor = .white.withAlphaComponent(0.35)
        lineWidth = 2
    }

    func occupiedCellRects(at position: CGPoint) -> [CGRect] {
        if model.shape == .single1x1 {
            return [CGRect(origin: CGPoint(x: position.x - model.size.width / 2, y: position.y - model.size.height / 2), size: model.size)]
        }

        let cells = model.shape.occupiedCells
        let cellWidth: CGFloat = 44
        let cellHeight: CGFloat = 44

        let minDx = cells.map { $0.dx }.min() ?? 0
        let maxDx = cells.map { $0.dx }.max() ?? 0
        let minDy = cells.map { $0.dy }.min() ?? 0
        let maxDy = cells.map { $0.dy }.max() ?? 0

        let totalCols = CGFloat(maxDx - minDx + 1)
        let totalRows = CGFloat(maxDy - minDy + 1)
        let offsetX = position.x - (totalCols * cellWidth) / 2
        let offsetY = position.y - (totalRows * cellHeight) / 2

        return cells.map { cell in
            CGRect(
                x: offsetX + CGFloat(cell.dx - minDx) * cellWidth,
                y: offsetY + CGFloat(cell.dy - minDy) * cellHeight,
                width: cellWidth,
                height: cellHeight
            )
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
