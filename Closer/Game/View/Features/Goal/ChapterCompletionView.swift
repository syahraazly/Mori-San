import SpriteKit
import UIKit

// MARK: - Chapter Completion

final class ChapterCompletionView: SKNode {
    private let sceneSize: CGSize
    private let chapter: MapChapterConfiguration
    private let goal: FlowerGoal
    private let completionMessage: String
    private let isFinalChapter: Bool
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
        super.init()

        name = "chapter-completion-screen"
        setupBackground()
        setupHeader()
        setupReveal()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func handleTap(at location: CGPoint) -> Bool {
        guard canContinue,
              containsNode(named: "chapter-completion-continue", at: location) else {
            return false
        }
        return true
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
        label.text = "A QUIET MOMENT"
        label.fontSize = 15
        label.fontColor = SKColor(red: 0.25, green: 0.20, blue: 0.31, alpha: 1)
        label.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.91)
        addChild(label)

        let title = SKLabelNode(fontNamed: "AvenirNext-Medium")
        title.text = FlowerCelebrationInfo.info(for: goal.id).endingNarrative
        title.numberOfLines = 2
        title.preferredMaxLayoutWidth = sceneSize.width * 0.82
        title.fontSize = 15
        title.fontColor = SKColor(red: 0.25, green: 0.20, blue: 0.31, alpha: 1)
        title.horizontalAlignmentMode = .center
        title.verticalAlignmentMode = .center
        title.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.84)
        addChild(title)

        let response = SKLabelNode(fontNamed: "AvenirNext-MediumItalic")
        response.text = "Mori: \(FlowerCelebrationInfo.info(for: goal.id).moriResponse)"
        response.fontSize = 15
        response.fontColor = SKColor(red: 0.35, green: 0.29, blue: 0.42, alpha: 1)
        response.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.75)
        addChild(response)

        if let followUp = FlowerCelebrationInfo.info(for: goal.id).endingFollowUp {
            let followUpLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
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
            let sparkle = SKLabelNode(fontNamed: "AvenirNext-Bold")
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
