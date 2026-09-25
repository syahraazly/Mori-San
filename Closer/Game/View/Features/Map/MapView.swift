import SpriteKit

final class MapView: SKNode {
    private let sceneSize: CGSize
    private let viewModel: MapViewModel
    private let onSelectChapter: (GoalID) -> Void
    private let onOpenTutorial: () -> Void
    private let pagesNode = SKNode()
    private let pageWidth: CGFloat

    private var currentPageIndex = 0
    private var touchStart: CGPoint?
    private var pagesStartX: CGFloat = 0

    init(
        sceneSize: CGSize,
        viewModel: MapViewModel,
        onSelectChapter: @escaping (GoalID) -> Void,
        onOpenTutorial: @escaping () -> Void
    ) {
        self.sceneSize = sceneSize
        self.viewModel = viewModel
        self.onSelectChapter = onSelectChapter
        self.onOpenTutorial = onOpenTutorial
        pageWidth = sceneSize.width * 0.90
        super.init()

        buildBackground()
        buildPages()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func handleTouchBegan(at location: CGPoint) {
        touchStart = location
        pagesStartX = pagesNode.position.x
        pagesNode.removeAction(forKey: "mapPage")
    }

    func handleTouchMoved(to location: CGPoint) {
        guard let touchStart else { return }

        let proposedX = pagesStartX + (location.x - touchStart.x)
        let finalPageOffset = pageWidth * CGFloat(max(viewModel.chapters.count - 1, 0))
        let minimumX = sceneSize.width / 2 - finalPageOffset
        pagesNode.position.x = min(max(proposedX, minimumX), sceneSize.width / 2)
    }

    func handleTouchEnded(at location: CGPoint) {
        guard let touchStart else { return }
        defer { self.touchStart = nil }

        let horizontalMovement = location.x - touchStart.x
        if abs(horizontalMovement) < 12 {
            selectChapter(at: location)
            return
        }

        if horizontalMovement <= -35 {
            currentPageIndex = min(currentPageIndex + 1, viewModel.chapters.count - 1)
        } else if horizontalMovement >= 35 {
            currentPageIndex = max(currentPageIndex - 1, 0)
        }

        snapToCurrentPage()
    }

    private func buildBackground() {
        let background = SKSpriteNode(imageNamed: "background-map")
        let textureSize = background.texture?.size() ?? sceneSize
        let scale = max(sceneSize.width / textureSize.width, sceneSize.height / textureSize.height)
        background.size = CGSize(width: textureSize.width * scale, height: textureSize.height * scale)
        background.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)
        background.zPosition = -2
        addChild(background)

        let overlay = SKShapeNode(rectOf: sceneSize)
        overlay.fillColor = SKColor(red: 0.10, green: 0.12, blue: 0.18, alpha: 0.20)
        overlay.strokeColor = .clear
        overlay.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)
        overlay.zPosition = -1
        addChild(overlay)
        overlay.alpha = 0
        overlay.run(.fadeIn(withDuration: 0.35))

        let title = SKLabelNode(fontNamed: "Montserrat-Bold")
        title.text = "MORI JOURNEY"
        title.fontSize = 20
        title.fontColor = .white
        title.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.85)
        addChild(title)

        let mori = SKSpriteNode(imageNamed: "mori-idle-1")
        mori.name = "map-mori-observing"
        // The idle assets use a square canvas; keep a 1:1 sprite ratio so Mori
        // is not vertically stretched on the map.
        mori.size = CGSize(width: 74, height: 74)
        mori.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.135)
        mori.zPosition = 5
        addChild(mori)
        let idleFrames = [
            SKTexture(imageNamed: "mori-idle-1"),
            SKTexture(imageNamed: "mori-idle-2")
        ]
        mori.run(.repeatForever(.animate(with: idleFrames, timePerFrame: 0.55, resize: false, restore: true)))
        mori.run(.repeatForever(.sequence([
            .moveBy(x: 0, y: 2, duration: 1.1),
            .moveBy(x: 0, y: -2, duration: 1.1)
        ])))

        addChild(pagesNode)
        addTutorialButton()
        buildSwipeHint()
    }

    private func addTutorialButton() {
        let button = SKSpriteNode(imageNamed: "hint-tutorial")
        button.name = "map-tutorial"
        let textureSize = button.texture?.size() ?? CGSize(width: 1, height: 1)
        let iconHeight: CGFloat = 52
        button.size = CGSize(
            width: iconHeight * textureSize.width / max(textureSize.height, 1),
            height: iconHeight
        )
        button.position = CGPoint(x: sceneSize.width - 72, y: sceneSize.height * 0.86)
        button.zPosition = 10
        addChild(button)
    }

    private func buildSwipeHint() {
        guard viewModel.chapters.count > 1 else { return }

        let hint = SKNode()
        hint.name = "map-swipe-hint"
        hint.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.075)
        hint.zPosition = 10

        let leftChevron = SKLabelNode(fontNamed: "Montserrat-Medium")
        leftChevron.text = "‹"
        leftChevron.fontSize = 28
        leftChevron.fontColor = .white.withAlphaComponent(0.82)
        leftChevron.verticalAlignmentMode = .center
        leftChevron.position = CGPoint(x: -88, y: 1)
        hint.addChild(leftChevron)

        let label = SKLabelNode(fontNamed: "Montserrat-Medium")
        label.text = "SWIPE TO EXPLORE"
        label.fontSize = 13
        label.fontColor = .white.withAlphaComponent(0.82)
        label.verticalAlignmentMode = .center
        hint.addChild(label)

        let rightChevron = SKLabelNode(fontNamed: "Montserrat-Medium")
        rightChevron.text = "›"
        rightChevron.fontSize = 28
        rightChevron.fontColor = .white.withAlphaComponent(0.82)
        rightChevron.verticalAlignmentMode = .center
        rightChevron.position = CGPoint(x: 88, y: 1)
        hint.addChild(rightChevron)

        hint.run(
            SKAction.repeatForever(
                SKAction.sequence([
                    .fadeAlpha(to: 0.55, duration: 1.0),
                    .fadeAlpha(to: 0.82, duration: 1.0)
                ])
            )
        )
        addChild(hint)
    }

    private func buildPages() {
        pagesNode.position = CGPoint(x: sceneSize.width / 2, y: 0)

        for (index, chapter) in viewModel.chapters.enumerated() {
            let page = makePage(for: chapter)
            page.position = CGPoint(x: CGFloat(index) * pageWidth, y: sceneSize.height * 0.49)
            page.alpha = 0
            page.setScale(0.97)
            pagesNode.addChild(page)
            page.run(.sequence([
                .wait(forDuration: 0.06 * Double(index)),
                .group([
                    .fadeIn(withDuration: 0.28),
                    .scale(to: 1.0, duration: 0.28)
                ])
            ]))
        }
    }

    private func makePage(for chapter: MapChapterConfiguration) -> SKNode {
        let page = SKNode()
        let state = viewModel.state(for: chapter)
        let goal = FlowerGoalData.goal(for: chapter.id)
        let actionY = -sceneSize.height * 0.19

        let cardSize = CGSize(width: pageWidth * 0.82, height: sceneSize.height * 0.53)
        let card = SKShapeNode(
            rectOf: cardSize,
            cornerRadius: 26
        )
        card.fillColor = SKColor(red: 0.13, green: 0.16, blue: 0.23, alpha: 0.80)
        card.strokeColor = state == .locked ? .white.withAlphaComponent(0.16) : .white.withAlphaComponent(0.30)
        card.lineWidth = 1
        card.zPosition = -2
        page.addChild(card)

        if state == .locked {
            let lockBackground = SKSpriteNode(imageNamed: "lock")
            lockBackground.size = cardSize
            lockBackground.position = .zero
            lockBackground.alpha = 0.34

            let lockCrop = SKCropNode()
            let mask = SKShapeNode(rectOf: cardSize, cornerRadius: 26)
            mask.fillColor = .white
            mask.strokeColor = .clear
            lockCrop.maskNode = mask
            lockCrop.addChild(lockBackground)
            lockCrop.zPosition = -1
            page.addChild(lockCrop)
        }

        let chapterNumber = SKLabelNode(fontNamed: "Montserrat-Bold")
        chapterNumber.text = "CHAPTER \(romanNumeral(chapter.order))"
        chapterNumber.fontSize = 17
        chapterNumber.fontColor = .white
        chapterNumber.position = CGPoint(x: 0, y: sceneSize.height * 0.20)
        page.addChild(chapterNumber)

        let chapterTitle = SKLabelNode(fontNamed: "Montserrat-SemiBold")
        chapterTitle.text = chapter.progressionTitle
        chapterTitle.fontSize = 18
        chapterTitle.fontColor = .white.withAlphaComponent(0.95)
        chapterTitle.preferredMaxLayoutWidth = pageWidth * 0.72
        chapterTitle.numberOfLines = 2
        chapterTitle.lineBreakMode = .byWordWrapping
        chapterTitle.horizontalAlignmentMode = .center
        chapterTitle.verticalAlignmentMode = .top
        chapterTitle.position = CGPoint(x: 0, y: sceneSize.height * 0.18)
        page.addChild(chapterTitle)

        if chapter.isComingSoon {
            addClue(chapter.clue, to: page, y: 18)
            addStateLabel("Coming soon", to: page, y: -sceneSize.height * 0.16, color: .white.withAlphaComponent(0.68))
            return page
        }

        switch state {
        case .locked:
            addClue(chapter.clue, to: page, y: 20)
            addActionButton("Locked", chapterID: chapter.id, to: page, y: actionY, enabled: false)

        case .unlocked:
            addClue(chapter.unlockedPrompt, to: page, y: 30)
            if let goal {
                addStateLabel(
                    "\(viewModel.collectedPetals(for: chapter))/\(goal.totalPetals) petals",
                    to: page,
                    y: -sceneSize.height * 0.13,
                    color: .white.withAlphaComponent(0.82)
                )
            }
            addActionButton("Enter Chapter", chapterID: chapter.id, to: page, y: actionY)

        case .completed:
            let flower = SKSpriteNode(imageNamed: chapter.flowerAssetName)
            let flowerSize = min(pageWidth * 0.54, 168)
            let textureSize = flower.texture?.size() ?? CGSize(width: 1, height: 1)
            flower.size = CGSize(
                width: flowerSize,
                height: flowerSize * textureSize.height / max(textureSize.width, 1)
            )
            flower.position = CGPoint(x: 0, y: 48)
            flower.zPosition = 1
            addFlowerHighlight(behind: flower, radius: flowerSize * 0.60, to: page)
            page.addChild(flower)
            animateCompletedFlower(flower, in: page)

            let flowerName = SKLabelNode(fontNamed: "Montserrat-Bold")
            flowerName.text = chapter.flowerDisplayName
            flowerName.fontSize = 16
            flowerName.fontColor = .white
            flowerName.position = CGPoint(x: 0, y: -72)
            page.addChild(flowerName)

            if let goal {
                addStateLabel("\(goal.totalPetals)/\(goal.totalPetals) petals · Complete", to: page, y: -sceneSize.height * 0.19, color: .white.withAlphaComponent(0.76), size: 15)
            }
            addActionButton("Revisit Chapter", chapterID: chapter.id, to: page, y: actionY)
        }

        return page
    }

    private func addClue(_ clue: String, to page: SKNode, y: CGFloat) {
        let lines = centeredLines(for: clue, maximumCharacters: 28)
        let lineSpacing: CGFloat = 22
        let startY = y + CGFloat(lines.count - 1) * lineSpacing / 2

        for (index, line) in lines.enumerated() {
            let label = SKLabelNode(fontNamed: "Montserrat-Medium")
            label.text = line
            label.fontSize = 17
            label.fontColor = .white.withAlphaComponent(0.92)
            label.horizontalAlignmentMode = .center
            label.verticalAlignmentMode = .center
            label.position = CGPoint(x: 0, y: startY - CGFloat(index) * lineSpacing)
            page.addChild(label)
        }
    }

    private func centeredLines(for text: String, maximumCharacters: Int) -> [String] {
        text
            .components(separatedBy: "\n")
            .flatMap { paragraph in
                let words = paragraph.split(separator: " ").map(String.init)
                guard !words.isEmpty else { return [""] }

                var lines: [String] = []
                var current = ""
                for word in words {
                    let candidate = current.isEmpty ? word : "\(current) \(word)"
                    if candidate.count > maximumCharacters, !current.isEmpty {
                        lines.append(current)
                        current = word
                    } else {
                        current = candidate
                    }
                }
                if !current.isEmpty { lines.append(current) }
                return lines
            }
    }

    private func animateCompletedFlower(_ flower: SKSpriteNode, in page: SKNode) {
        let pulse = SKAction.repeatForever(.sequence([
            .group([
                .scale(to: 1.05, duration: 0.75),
                .rotate(byAngle: 0.025, duration: 0.75)
            ]),
            .group([
                .scale(to: 0.98, duration: 0.75),
                .rotate(byAngle: -0.05, duration: 0.75)
            ]),
            .rotate(byAngle: 0.025, duration: 0.75)
        ]))
        flower.run(pulse, withKey: "mapFlowerPulse")

        for index in 0..<4 {
            let sparkle = SKLabelNode(fontNamed: "Montserrat-Bold")
            sparkle.text = index.isMultiple(of: 2) ? "✦" : "✧"
            sparkle.fontSize = index.isMultiple(of: 2) ? 13 : 10
            sparkle.fontColor = SKColor(red: 1.0, green: 0.88, blue: 0.55, alpha: 0.9)
            let angle = (CGFloat(index) / 4.0) * .pi * 2
            sparkle.position = CGPoint(x: cos(angle) * 58, y: 38 + sin(angle) * 48)
            sparkle.alpha = 0.25
            page.addChild(sparkle)
            sparkle.run(.repeatForever(.sequence([
                .wait(forDuration: 0.16 * Double(index)),
                .group([
                    .fadeAlpha(to: 1.0, duration: 0.35),
                    .scale(to: 1.18, duration: 0.35)
                ]),
                .group([
                    .fadeAlpha(to: 0.25, duration: 0.55),
                    .scale(to: 0.82, duration: 0.55)
                ])
            ])))
        }
    }

    private func addFlowerHighlight(behind flower: SKSpriteNode, radius: CGFloat, to page: SKNode) {
        let glow = SKShapeNode(circleOfRadius: radius)
        glow.fillColor = SKColor(red: 1.0, green: 0.86, blue: 0.48, alpha: 0.16)
        glow.strokeColor = .clear
        glow.position = flower.position
        glow.zPosition = 0
        page.addChild(glow)
        glow.run(.repeatForever(.sequence([
            .group([
                .scale(to: 1.08, duration: 0.8),
                .fadeAlpha(to: 0.28, duration: 0.8)
            ]),
            .group([
                .scale(to: 0.96, duration: 0.8),
                .fadeAlpha(to: 0.12, duration: 0.8)
            ])
        ])))
    }

    private func addStateLabel(
        _ text: String,
        to page: SKNode,
        y: CGFloat,
        color: SKColor,
        size: CGFloat = 18
    ) {
        let label = SKLabelNode(fontNamed: "Montserrat-Medium")
        label.text = text
        label.fontSize = size
        label.fontColor = color
        label.position = CGPoint(x: 0, y: y)
        page.addChild(label)
    }

    private func addActionButton(
        _ text: String,
        chapterID: GoalID,
        to page: SKNode,
        y: CGFloat,
        enabled: Bool = true
    ) {
        let button = SKShapeNode(rectOf: CGSize(width: 156, height: 46), cornerRadius: 16)
        if enabled { button.name = "map-chapter-\(chapterID)" }
        button.fillColor = enabled
            ? SKColor(red: 0.38, green: 0.31, blue: 0.52, alpha: 0.94)
            : SKColor(red: 0.35, green: 0.35, blue: 0.40, alpha: 0.72)
        button.strokeColor = .white.withAlphaComponent(enabled ? 0.35 : 0.16)
        button.lineWidth = 2
        button.position = CGPoint(x: 0, y: y)
        page.addChild(button)

        let label = SKLabelNode(fontNamed: "Montserrat-Bold")
        label.text = text
        label.fontSize = 15
        label.verticalAlignmentMode = .center
        label.fontColor = .white
        button.addChild(label)
    }

    private func selectChapter(at location: CGPoint) {
        var node: SKNode? = atPoint(location)

        while let currentNode = node {
            if currentNode.name == "map-tutorial" {
                onOpenTutorial()
                return
            }
            if let name = currentNode.name, name.hasPrefix("map-chapter-") {
                let chapterID = String(name.dropFirst("map-chapter-".count))
                guard let chapter = viewModel.chapters.first(where: { $0.id == chapterID }),
                      viewModel.state(for: chapter) != .locked else {
                    return
                }
                onSelectChapter(chapterID)
                return
            }
            node = currentNode.parent
        }
    }

    private func snapToCurrentPage() {
        let destinationX = sceneSize.width / 2 - CGFloat(currentPageIndex) * pageWidth
        pagesNode.run(
            SKAction.moveTo(x: destinationX, duration: 0.22),
            withKey: "mapPage"
        )
    }

    private func romanNumeral(_ value: Int) -> String {
        switch value {
        case 1: return "I"
        case 2: return "II"
        case 3: return "III"
        case 4: return "IV"
        default: return "\(value)"
        }
    }
}
