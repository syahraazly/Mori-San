import SpriteKit
import UIKit

// MARK: - Chapter Completion

final class ChapterCompletionView: SKNode {
    private enum Phase {
        case narration
        case blooming
        case completion
    }
    
    private let sceneSize: CGSize
    private let chapter: MapChapterConfiguration
    private let goal: FlowerGoal
    private let completionMessage: String
    private let isFinalChapter: Bool
    
    private var phase: Phase = .completion
    private var config: EndingChapterConfig?
    private var currentBeatIndex = 0
    private var narrationContainer: SKNode?
    
    private var isTransitioningBeat = false
    private var canContinue = false

    init?(sceneSize: CGSize, goalID: GoalID, isFinalChapter: Bool) {
        guard let chapter = MapChapterData.chapter(for: goalID),
              let goal = FlowerGoalData.goal(for: goalID) else {
            return nil
        }

        self.sceneSize = sceneSize
        self.chapter = chapter
        self.goal = goal
        self.completionMessage = FlowerCelebrationInfo.info(for: goalID).moriLearnedQuote
        self.isFinalChapter = isFinalChapter
        self.config = EndingChapterConfig.config(for: goalID)
        
        super.init()

        name = "chapter-completion-screen"
        
        if config != nil {
            setupNarrationPhase()
        } else {
            setupCompletionPhase()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func handleTap(at location: CGPoint) -> Bool {
        switch phase {
        case .narration:
            guard !isTransitioningBeat else { return false }
            guard let config = config else { return false }
            
            if let skipNode = narrationContainer?.childNode(withName: "ui-layer/narration-skip"),
               skipNode.contains(location) {
                transitionToBlooming()
                return false
            }
            
            if currentBeatIndex < config.beats.count - 1 {
                advanceBeat()
            } else {
                transitionToBlooming()
            }
            return false
            
        case .blooming:
            return false
            
        case .completion:
            guard canContinue,
                  containsNode(named: "chapter-completion-continue", at: location) else {
                return false
            }
            return true
        }
    }
    
    // MARK: - Narration Phase
    
    private func setupNarrationPhase() {
        phase = .narration
        let container = SKNode()
        addChild(container)
        self.narrationContainer = container
        
        // --- Artwork layer (fades in first) ---
        let artworkNode = SKNode()
        artworkNode.name = "artwork-layer"
        artworkNode.alpha = 0
        container.addChild(artworkNode)
        
        if let bgName = config?.backgroundName {
            let bg = SKSpriteNode(imageNamed: bgName)
            bg.name = "background-sprite"
            bg.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)
            let scale = max(sceneSize.width / bg.size.width, sceneSize.height / bg.size.height)
            bg.setScale(scale)
            bg.zPosition = -1
            artworkNode.addChild(bg)
        }
        
        let texture1 = SKTexture(imageNamed: "mori-idle-1")
        let texture2 = SKTexture(imageNamed: "mori-idle-2")
        
        let targetHeight: CGFloat = 150
        let aspectRatio = texture1.size().width / max(texture1.size().height, 1)
        let targetSize = CGSize(width: targetHeight * aspectRatio, height: targetHeight)
        
        let mori = SKSpriteNode(texture: texture1, size: targetSize)
        mori.name = "mori-sprite"
        // Position center so the bottom of the sprite is 40 points above the bottom edge
        mori.position = CGPoint(x: sceneSize.width / 2, y: (targetSize.height / 2) + 40)
        artworkNode.addChild(mori)
        
        let idleAction = SKAction.repeatForever(SKAction.animate(with: [
            texture1, texture2
        ], timePerFrame: 0.55, resize: false, restore: false))
        mori.run(idleAction, withKey: "idle")
        
        // --- UI layer (narration + Skip, fades in slightly after artwork) ---
        let uiNode = SKNode()
        uiNode.name = "ui-layer"
        uiNode.alpha = 0
        container.addChild(uiNode)
        
        let textY = sceneSize.height * 0.55
        
        let narrationLabel = SKLabelNode(fontNamed: "Montserrat-Medium")
        narrationLabel.name = "narration-label"
        narrationLabel.fontSize = 18
        narrationLabel.fontColor = .white
        narrationLabel.numberOfLines = 0
        narrationLabel.preferredMaxLayoutWidth = sceneSize.width * 0.8
        narrationLabel.horizontalAlignmentMode = .center
        narrationLabel.position = CGPoint(x: sceneSize.width / 2, y: textY)
        
        let shadow1 = SKLabelNode(fontNamed: "Montserrat-Medium")
        shadow1.name = "narration-shadow"
        shadow1.fontSize = 18
        shadow1.fontColor = SKColor.black.withAlphaComponent(0.6)
        shadow1.numberOfLines = 0
        shadow1.preferredMaxLayoutWidth = sceneSize.width * 0.8
        shadow1.horizontalAlignmentMode = .center
        shadow1.position = CGPoint(x: sceneSize.width / 2, y: textY - 2)
        shadow1.zPosition = -0.1
        
        let thoughtLabel = SKLabelNode(fontNamed: "Montserrat-Italic")
        thoughtLabel.name = "thought-label"
        thoughtLabel.fontSize = 18
        thoughtLabel.fontColor = .white
        thoughtLabel.numberOfLines = 0
        thoughtLabel.preferredMaxLayoutWidth = sceneSize.width * 0.8
        thoughtLabel.horizontalAlignmentMode = .center
        thoughtLabel.position = CGPoint(x: sceneSize.width / 2, y: textY - 80)
        
        let shadow2 = SKLabelNode(fontNamed: "Montserrat-Italic")
        shadow2.name = "thought-shadow"
        shadow2.fontSize = 18
        shadow2.fontColor = SKColor.black.withAlphaComponent(0.6)
        shadow2.numberOfLines = 0
        shadow2.preferredMaxLayoutWidth = sceneSize.width * 0.8
        shadow2.horizontalAlignmentMode = .center
        shadow2.position = CGPoint(x: sceneSize.width / 2, y: textY - 82)
        shadow2.zPosition = -0.1
        
        uiNode.addChild(shadow1)
        uiNode.addChild(narrationLabel)
        uiNode.addChild(shadow2)
        uiNode.addChild(thoughtLabel)
        
        let skipLabel = SKLabelNode(fontNamed: "Montserrat-Medium")
        skipLabel.name = "narration-skip"
        skipLabel.text = "Skip"
        skipLabel.fontSize = 15
        skipLabel.fontColor = SKColor.white.withAlphaComponent(0.7)
        // sceneSize.height * 0.88 places Skip ~12% from the top in portrait,
        // matching the visual position of the Storyline Skip (safeArea top + ~20pt padding).
        // This is proportional rather than a hardcoded pixel value.
        skipLabel.position = CGPoint(x: sceneSize.width - 32, y: sceneSize.height * 0.88)
        skipLabel.zPosition = 50
        uiNode.addChild(skipLabel)
        
        // --- Entrance animation ---
        // Artwork fades in immediately over 0.85s.
        artworkNode.run(.fadeIn(withDuration: 0.85))
        // Narration UI fades in 0.35s later, giving artwork a head start.
        uiNode.run(.sequence([
            .wait(forDuration: 0.35),
            .fadeIn(withDuration: 0.65)
        ]))
        
        renderCurrentBeat()
    }

    
    private func advanceBeat() {
        guard let config = config,
              let container = narrationContainer else { return }
        isTransitioningBeat = true

        let nextIndex   = currentBeatIndex + 1
        let currentBeat = config.beats[currentBeatIndex]
        let nextBeat    = config.beats[nextIndex]

        // True cross-dissolve only when BOTH beats use composed per-beat assets.
        // Fallback chapters and mixed transitions use the simple fade-swap path.
        if currentBeat.assetName != nil, let nextAssetName = nextBeat.assetName {
            performCrossDissolve(
                nextAssetName: nextAssetName,
                nextIndex: nextIndex,
                container: container
            )
        } else {
            performSimpleTransition(nextIndex: nextIndex, container: container)
        }
    }

    // MARK: - Cross-Dissolve (composed-asset → composed-asset)

    private func performCrossDissolve(
        nextAssetName: String,
        nextIndex: Int,
        container: SKNode
    ) {
        let dissolveDuration: TimeInterval = 0.32
        let textOutDuration:  TimeInterval = 0.15
        let textInDelay:      TimeInterval = 0.10
        let textInDuration:   TimeInterval = 0.20

        guard let artworkNode = container.childNode(withName: "artwork-layer"),
              let bgSprite = container.childNode(withName: "artwork-layer/background-sprite")
                  as? SKSpriteNode
        else {
            // Node structure unexpected — fall back to simple swap.
            performSimpleTransition(nextIndex: nextIndex, container: container)
            return
        }

        let textNodes: [SKNode] = [
            container.childNode(withName: "ui-layer/narration-label"),
            container.childNode(withName: "ui-layer/narration-shadow"),
            container.childNode(withName: "ui-layer/thought-label"),
            container.childNode(withName: "ui-layer/thought-shadow")
        ].compactMap { $0 }

        // Build incoming sprite starting at 0.98x for a subtle zoom-in feel.
        let incomingTexture = SKTexture(imageNamed: nextAssetName)
        let targetScale = max(
            sceneSize.width  / incomingTexture.size().width,
            sceneSize.height / incomingTexture.size().height
        )
        let incomingSprite = SKSpriteNode(texture: incomingTexture)
        incomingSprite.name      = "incoming-sprite"
        incomingSprite.position  = bgSprite.position
        incomingSprite.zPosition = bgSprite.zPosition + 0.5   // renders on top of outgoing
        incomingSprite.setScale(targetScale * 0.98)
        incomingSprite.alpha = 0
        artworkNode.addChild(incomingSprite)

        // Immediate: old text fades out; outgoing fades out; incoming fades in + scales up.
        for node in textNodes {
            node.run(.fadeOut(withDuration: textOutDuration))
        }
        bgSprite.run(.fadeOut(withDuration: dissolveDuration))
        incomingSprite.run(.group([
            .fadeIn(withDuration: dissolveDuration),
            .scale(to: targetScale, duration: dissolveDuration)
        ]))

        // At textInDelay: update text content for next beat, begin fade-in.
        run(.sequence([
            .wait(forDuration: textInDelay),
            .run { [weak self] in
                guard let self = self else { return }
                self.currentBeatIndex = nextIndex
                self.updateTextForCurrentBeat(in: container)
                for node in textNodes {
                    node.run(.fadeIn(withDuration: textInDuration))
                }
            }
        ]))

        // At dissolveDuration: promote incoming sprite, clean up, unlock.
        run(.sequence([
            .wait(forDuration: dissolveDuration),
            .run { [weak self] in
                guard let self = self else { return }
                bgSprite.removeFromParent()
                incomingSprite.name = "background-sprite"
                // Composed beats always keep the standalone Mori sprite hidden.
                if let mori = container.childNode(withName: "artwork-layer/mori-sprite")
                    as? SKSpriteNode {
                    mori.isHidden = true
                    mori.isPaused = true
                }
                self.isTransitioningBeat = false
            }
        ]))
    }

    // MARK: - Simple Transition (fallback / mixed beats)

    private func performSimpleTransition(nextIndex: Int, container: SKNode) {
        let artworkNode = container.childNode(withName: "artwork-layer")
        let textNodes: [SKNode] = [
            container.childNode(withName: "ui-layer/narration-label"),
            container.childNode(withName: "ui-layer/narration-shadow"),
            container.childNode(withName: "ui-layer/thought-label"),
            container.childNode(withName: "ui-layer/thought-shadow")
        ].compactMap { $0 }

        let fadeOutDuration: TimeInterval = 0.10
        let fadeInDuration:  TimeInterval = 0.20

        artworkNode?.run(.fadeOut(withDuration: fadeOutDuration))
        for node in textNodes {
            node.run(.fadeOut(withDuration: fadeOutDuration))
        }

        run(.sequence([
            .wait(forDuration: fadeOutDuration),
            .run { [weak self] in
                guard let self = self else { return }
                self.currentBeatIndex = nextIndex
                self.renderCurrentBeat()
                artworkNode?.run(.fadeIn(withDuration: fadeInDuration))
                for node in textNodes {
                    node.run(.fadeIn(withDuration: fadeInDuration))
                }
            },
            .wait(forDuration: fadeInDuration),
            .run { [weak self] in self?.isTransitioningBeat = false }
        ]))
    }

    // MARK: - Text-only update (used by the cross-dissolve path)

    // Updates text labels for currentBeatIndex without touching artwork.
    private func updateTextForCurrentBeat(in container: SKNode) {
        guard let config = config else { return }
        let beat = config.beats[currentBeatIndex]

        let narrationLabel  = container.childNode(withName: "ui-layer/narration-label")  as? SKLabelNode
        let narrationShadow = container.childNode(withName: "ui-layer/narration-shadow") as? SKLabelNode
        let thoughtLabel    = container.childNode(withName: "ui-layer/thought-label")    as? SKLabelNode
        let thoughtShadow   = container.childNode(withName: "ui-layer/thought-shadow")   as? SKLabelNode

        narrationLabel?.text  = beat.narration
        narrationShadow?.text = beat.narration
        thoughtLabel?.text    = beat.thought
        thoughtShadow?.text   = beat.thought

        if let customPos = beat.customThoughtPosition {
            let newPos = CGPoint(
                x: sceneSize.width  * customPos.x,
                y: sceneSize.height * customPos.y
            )
            thoughtLabel?.position  = newPos
            thoughtShadow?.position = CGPoint(x: newPos.x, y: newPos.y - 2)
        } else {
            let textY = sceneSize.height * 0.55
            thoughtLabel?.position  = CGPoint(x: sceneSize.width / 2, y: textY - 80)
            thoughtShadow?.position = CGPoint(x: sceneSize.width / 2, y: textY - 82)
        }
    }

    private func renderCurrentBeat() {
        guard let config = config,
              let container = narrationContainer else { return }
        let beat = config.beats[currentBeatIndex]
        
        let bgSprite = container.childNode(withName: "artwork-layer/background-sprite") as? SKSpriteNode
        let moriSprite = container.childNode(withName: "artwork-layer/mori-sprite") as? SKSpriteNode
        
        if let assetName = beat.assetName {
            bgSprite?.texture = SKTexture(imageNamed: assetName)
            moriSprite?.isHidden = true
            moriSprite?.isPaused = true
        } else {
            bgSprite?.texture = SKTexture(imageNamed: config.backgroundName)
            moriSprite?.isHidden = false
            moriSprite?.isPaused = false
        }
        
        let narrationLabel = container.childNode(withName: "ui-layer/narration-label") as? SKLabelNode
        let narrationShadow = container.childNode(withName: "ui-layer/narration-shadow") as? SKLabelNode
        let thoughtLabel = container.childNode(withName: "ui-layer/thought-label") as? SKLabelNode
        let thoughtShadow = container.childNode(withName: "ui-layer/thought-shadow") as? SKLabelNode
        
        narrationLabel?.text = beat.narration
        narrationShadow?.text = beat.narration
        
        thoughtLabel?.text = beat.thought
        thoughtShadow?.text = beat.thought
        
        if let customPos = beat.customThoughtPosition {
            let newPos = CGPoint(x: sceneSize.width * customPos.x, y: sceneSize.height * customPos.y)
            thoughtLabel?.position = newPos
            thoughtShadow?.position = CGPoint(x: newPos.x, y: newPos.y - 2)
        } else {
            let textY = sceneSize.height * 0.55
            thoughtLabel?.position = CGPoint(x: sceneSize.width / 2, y: textY - 80)
            thoughtShadow?.position = CGPoint(x: sceneSize.width / 2, y: textY - 82)
        }
    }
    
    private func transitionToBlooming() {
        phase = .blooming
        let whiteFade = SKShapeNode(rectOf: sceneSize)
        whiteFade.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)
        whiteFade.fillColor = .white
        whiteFade.strokeColor = .clear
        whiteFade.zPosition = 100
        whiteFade.alpha = 0
        addChild(whiteFade)
        
        whiteFade.run(.sequence([
            .fadeIn(withDuration: 1.5),
            .run { [weak self] in
                self?.narrationContainer?.removeFromParent()
                self?.narrationContainer = nil
                self?.setupCompletionPhase()
            },
            .fadeOut(withDuration: 0.5),
            .run { [weak self] in
                self?.phase = .completion
            },
            .removeFromParent()
        ]))
    }

    // MARK: - Completion Phase
    
    private func setupCompletionPhase() {
        setupBackground()
        setupHeader()
        setupReveal()
    }

    private func setupBackground() {
        let background = SKShapeNode(rectOf: sceneSize)
        background.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)
        background.fillColor = SKColor(red: 0.98, green: 0.95, blue: 0.89, alpha: 1)
        background.strokeColor = .clear
        background.zPosition = -1
        addChild(background)
    }

    private func setupHeader() {
        let label = SKLabelNode(fontNamed: "Montserrat-SemiBold")
        label.text = "A QUIET MOMENT"
        label.fontSize = 15
        label.fontColor = SKColor(red: 0.25, green: 0.20, blue: 0.31, alpha: 1)
        label.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.91)
        addChild(label)

        let title = SKLabelNode(fontNamed: "Montserrat-Medium")
        title.text = FlowerCelebrationInfo.info(for: goal.id).endingNarrative
        title.numberOfLines = 2
        title.preferredMaxLayoutWidth = sceneSize.width * 0.82
        title.fontSize = 15
        title.fontColor = SKColor(red: 0.25, green: 0.20, blue: 0.31, alpha: 1)
        title.horizontalAlignmentMode = .center
        title.verticalAlignmentMode = .center
        title.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.84)
        addChild(title)

        let response = SKLabelNode(fontNamed: "Montserrat-MediumItalic")
        response.text = "Mori: \(FlowerCelebrationInfo.info(for: goal.id).moriResponse)"
        response.fontSize = 15
        response.fontColor = SKColor(red: 0.35, green: 0.29, blue: 0.42, alpha: 1)
        response.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.75)
        addChild(response)

        if let followUp = FlowerCelebrationInfo.info(for: goal.id).endingFollowUp {
            let followUpLabel = SKLabelNode(fontNamed: "Montserrat-Medium")
            followUpLabel.text = followUp
            followUpLabel.fontSize = 13
            followUpLabel.fontColor = SKColor(red: 0.35, green: 0.29, blue: 0.42, alpha: 0.86)
            followUpLabel.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.70)
            addChild(followUpLabel)
        }
    }

    // MARK: - Flower Reveal

    private func setupReveal() {
        let center = CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.54)
        let reduceMotion = UIAccessibility.isReduceMotionEnabled

        let petals = SKNode()
        petals.position = center
        addChild(petals)

        let petalCount = max(goal.totalPetals, 1)
        for index in 0..<petalCount {
            let petal = SKSpriteNode(imageNamed: goal.petalAssetName)
            petal.size = CGSize(width: 34, height: 28)
            petal.position = CGPoint(x: CGFloat(index - (petalCount - 1) / 2) * 38, y: 0)
            petals.addChild(petal)
        }

        let flower = SKSpriteNode(imageNamed: chapter.flowerAssetName)
        flower.position = center
        flower.size = CGSize(width: min(sceneSize.width * 0.58, 220), height: min(sceneSize.width * 0.44, 168))
        flower.alpha = 0
        flower.zPosition = 2
        addChild(flower)

        let flowerName = SKLabelNode(fontNamed: "Montserrat-SemiBold")
        flowerName.text = chapter.flowerDisplayName
        flowerName.fontSize = 28
        flowerName.fontColor = SKColor(red: 0.25, green: 0.20, blue: 0.31, alpha: 1)
        flowerName.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.34)
        flowerName.alpha = 0
        addChild(flowerName)

        let message = SKLabelNode(fontNamed: "Montserrat-Regular")
        message.text = completionMessage
        message.fontSize = 14
        message.fontColor = SKColor(red: 0.35, green: 0.29, blue: 0.42, alpha: 1)
        message.numberOfLines = 3
        message.preferredMaxLayoutWidth = sceneSize.width * 0.78
        message.horizontalAlignmentMode = .center
        message.verticalAlignmentMode = .top
        message.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.28)
        message.alpha = 0
        addChild(message)

        let continueButton = makeContinueButton()
        continueButton.alpha = 0
        addChild(continueButton)

        let petalsOut = SKAction.group([
            .fadeOut(withDuration: reduceMotion ? 0.2 : 0.35),
            reduceMotion ? .wait(forDuration: 0.2) : .scale(to: 0.72, duration: 0.35)
        ])
        let flowerIn = reduceMotion
            ? SKAction.fadeIn(withDuration: 0.25)
            : SKAction.group([.fadeIn(withDuration: 0.25), .scale(to: 1.04, duration: 0.25)])
        if !reduceMotion { flower.setScale(0.82) }

        run(.sequence([
            .wait(forDuration: reduceMotion ? 0.2 : 0.55),
            .run { petals.run(petalsOut) },
            .wait(forDuration: reduceMotion ? 0.2 : 0.35),
            .run {
                flower.run(flowerIn)
                self.animateRevealedFlower(flower, reduceMotion: reduceMotion)
            },
            .wait(forDuration: 0.18),
            .run {
                flowerName.run(.fadeIn(withDuration: 0.2))
                message.run(.fadeIn(withDuration: 0.2))
                continueButton.run(.fadeIn(withDuration: 0.2)) { [weak self] in
                    self?.canContinue = true
                }
            }
        ]))
    }

    private func animateRevealedFlower(_ flower: SKSpriteNode, reduceMotion: Bool) {
        guard !reduceMotion else { return }

        flower.run(.repeatForever(.sequence([
            .group([
                .scale(to: 1.04, duration: 0.7),
                .rotate(byAngle: 0.025, duration: 0.7)
            ]),
            .group([
                .scale(to: 0.98, duration: 0.7),
                .rotate(byAngle: -0.05, duration: 0.7)
            ]),
            .rotate(byAngle: 0.025, duration: 0.7)
        ])), withKey: "flowerPulse")

        for index in 0..<5 {
            let sparkle = SKLabelNode(fontNamed: "Montserrat-Bold")
            sparkle.text = index.isMultiple(of: 2) ? "✦" : "✧"
            sparkle.fontSize = 12
            sparkle.fontColor = SKColor(red: 0.74, green: 0.55, blue: 0.23, alpha: 0.9)
            let angle = CGFloat(index) / 5 * .pi * 2
            sparkle.position = CGPoint(
                x: sceneSize.width / 2 + cos(angle) * 88,
                y: sceneSize.height * 0.54 + sin(angle) * 54
            )
            sparkle.alpha = 0.2
            addChild(sparkle)
            sparkle.run(.repeatForever(.sequence([
                .wait(forDuration: 0.12 * Double(index)),
                .fadeAlpha(to: 1.0, duration: 0.3),
                .fadeAlpha(to: 0.2, duration: 0.55)
            ])))
        }
    }

    // MARK: - Completion Actions

    private func makeContinueButton() -> SKNode {
        let container = SKNode()
        container.name = "chapter-completion-continue"
        container.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.13)

        let button = SKShapeNode(
            rectOf: CGSize(width: min(sceneSize.width * 0.62, 250), height: 52),
            cornerRadius: 18
        )
        button.name = "chapter-completion-continue"
        button.fillColor = SKColor(red: 0.66, green: 0.31, blue: 0.23, alpha: 1)
        button.strokeColor = .clear
        container.addChild(button)

        let label = SKLabelNode(fontNamed: "Montserrat-SemiBold")
        label.name = "chapter-completion-continue"
        label.text = isFinalChapter ? "To Be Continued" : "Continue"
        label.fontSize = 16
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        container.addChild(label)

        return container
    }

    private func containsNode(named targetName: String, at location: CGPoint) -> Bool {
        var node: SKNode? = atPoint(location)
        while let current = node {
            if current.name == targetName { return true }
            node = current.parent
        }
        return false
    }
}

