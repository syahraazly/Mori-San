import SpriteKit
import UIKit

/// An interactive, game-like chapter finale sequence where collected petals
/// assemble and merge into the fully bloomed chapter flower before revealing congratulations.
final class FlowerRevealView: SKNode {
    private let sceneSize: CGSize
    private let info: FlowerCelebrationInfo
    private(set) var isBloomed = false

    private static var cachedGlowTexture: SKTexture?

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

    private var petalNodes: [SKNode] = []
    private var centerGlowNode: SKShapeNode?
    private var flowerContainer: SKNode?
    private var titleLabel: SKLabelNode?
    private var subtitleLabel: SKLabelNode?
    private var followUpLabel: SKLabelNode?
    private var tapPromptNode: SKNode?
    private var moriNode: PlayerNode?

    private let goalID: GoalID

    init(sceneSize: CGSize, goalID: GoalID) {
        self.sceneSize = sceneSize
        self.goalID = goalID
        self.info = FlowerCelebrationInfo.info(for: goalID)
        super.init()
        self.name = "flower-reveal-screen"

        setupAtmosphere()
        setupHeader()
        setupPlatformAndMori()
        setupPetalConvergence()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup Elements

    private func setupAtmosphere() {
        if let chapter = MapChapterData.chapter(for: goalID) {
            let bg = SKSpriteNode(imageNamed: chapter.backgroundAssetName)
            bg.size = sceneSize
            bg.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)
            bg.zPosition = -10
            addChild(bg)
        } else {
            let bg = SKShapeNode(rectOf: sceneSize)
            bg.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)
            bg.fillColor = SKColor(red: 0.42, green: 0.55, blue: 0.72, alpha: 1.0)
            bg.strokeColor = .clear
            bg.zPosition = -10
            addChild(bg)
        }

        // Twinkling stars in sky
        for (i, offset) in [
            CGPoint(x: sceneSize.width * 0.18, y: sceneSize.height * 0.88),
            CGPoint(x: sceneSize.width * 0.82, y: sceneSize.height * 0.90),
            CGPoint(x: sceneSize.width * 0.25, y: sceneSize.height * 0.68),
            CGPoint(x: sceneSize.width * 0.85, y: sceneSize.height * 0.64),
            CGPoint(x: sceneSize.width * 0.50, y: sceneSize.height * 0.84)
        ].enumerated() {
            let star = SKLabelNode(fontNamed: "Montserrat-Bold")
            star.text = i.isMultiple(of: 2) ? "✦" : "✧"
            star.fontSize = i.isMultiple(of: 2) ? 22 : 17
            star.fontColor = SKColor(red: 1.0, green: 0.93, blue: 0.65, alpha: 0.85)
            star.position = offset
            star.zPosition = -5
            addChild(star)

            let pulse = SKAction.sequence([
                .fadeAlpha(to: 0.25, duration: Double(0.6 + Double(i) * 0.2)),
                .fadeAlpha(to: 0.95, duration: Double(0.6 + Double(i) * 0.2))
            ])
            star.run(.repeatForever(pulse))
        }
    }

    private func setupHeader() {
        let cardWidth = sceneSize.width * 0.90
        // Card sits just above the flower (flower center = height * 0.55)
        // Small top margin: card top at 0.72, bottom at 0.59 (tight above flower)
        let cardTop: CGFloat = sceneSize.height * 0.72
        let cardBottom: CGFloat = sceneSize.height * 0.59
        let cardHeight = cardTop - cardBottom
        let cardY = (cardTop + cardBottom) / 2
        
        let headerCard = SKShapeNode(rectOf: CGSize(width: cardWidth, height: cardHeight), cornerRadius: 16)
        headerCard.position = CGPoint(x: sceneSize.width / 2, y: cardY)
        headerCard.fillColor = SKColor(red: 0.12, green: 0.15, blue: 0.24, alpha: 0.65)
        headerCard.strokeColor = SKColor.white.withAlphaComponent(0.35)
        headerCard.lineWidth = 1.2
        headerCard.zPosition = 3
        addChild(headerCard)

        // Chapter title: small gap from card top (0.72 - tiny margin = 0.69)
        let tagY = sceneSize.height * 0.69
        let chapterTitle = MapChapterData.chapter(for: goalID)?.progressionTitle.uppercased() ?? "SCARS TO YOUR BEAUTIFUL"
        
        let tagShadow = SKLabelNode(fontNamed: "AvenirNext-Bold")
        tagShadow.text = chapterTitle
        tagShadow.fontSize = 12.5
        tagShadow.fontColor = SKColor.black.withAlphaComponent(0.7)
        tagShadow.position = CGPoint(x: sceneSize.width / 2 + 1, y: tagY - 1.5)
        tagShadow.zPosition = 5.9
        addChild(tagShadow)

        let tag = SKLabelNode(fontNamed: "AvenirNext-Bold")
        tag.text = chapterTitle
        tag.fontSize = 12.5
        tag.fontColor = SKColor(red: 1.0, green: 0.88, blue: 0.50, alpha: 1.0)
        tag.position = CGPoint(x: sceneSize.width / 2, y: tagY)
        tag.zPosition = 6
        addChild(tag)

        // Narrative text below chapter title, still inside card
        let titleY = sceneSize.height * 0.64
        if let narrative = info.endingNarrative {
            let titleShadow = SKLabelNode(fontNamed: "AvenirNext-Bold")
            titleShadow.text = narrative
            titleShadow.fontSize = 17.5
            titleShadow.numberOfLines = 2
            titleShadow.preferredMaxLayoutWidth = cardWidth - 28
            titleShadow.fontColor = SKColor.black.withAlphaComponent(0.75)
            titleShadow.position = CGPoint(x: sceneSize.width / 2 + 1, y: titleY - 1.5)
            titleShadow.zPosition = 5.9
            addChild(titleShadow)
        }

        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = info.endingNarrative
        title.fontSize = 17.5
        title.numberOfLines = 2
        title.preferredMaxLayoutWidth = cardWidth - 28
        title.fontColor = .white
        title.position = CGPoint(x: sceneSize.width / 2, y: titleY)
        title.zPosition = 6
        addChild(title)
        self.titleLabel = title

        // Subtitle (post-bloom: "Forget-me-not Bloomed!") — placed above flower
        let subtitleY = sceneSize.height * 0.69
        let subtitle = SKLabelNode(fontNamed: "AvenirNext-Medium")
        subtitle.fontSize = 15
        subtitle.fontColor = SKColor(red: 0.92, green: 0.94, blue: 0.98, alpha: 0.92)
        subtitle.position = CGPoint(x: sceneSize.width / 2, y: subtitleY)
        subtitle.zPosition = 6
        addChild(subtitle)
        self.subtitleLabel = subtitle

        if let endingFollowUp = info.endingFollowUp {
            let followUpY = sceneSize.height * 0.61
            let followUpShadow = SKLabelNode(fontNamed: "AvenirNext-Medium")
            followUpShadow.text = endingFollowUp
            followUpShadow.fontSize = 13
            followUpShadow.fontColor = SKColor.black.withAlphaComponent(0.7)
            followUpShadow.position = CGPoint(x: sceneSize.width / 2 + 1, y: followUpY - 1.5)
            followUpShadow.zPosition = 5.9
            addChild(followUpShadow)

            let followUp = SKLabelNode(fontNamed: "AvenirNext-Medium")
            followUp.text = endingFollowUp
            followUp.fontSize = 13.5
            followUp.fontColor = SKColor(red: 0.92, green: 0.94, blue: 0.98, alpha: 0.88)
            followUp.position = CGPoint(x: sceneSize.width / 2, y: followUpY)
            followUp.zPosition = 6
            addChild(followUp)
            self.followUpLabel = followUp
        }
    }

    private func setupPlatformAndMori() {
        let platformY = sceneSize.height * 0.48

        // Stone pedestal
        let stoneBase = SKShapeNode(rectOf: CGSize(width: sceneSize.width * 0.72, height: 38), cornerRadius: 14)
        stoneBase.position = CGPoint(x: sceneSize.width / 2, y: platformY)
        stoneBase.fillColor = SKColor(red: 0.65, green: 0.71, blue: 0.74, alpha: 1.0)
        stoneBase.strokeColor = SKColor(white: 1.0, alpha: 0.4)
        stoneBase.lineWidth = 1.5
        stoneBase.zPosition = 1
        addChild(stoneBase)

        let mossHighlight = SKShapeNode(rectOf: CGSize(width: sceneSize.width * 0.68, height: 8), cornerRadius: 4)
        mossHighlight.position = CGPoint(x: sceneSize.width / 2, y: platformY + 14)
        mossHighlight.fillColor = SKColor(red: 0.48, green: 0.62, blue: 0.48, alpha: 0.70)
        mossHighlight.strokeColor = .clear
        mossHighlight.zPosition = 2
        addChild(mossHighlight)

        // Mori standing on the left side of stone platform looking right
        let mori = PlayerNode(player: PlayerModel(name: "Mori", startingPlatformID: "reveal"))
        mori.setScale(0.85)
        mori.position = CGPoint(x: sceneSize.width * 0.32, y: platformY + 38)
        mori.setFacing(right: true)
        mori.zPosition = 5
        addChild(mori)
        self.moriNode = mori
    }

    private func setupPetalConvergence() {
        let flowerCenter = CGPoint(x: sceneSize.width * 0.62, y: sceneSize.height * 0.55)

        // Center glow orb (grows as petals merge)
        let orb = SKShapeNode(circleOfRadius: 20)
        orb.position = flowerCenter
        orb.fillColor = SKColor(red: 1.0, green: 0.95, blue: 0.70, alpha: 0.0)
        orb.strokeColor = .clear
        orb.zPosition = 10
        addChild(orb)
        self.centerGlowNode = orb

        // Spawn petals around flowerCenter
        let count = info.totalPetals
        let radius: CGFloat = 96
        petalNodes.removeAll()

        for i in 0..<count {
            let angle = (2 * .pi / CGFloat(count)) * CGFloat(i) - (.pi / 2)
            let startPos = CGPoint(
                x: flowerCenter.x + cos(angle) * radius,
                y: flowerCenter.y + sin(angle) * radius
            )

            let petalContainer = SKNode()
            petalContainer.position = startPos
            petalContainer.zPosition = 12

            let petal = SKSpriteNode(imageNamed: info.petalAssetName)
            petal.size = CGSize(width: 36, height: 26)
            petal.zRotation = angle + .pi / 2
            petalContainer.addChild(petal)

            // Sparkle on each petal
            let sparkle = SKLabelNode(fontNamed: "Montserrat-Bold")
            sparkle.text = "✦"
            sparkle.fontSize = 15
            sparkle.fontColor = SKColor(red: 1.0, green: 0.94, blue: 0.60, alpha: 0.9)
            sparkle.position = CGPoint(x: 0, y: 12)
            petalContainer.addChild(sparkle)

            addChild(petalContainer)
            petalNodes.append(petalContainer)

            // Phase 1: Floating bob
            let bobDistance: CGFloat = 6.0
            let bobAction = SKAction.repeatForever(SKAction.sequence([
                .moveBy(x: cos(angle) * bobDistance, y: sin(angle) * bobDistance, duration: 0.6 + Double(i) * 0.1),
                .moveBy(x: -cos(angle) * bobDistance, y: -sin(angle) * bobDistance, duration: 0.6 + Double(i) * 0.1)
            ]))
            petalContainer.run(bobAction, withKey: "bob")
        }

        // Phase 2: Convergence sequence after 0.8 seconds
        let delay = SKAction.wait(forDuration: 0.8)
        let converge = SKAction.run { [weak self] in
            self?.runConvergenceAnimation(towards: flowerCenter)
        }
        run(SKAction.sequence([delay, converge]), withKey: "convergenceSequence")
    }

    private func runConvergenceAnimation(towards center: CGPoint) {
        guard !isBloomed else { return }

        // Expand glow orb in the center
        if let orb = centerGlowNode {
            let orbPulse = SKAction.sequence([
                .fadeAlpha(to: 0.85, duration: 0.8),
                .scale(to: 1.8, duration: 0.5)
            ])
            orb.run(orbPulse)
        }

        // Move all petals spiraling inward
        for (i, petalNode) in petalNodes.enumerated() {
            petalNode.removeAction(forKey: "bob")

            let duration: TimeInterval = 1.2
            let moveInward = SKAction.move(to: center, duration: duration)
            moveInward.timingMode = .easeIn

            let spin = SKAction.rotate(byAngle: .pi * 2.5, duration: duration)
            let shrink = SKAction.scale(to: 0.4, duration: duration)
            let fade = SKAction.sequence([
                .wait(forDuration: duration * 0.7),
                .fadeOut(withDuration: duration * 0.3)
            ])

            let group = SKAction.group([moveInward, spin, shrink, fade])
            petalNode.run(group) {
                petalNode.removeFromParent()
            }
        }

        // Climax when petals reach center
        let wait = SKAction.wait(forDuration: 1.25)
        let bloom = SKAction.run { [weak self] in
            self?.triggerFlowerBloom(at: center)
        }
        run(SKAction.sequence([wait, bloom]), withKey: "bloomAction")
    }

    private func triggerFlowerBloom(at center: CGPoint) {
        guard !isBloomed else { return }
        isBloomed = true

        // Clean up remaining petal nodes
        for node in petalNodes {
            node.removeFromParent()
        }
        petalNodes.removeAll()

        // Flash shockwave
        let flash = SKShapeNode(circleOfRadius: 40)
        flash.position = center
        flash.fillColor = SKColor(red: 1.0, green: 0.98, blue: 0.85, alpha: 0.9)
        flash.strokeColor = .white
        flash.lineWidth = 3
        flash.zPosition = 15
        addChild(flash)

        let expandFlash = SKAction.group([
            .scale(to: 2.8, duration: 0.4),
            .fadeOut(withDuration: 0.4)
        ])
        flash.run(expandFlash) {
            flash.removeFromParent()
        }

        // Star sparkles burst outward
        for i in 0..<10 {
            let spark = SKLabelNode(fontNamed: "Montserrat-Bold")
            spark.text = i.isMultiple(of: 2) ? "✦" : "✧"
            spark.fontSize = CGFloat.random(in: 18...26)
            spark.fontColor = SKColor(red: 1.0, green: 0.92, blue: 0.50, alpha: 1.0)
            spark.position = center
            spark.zPosition = 16
            addChild(spark)

            let burstAngle = (2 * .pi / 10) * CGFloat(i)
            let distance: CGFloat = CGFloat.random(in: 70...110)
            let burstMove = SKAction.moveBy(
                x: cos(burstAngle) * distance,
                y: sin(burstAngle) * distance,
                duration: 0.55
            )
            burstMove.timingMode = .easeOut
            let burstFade = SKAction.fadeOut(withDuration: 0.55)
            let burstGroup = SKAction.group([burstMove, burstFade, .scale(to: 0.5, duration: 0.55)])
            spark.run(burstGroup) {
                spark.removeFromParent()
            }
        }

        // Create Bloomed Flower
        let flowerGroup = SKNode()
        flowerGroup.name = "bloomed-flower-container"
        flowerGroup.position = center
        flowerGroup.zPosition = 14
        addChild(flowerGroup)
        self.flowerContainer = flowerGroup

        // Realistic, soft radial gradient bloom lighting directly behind blossoms
        let texture = Self.radialGlowTexture()

        let outerGlow = SKSpriteNode(texture: texture)
        outerGlow.size = CGSize(width: 215, height: 200)
        outerGlow.alpha = 0.52
        outerGlow.blendMode = .add
        outerGlow.zPosition = -2
        outerGlow.position = CGPoint(x: 0, y: 10)
        flowerGroup.addChild(outerGlow)

        let coreGlow = SKSpriteNode(texture: texture)
        coreGlow.size = CGSize(width: 130, height: 120)
        coreGlow.alpha = 0.80
        coreGlow.blendMode = .add
        coreGlow.zPosition = -1
        coreGlow.position = CGPoint(x: 0, y: 10)
        flowerGroup.addChild(coreGlow)

        outerGlow.run(.repeatForever(.sequence([
            .group([.scale(to: 1.05, duration: 1.8), .fadeAlpha(to: 0.62, duration: 1.8)]),
            .group([.scale(to: 0.97, duration: 1.8), .fadeAlpha(to: 0.44, duration: 1.8)])
        ])))
        coreGlow.run(.repeatForever(.sequence([
            .group([.scale(to: 1.05, duration: 1.3), .fadeAlpha(to: 0.90, duration: 1.3)]),
            .group([.scale(to: 0.98, duration: 1.3), .fadeAlpha(to: 0.72, duration: 1.3)])
        ])))

        // Flower sprite
        let flowerSprite = SKSpriteNode(imageNamed: info.flowerAssetName)
        flowerSprite.name = "bloomed-flower-sprite"
        flowerSprite.size = CGSize(width: 175, height: 120)
        flowerGroup.addChild(flowerSprite)

        // Spring bloom entrance
        flowerGroup.setScale(0.05)
        let springPop = SKAction.sequence([
            .scale(to: 1.18, duration: 0.32),
            .scale(to: 0.96, duration: 0.16),
            .scale(to: 1.0, duration: 0.14)
        ])
        flowerGroup.run(springPop)

        // Gentle breathing animation after popping
        let breathe = SKAction.repeatForever(.sequence([
            .scale(to: 1.04, duration: 0.9),
            .scale(to: 1.0, duration: 0.9)
        ]))
        flowerGroup.run(.sequence([.wait(forDuration: 0.65), breathe]))

        // Mori does a joyful celebration hop!
        if let mori = moriNode {
            let jump = SKAction.sequence([
                .moveBy(x: 0, y: 18, duration: 0.18),
                .moveBy(x: 0, y: -18, duration: 0.18)
            ])
            mori.run(.repeatForever(.sequence([jump, .wait(forDuration: 1.5)])))
        }

        // Drifting celebratory falling petals
        startDriftingPetals()

        // Update labels
        titleLabel?.text = "\(info.flowerName) Bloomed!"
        subtitleLabel?.text = "Touch the flower to receive its memory"

        // Tap prompt badge
        showTapPrompt(near: CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.26))
        HapticManager.playSnapFeedback()
    }

    private func showTapPrompt(near position: CGPoint) {
        let promptContainer = SKNode()
        promptContainer.name = "tap-prompt-container"
        promptContainer.position = position
        promptContainer.zPosition = 20
        addChild(promptContainer)
        self.tapPromptNode = promptContainer

        let buttonShape = SKShapeNode(rectOf: CGSize(width: sceneSize.width * 0.64, height: 48), cornerRadius: 24)
        buttonShape.fillColor = SKColor(red: 0.22, green: 0.32, blue: 0.54, alpha: 0.95)
        buttonShape.strokeColor = SKColor(white: 1.0, alpha: 0.7)
        buttonShape.lineWidth = 1.5
        promptContainer.addChild(buttonShape)

        let label = SKLabelNode(fontNamed: "Montserrat-Bold")
        label.text = "✦  Tap to Celebrate  ✦"
        label.fontSize = 15
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        promptContainer.addChild(label)

        // Pulsing bounce animation
        let pulse = SKAction.repeatForever(.sequence([
            .group([.scale(to: 1.06, duration: 0.65), .fadeAlpha(to: 1.0, duration: 0.65)]),
            .group([.scale(to: 0.98, duration: 0.65), .fadeAlpha(to: 0.85, duration: 0.65)])
        ]))
        promptContainer.run(pulse)
    }

    private func startDriftingPetals() {
        let spawnPetal = SKAction.run { [weak self] in
            guard let self, self.isBloomed else { return }
            let driftPetal = SKSpriteNode(imageNamed: self.info.petalAssetName)
            let sizeScale = CGFloat.random(in: 0.5...0.85)
            driftPetal.size = CGSize(width: 32 * sizeScale, height: 24 * sizeScale)
            driftPetal.position = CGPoint(
                x: CGFloat.random(in: 20...(self.sceneSize.width - 20)),
                y: self.sceneSize.height + 20
            )
            driftPetal.zPosition = 8
            driftPetal.alpha = CGFloat.random(in: 0.6...0.9)
            self.addChild(driftPetal)

            let fallDuration = Double.random(in: 3.5...5.5)
            let endY = -30.0
            let swayAmount = CGFloat.random(in: 30...60)
            let fallAction = SKAction.moveTo(y: endY, duration: fallDuration)
            let swayAction = SKAction.repeatForever(SKAction.sequence([
                .moveBy(x: swayAmount, y: 0, duration: fallDuration / 3),
                .moveBy(x: -swayAmount, y: 0, duration: fallDuration / 3)
            ]))
            let spinAction = SKAction.rotate(byAngle: CGFloat.random(in: -4...4), duration: fallDuration)
            let group = SKAction.group([fallAction, swayAction, spinAction])

            driftPetal.run(group) {
                driftPetal.removeFromParent()
            }
        }

        let loop = SKAction.repeatForever(SKAction.sequence([
            spawnPetal,
            .wait(forDuration: 0.55)
        ]))
        run(loop, withKey: "fallingPetals")
    }

    // MARK: - Interactive Actions

    /// If player taps during petal gathering, fast-forward to bloomed state so there is no forced wait.
    func fastForwardToBloomed() {
        removeAction(forKey: "convergenceSequence")
        removeAction(forKey: "bloomAction")
        let center = CGPoint(x: sceneSize.width * 0.62, y: sceneSize.height * 0.55)
        triggerFlowerBloom(at: center)
    }

    /// Plays celebration burst upon tapping the bloomed flower and executes completion.
    func playBloomTapCelebration(completion: @escaping () -> Void) {
        guard let flowerContainer else {
            completion()
            return
        }

        HapticManager.playSnapFeedback()

        // Flower pulse burst
        let pop = SKAction.sequence([
            .scale(to: 1.25, duration: 0.18),
            .scale(to: 1.0, duration: 0.15)
        ])
        flowerContainer.run(pop)

        // Sparkle explosion
        for i in 0..<12 {
            let spark = SKLabelNode(fontNamed: "Montserrat-Bold")
            spark.text = "✦"
            spark.fontSize = 24
            spark.fontColor = SKColor(red: 1.0, green: 0.95, blue: 0.65, alpha: 1.0)
            spark.position = flowerContainer.position
            spark.zPosition = 25
            addChild(spark)

            let angle = (2 * .pi / 12) * CGFloat(i)
            let move = SKAction.moveBy(x: cos(angle) * 120, y: sin(angle) * 120, duration: 0.4)
            move.timingMode = .easeOut
            let fade = SKAction.fadeOut(withDuration: 0.4)
            spark.run(.group([move, fade])) {
                spark.removeFromParent()
            }
        }

        run(.sequence([
            .wait(forDuration: 0.35),
            .run(completion)
        ]))
    }
}
