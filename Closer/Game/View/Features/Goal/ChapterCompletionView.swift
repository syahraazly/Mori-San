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
            guard let config = config else { return false }
            if currentBeatIndex < config.beats.count - 1 {
                currentBeatIndex += 1
                renderCurrentBeat()
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
        
        if let bgName = config?.backgroundName {
            let bg = SKSpriteNode(imageNamed: bgName)
            bg.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)
            let scale = max(sceneSize.width / bg.size.width, sceneSize.height / bg.size.height)
            bg.setScale(scale)
            bg.zPosition = -1
            container.addChild(bg)
        }
        
        let texture1 = SKTexture(imageNamed: "mori-idle-1")
        let texture2 = SKTexture(imageNamed: "mori-idle-2")
        
        let targetHeight: CGFloat = 150
        let aspectRatio = texture1.size().width / max(texture1.size().height, 1)
        let targetSize = CGSize(width: targetHeight * aspectRatio, height: targetHeight)
        
        let mori = SKSpriteNode(texture: texture1, size: targetSize)
        // Position center so the bottom of the sprite is 40 points above the bottom edge
        mori.position = CGPoint(x: sceneSize.width / 2, y: (targetSize.height / 2) + 40)
        container.addChild(mori)
        
        let idleAction = SKAction.repeatForever(SKAction.animate(with: [
            texture1, texture2
        ], timePerFrame: 0.55, resize: false, restore: false))
        mori.run(idleAction)
        
        let textY = sceneSize.height * 0.55
        
        let narrationLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        narrationLabel.name = "narration-label"
        narrationLabel.fontSize = 19
        narrationLabel.fontColor = .white
        narrationLabel.numberOfLines = 0
        narrationLabel.preferredMaxLayoutWidth = sceneSize.width * 0.8
        narrationLabel.horizontalAlignmentMode = .center
        narrationLabel.position = CGPoint(x: sceneSize.width / 2, y: textY)
        
        let shadow1 = SKLabelNode(fontNamed: "AvenirNext-Medium")
        shadow1.name = "narration-shadow"
        shadow1.fontSize = 19
        shadow1.fontColor = SKColor.black.withAlphaComponent(0.6)
        shadow1.numberOfLines = 0
        shadow1.preferredMaxLayoutWidth = sceneSize.width * 0.8
        shadow1.horizontalAlignmentMode = .center
        shadow1.position = CGPoint(x: sceneSize.width / 2, y: textY - 2)
        shadow1.zPosition = -0.1
        
        let thoughtLabel = SKLabelNode(fontNamed: "AvenirNext-Italic")
        thoughtLabel.name = "thought-label"
        thoughtLabel.fontSize = 19
        thoughtLabel.fontColor = .white
        thoughtLabel.numberOfLines = 0
        thoughtLabel.preferredMaxLayoutWidth = sceneSize.width * 0.8
        thoughtLabel.horizontalAlignmentMode = .center
        thoughtLabel.position = CGPoint(x: sceneSize.width / 2, y: textY - 80)
        
        let shadow2 = SKLabelNode(fontNamed: "AvenirNext-Italic")
        shadow2.name = "thought-shadow"
        shadow2.fontSize = 19
        shadow2.fontColor = SKColor.black.withAlphaComponent(0.6)
        shadow2.numberOfLines = 0
        shadow2.preferredMaxLayoutWidth = sceneSize.width * 0.8
        shadow2.horizontalAlignmentMode = .center
        shadow2.position = CGPoint(x: sceneSize.width / 2, y: textY - 82)
        shadow2.zPosition = -0.1
        
        container.addChild(shadow1)
        container.addChild(narrationLabel)
        container.addChild(shadow2)
        container.addChild(thoughtLabel)
        
        renderCurrentBeat()
    }
    
    private func renderCurrentBeat() {
        guard let config = config,
              let container = narrationContainer else { return }
        let beat = config.beats[currentBeatIndex]
        
        let narrationLabel = container.childNode(withName: "narration-label") as? SKLabelNode
        let narrationShadow = container.childNode(withName: "narration-shadow") as? SKLabelNode
        let thoughtLabel = container.childNode(withName: "thought-label") as? SKLabelNode
        let thoughtShadow = container.childNode(withName: "thought-shadow") as? SKLabelNode
        
        narrationLabel?.text = beat.narration
        narrationShadow?.text = beat.narration
        
        thoughtLabel?.text = beat.thought
        thoughtShadow?.text = beat.thought
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
        let label = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        label.text = "CHAPTER \(chapter.order) COMPLETE"
        label.fontSize = 15
        label.fontColor = SKColor(red: 0.25, green: 0.20, blue: 0.31, alpha: 1)
        label.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.84)
        addChild(label)

        let title = SKLabelNode(fontNamed: "AvenirNext-Medium")
        title.text = chapter.progressionTitle
        title.fontSize = 22
        title.fontColor = SKColor(red: 0.25, green: 0.20, blue: 0.31, alpha: 1)
        title.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.79)
        addChild(title)
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

        let flowerName = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        flowerName.text = chapter.flowerDisplayName
        flowerName.fontSize = 28
        flowerName.fontColor = SKColor(red: 0.25, green: 0.20, blue: 0.31, alpha: 1)
        flowerName.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.34)
        flowerName.alpha = 0
        addChild(flowerName)

        let message = SKLabelNode(fontNamed: "AvenirNext-Regular")
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
            .run { flower.run(flowerIn) },
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

        let label = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
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
