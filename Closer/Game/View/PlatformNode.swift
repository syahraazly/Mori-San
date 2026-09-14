import SpriteKit

final class PlatformNode: SKShapeNode {
    let model: PlatformModel

    init(model: PlatformModel) {
        self.model = model
        super.init()

        path = CGPath(
            roundedRect: CGRect(origin: CGPoint(x: -model.size.width / 2, y: -model.size.height / 2), size: model.size),
            cornerWidth: 10,
            cornerHeight: 10,
            transform: nil
        )
        name = model.id
        fillColor = model.isDraggable
            ? SKColor(red: 0.86, green: 0.50, blue: 0.39, alpha: 1.0)
            : SKColor(red: 0.78, green: 0.39, blue: 0.31, alpha: 1.0)
        strokeColor = .white.withAlphaComponent(0.35)
        lineWidth = 2
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
