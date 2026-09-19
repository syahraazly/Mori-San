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

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
