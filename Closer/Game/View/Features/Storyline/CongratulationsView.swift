import SpriteKit
import UIKit

/// The chapter completion celebration screen matching the visual and text layout of IMG_5587.
final class CongratulationsView: SKNode {
    private let sceneSize: CGSize
    private let info: FlowerCelebrationInfo
    private let nextGoalID: GoalID?

    private static var cachedGlowTexture: SKTexture?

    init(sceneSize: CGSize, goalID: GoalID, nextGoalID: GoalID? = nil) {
        self.sceneSize = sceneSize
        self.info = FlowerCelebrationInfo.info(for: goalID)
        self.nextGoalID = nextGoalID
        super.init()
        self.name = "congratulations-screen"

        setupAtmosphere()
        setupTitleSection()
        setupCenterVignette()
        setupAboutCard()
        setupActionButtons()
        setupFooter()
        startFloatingPetals()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Atmosphere & Sky

    private func setupAtmosphere() {
        let bg = SKShapeNode(rectOf: sceneSize)
        bg.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)
        bg.fillColor = SKColor(red: 0.42, green: 0.55, blue: 0.72, alpha: 1.0)
        bg.strokeColor = .clear
        bg.zPosition = -10
        addChild(bg)

        // Twinkling stars
        for (i, pos) in [
            CGPoint(x: sceneSize.width * 0.16, y: sceneSize.height * 0.90),
            CGPoint(x: sceneSize.width * 0.84, y: sceneSize.height * 0.90),
            CGPoint(x: sceneSize.width * 0.24, y: sceneSize.height * 0.84),
            CGPoint(x: sceneSize.width * 0.76, y: sceneSize.height * 0.84)
        ].enumerated() {
            let star = SKLabelNode(fontNamed: "AvenirNext-Bold")
            star.text = i.isMultiple(of: 2) ? "✦" : "✧"
            star.fontSize = i.isMultiple(of: 2) ? 18 : 14
            star.fontColor = SKColor(red: 1.0, green: 0.94, blue: 0.70, alpha: 0.9)
            star.position = pos
            star.zPosition = -5
            addChild(star)

            star.run(.repeatForever(.sequence([
                .fadeAlpha(to: 0.3, duration: 0.7 + Double(i) * 0.15),
                .fadeAlpha(to: 1.0, duration: 0.7 + Double(i) * 0.15)
            ])))
        }
    }

    // MARK: - Title Section

    private func setupTitleSection() {
        let titleY = sceneSize.height * 0.865

        let congrats = SKLabelNode(fontNamed: "AvenirNext-Bold")
        congrats.text = "Congratulations!"
        congrats.fontSize = 30
        congrats.fontColor = .white
        congrats.position = CGPoint(x: sceneSize.width / 2, y: titleY)
        addChild(congrats)

        let youGot = SKLabelNode(fontNamed: "AvenirNext-Medium")
        youGot.text = "You got"
        youGot.fontSize = 13.5
        youGot.fontColor = SKColor(red: 0.90, green: 0.93, blue: 0.98, alpha: 0.92)
        youGot.position = CGPoint(x: sceneSize.width / 2, y: titleY - 24)
        addChild(youGot)

        let flowerName = SKLabelNode(fontNamed: "AvenirNext-Bold")
        flowerName.text = info.flowerName
        flowerName.fontSize = 24
        flowerName.fontColor = .white
        flowerName.position = CGPoint(x: sceneSize.width / 2, y: titleY - 50)
        addChild(flowerName)

        let chapterLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        chapterLabel.text = info.chapterSubtitle
        chapterLabel.fontSize = 13.5
        chapterLabel.fontColor = SKColor(red: 0.90, green: 0.93, blue: 0.98, alpha: 0.92)
        chapterLabel.position = CGPoint(x: sceneSize.width / 2, y: titleY - 69)
        addChild(chapterLabel)
    }

    // MARK: - Center Vignette (Mori & Flower)

    private func setupCenterVignette() {
        let platformY = sceneSize.height * 0.565
        let flowerPos = CGPoint(x: sceneSize.width * 0.60, y: platformY + 44)

        // Layered stone pedestal
        let stoneBase = SKShapeNode(rectOf: CGSize(width: sceneSize.width * 0.68, height: 30), cornerRadius: 10)
        stoneBase.position = CGPoint(x: sceneSize.width / 2, y: platformY)
        stoneBase.fillColor = SKColor(red: 0.66, green: 0.72, blue: 0.75, alpha: 1.0)
        stoneBase.strokeColor = SKColor(white: 1.0, alpha: 0.4)
        stoneBase.lineWidth = 1.5
        stoneBase.zPosition = 1
        addChild(stoneBase)

        let mossTop = SKShapeNode(rectOf: CGSize(width: sceneSize.width * 0.64, height: 6), cornerRadius: 3)
        mossTop.position = CGPoint(x: sceneSize.width / 2, y: platformY + 11)
        mossTop.fillColor = SKColor(red: 0.46, green: 0.60, blue: 0.46, alpha: 0.75)
        mossTop.strokeColor = .clear
        mossTop.zPosition = 2
        addChild(mossTop)

        // Realistic, soft radial gradient bloom lighting directly behind blossoms
        let flowerGlow = setupFlowerGlow(at: CGPoint(x: flowerPos.x, y: flowerPos.y + 10))
        addChild(flowerGlow)

        // Blooming flower sprite
        let flower = SKSpriteNode(imageNamed: info.flowerAssetName)
        flower.size = CGSize(width: 148, height: 102)
        flower.position = flowerPos
        flower.zPosition = 4
        addChild(flower)
        flower.run(.repeatForever(.sequence([
            .scale(to: 1.03, duration: 1.2),
            .scale(to: 1.0, duration: 1.2)
        ])))

        // Mori standing on left side of platform looking up towards flower
        let mori = PlayerNode(player: PlayerModel(name: "Mori", startingPlatformID: "celebration"))
        mori.setScale(0.80)
        mori.position = CGPoint(x: sceneSize.width * 0.33, y: platformY + 34)
        mori.setFacing(right: true)
        mori.zPosition = 5
        addChild(mori)
    }

    // MARK: - Realistic Flower Lighting (Smooth Radial Gradient)

    private static func radialGlowTexture() -> SKTexture {
        if let cached = cachedGlowTexture {
            return cached
        }
        let size = CGSize(width: 256, height: 256)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let cgContext = context.cgContext
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = size.width / 2

            // Silky smooth radial light falloff matching IMG_5587 backlight
            let colors = [
                UIColor(red: 1.0, green: 0.99, blue: 0.94, alpha: 0.95).cgColor,
                UIColor(red: 1.0, green: 0.96, blue: 0.82, alpha: 0.62).cgColor,
                UIColor(red: 1.0, green: 0.92, blue: 0.72, alpha: 0.22).cgColor,
                UIColor(red: 1.0, green: 0.90, blue: 0.70, alpha: 0.0).cgColor
            ] as CFArray

            let locations: [CGFloat] = [0.0, 0.24, 0.60, 1.0]
            guard let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors,
                locations: locations
            ) else { return }

            cgContext.drawRadialGradient(
                gradient,
                startCenter: center,
                startRadius: 0,
                endCenter: center,
                endRadius: radius,
                options: .drawsAfterEndLocation
            )
        }
        let texture = SKTexture(image: image)
        cachedGlowTexture = texture
        return texture
    }

    private func setupFlowerGlow(at center: CGPoint) -> SKNode {
        let container = SKNode()
        container.position = center
        container.zPosition = 2

        let texture = Self.radialGlowTexture()

        // Outer soft ambient haze
        let outerGlow = SKSpriteNode(texture: texture)
        outerGlow.size = CGSize(width: 195, height: 180)
        outerGlow.alpha = 0.52
        outerGlow.blendMode = .add
        container.addChild(outerGlow)

        // Inner bright radiant core directly behind the blossoms
        let coreGlow = SKSpriteNode(texture: texture)
        coreGlow.size = CGSize(width: 118, height: 108)
        coreGlow.alpha = 0.80
        coreGlow.blendMode = .add
        container.addChild(coreGlow)

        // Soft, organic breathing pulse
        let pulseOuter = SKAction.repeatForever(SKAction.sequence([
            .group([.scale(to: 1.05, duration: 1.8), .fadeAlpha(to: 0.62, duration: 1.8)]),
            .group([.scale(to: 0.97, duration: 1.8), .fadeAlpha(to: 0.44, duration: 1.8)])
        ]))
        outerGlow.run(pulseOuter)

        let pulseCore = SKAction.repeatForever(SKAction.sequence([
            .group([.scale(to: 1.05, duration: 1.3), .fadeAlpha(to: 0.90, duration: 1.3)]),
            .group([.scale(to: 0.98, duration: 1.3), .fadeAlpha(to: 0.72, duration: 1.3)])
        ]))
        coreGlow.run(pulseCore)

        return container
    }

    // MARK: - About Card

    private func setupAboutCard() {
        let cardY = sceneSize.height * 0.325
        let cardWidth = sceneSize.width * 0.88
        let cardHeight: CGFloat = 212

        let card = SKShapeNode(rectOf: CGSize(width: cardWidth, height: cardHeight), cornerRadius: 22)
        card.position = CGPoint(x: sceneSize.width / 2, y: cardY)
        card.fillColor = SKColor(red: 0.99, green: 0.98, blue: 0.95, alpha: 0.96)
        card.strokeColor = SKColor(white: 1.0, alpha: 0.7)
        card.lineWidth = 1.5
        card.zPosition = 10
        addChild(card)

        // Header: About Forget Me Not (enlarged font: 17)
        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = info.aboutTitle
        title.fontSize = 17
        title.fontColor = SKColor(red: 0.22, green: 0.26, blue: 0.38, alpha: 1.0)
        title.position = CGPoint(x: 0, y: cardHeight / 2 - 25)
        card.addChild(title)

        // Lore paragraph (enlarged font: 13, tighter spacing to remove excess gap)
        let lore = SKLabelNode(fontNamed: "AvenirNext-Regular")
        lore.text = info.aboutDescription
        lore.fontSize = 13
        lore.fontColor = SKColor(red: 0.36, green: 0.38, blue: 0.44, alpha: 1.0)
        lore.numberOfLines = 4
        lore.preferredMaxLayoutWidth = cardWidth - 32
        lore.horizontalAlignmentMode = .center
        lore.verticalAlignmentMode = .top
        lore.position = CGPoint(x: 0, y: cardHeight / 2 - 47)
        card.addChild(lore)

        // Mori learned highlight banner (brought closer to lore text)
        let bannerWidth = cardWidth - 24
        let bannerHeight: CGFloat = 48
        let bannerY = -cardHeight / 2 + 34

        let banner = SKShapeNode(rectOf: CGSize(width: bannerWidth, height: bannerHeight), cornerRadius: 14)
        banner.position = CGPoint(x: 0, y: bannerY)
        banner.fillColor = SKColor(red: 0.88, green: 0.91, blue: 0.98, alpha: 0.90)
        banner.strokeColor = .clear
        card.addChild(banner)

        // Mori avatar icon on the left (28x28)
        let avatar = SKSpriteNode(imageNamed: "mori-idle-1")
        avatar.size = CGSize(width: 28, height: 28)
        avatar.position = CGPoint(x: -bannerWidth / 2 + 22, y: 0)
        banner.addChild(avatar)

        // Quote text (enlarged font: 11.5)
        let quote = SKLabelNode(fontNamed: "AvenirNext-MediumItalic")
        quote.text = info.moriLearnedQuote
        quote.fontSize = 11.5
        quote.fontColor = SKColor(red: 0.30, green: 0.36, blue: 0.52, alpha: 1.0)
        quote.numberOfLines = 2
        quote.preferredMaxLayoutWidth = bannerWidth - 54
        quote.horizontalAlignmentMode = .left
        quote.verticalAlignmentMode = .center
        quote.position = CGPoint(x: -bannerWidth / 2 + 42, y: 0)
        banner.addChild(quote)
    }

    // MARK: - Action Buttons

    private func setupActionButtons() {
        let buttonY = sceneSize.height * 0.115
        let hasNext = nextGoalID != nil

        // Left Button: Only "Start Over" (No icon, no subtitle)
        let leftWidth = sceneSize.width * 0.42
        let leftPos = CGPoint(x: sceneSize.width * 0.27, y: buttonY)
        addSecondaryButton(
            title: "Start Over",
            name: "restart-chapter",
            position: leftPos,
            width: leftWidth
        )

        // Right Button: Only "Next Chapter" / "Back to Map" (No icon, no subtitle)
        let rightWidth = sceneSize.width * 0.44
        let rightPos = CGPoint(x: sceneSize.width * 0.72, y: buttonY)
        let rightTitle = hasNext ? "Next Chapter" : "Back to Map"
        let rightName = hasNext ? "next-chapter" : "return-to-map"

        addPrimaryButton(
            title: rightTitle,
            name: rightName,
            position: rightPos,
            width: rightWidth
        )
    }

    private func addSecondaryButton(
        title: String,
        name: String,
        position: CGPoint,
        width: CGFloat
    ) {
        let container = SKNode()
        container.name = name
        container.position = position
        container.zPosition = 15
        addChild(container)

        let height: CGFloat = 50
        let shape = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 22)
        shape.name = name
        shape.fillColor = SKColor(red: 0.98, green: 0.96, blue: 0.93, alpha: 0.96)
        shape.strokeColor = SKColor(red: 0.85, green: 0.82, blue: 0.78, alpha: 0.6)
        shape.lineWidth = 1.5
        container.addChild(shape)

        // Pure centered label
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.name = name
        label.text = title
        label.fontSize = 15
        label.fontColor = SKColor(red: 0.22, green: 0.26, blue: 0.38, alpha: 1.0)
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: 0)
        container.addChild(label)
    }

    private func addPrimaryButton(
        title: String,
        name: String,
        position: CGPoint,
        width: CGFloat
    ) {
        let container = SKNode()
        container.name = name
        container.position = position
        container.zPosition = 15
        addChild(container)

        let height: CGFloat = 50
        let shape = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 22)
        shape.name = name
        shape.fillColor = SKColor(red: 0.22, green: 0.32, blue: 0.54, alpha: 1.0)
        shape.strokeColor = SKColor(white: 1.0, alpha: 0.25)
        shape.lineWidth = 1.0
        container.addChild(shape)

        // Pure centered label
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.name = name
        label.text = title
        label.fontSize = 15
        label.fontColor = .white
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: 0)
        container.addChild(label)
    }

    // MARK: - Footer

    private func setupFooter() {
        let footer = SKLabelNode(fontNamed: "AvenirNext-Bold")
        footer.text = "🌸   SAME STEPS. A BRIGHTER YOU."
        footer.fontSize = 10.5
        footer.fontColor = .white
        footer.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.042)
        footer.zPosition = 15
        addChild(footer)

        footer.run(.repeatForever(.sequence([
            .fadeAlpha(to: 0.6, duration: 1.5),
            .fadeAlpha(to: 1.0, duration: 1.5)
        ])))
    }

    // MARK: - Floating Petals

    private func startFloatingPetals() {
        let spawnPetal = SKAction.run { [weak self] in
            guard let self else { return }
            let petal = SKSpriteNode(imageNamed: self.info.petalAssetName)
            let scale = CGFloat.random(in: 0.5...0.8)
            petal.size = CGSize(width: 32 * scale, height: 24 * scale)
            petal.position = CGPoint(
                x: CGFloat.random(in: 20...(self.sceneSize.width - 20)),
                y: self.sceneSize.height + 20
            )
            petal.zPosition = 6
            petal.alpha = CGFloat.random(in: 0.5...0.85)
            self.addChild(petal)

            let fallDuration = Double.random(in: 4.5...7.0)
            let endY = -30.0
            let sway = CGFloat.random(in: 30...55)
            let fallAction = SKAction.moveTo(y: endY, duration: fallDuration)
            let swayAction = SKAction.repeatForever(SKAction.sequence([
                .moveBy(x: sway, y: 0, duration: fallDuration / 3),
                .moveBy(x: -sway, y: 0, duration: fallDuration / 3)
            ]))
            let spinAction = SKAction.rotate(byAngle: CGFloat.random(in: -3...3), duration: fallDuration)
            let group = SKAction.group([fallAction, swayAction, spinAction])

            petal.run(group) {
                petal.removeFromParent()
            }
        }

        let loop = SKAction.repeatForever(SKAction.sequence([
            spawnPetal,
            .wait(forDuration: 0.8)
        ]))
        run(loop)
    }
}
