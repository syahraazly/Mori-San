import SpriteKit

final class MapView: SKNode {
    private let sceneSize: CGSize
    private let viewModel: MapViewModel
    private let onSelectChapter: (GoalID) -> Void
    private let pagesNode = SKNode()
    private let pageWidth: CGFloat

    private var currentPageIndex = 0
    private var touchStart: CGPoint?
    private var pagesStartX: CGFloat = 0

    init(
        sceneSize: CGSize,
        viewModel: MapViewModel,
        onSelectChapter: @escaping (GoalID) -> Void
    ) {
        self.sceneSize = sceneSize
        self.viewModel = viewModel
        self.onSelectChapter = onSelectChapter
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
        let background = SKSpriteNode(imageNamed: "mapBackground")
        background.size = CGSize(width: sceneSize.width, height: sceneSize.height)
        background.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)
        background.zPosition = -2
        addChild(background)

        let overlay = SKShapeNode(rectOf: sceneSize)
        overlay.fillColor = SKColor(red: 0.10, green: 0.12, blue: 0.18, alpha: 0.20)
        overlay.strokeColor = .clear
        overlay.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)
        overlay.zPosition = -1
        addChild(overlay)

        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = "JOURNEY"
        title.fontSize = 24
        title.fontColor = .white
        title.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.90)
        addChild(title)

        addChild(pagesNode)
        buildSwipeHint()
    }

    private func buildSwipeHint() {
        guard viewModel.chapters.count > 1 else { return }

        let hint = SKNode()
        hint.name = "map-swipe-hint"
        hint.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.075)
        hint.zPosition = 10

        let leftChevron = SKLabelNode(fontNamed: "AvenirNext-Medium")
        leftChevron.text = "‹"
        leftChevron.fontSize = 28
        leftChevron.fontColor = .white.withAlphaComponent(0.82)
        leftChevron.verticalAlignmentMode = .center
        leftChevron.position = CGPoint(x: -88, y: 1)
        hint.addChild(leftChevron)

        let label = SKLabelNode(fontNamed: "AvenirNext-Medium")
        label.text = "SWIPE TO EXPLORE"
        label.fontSize = 13
        label.fontColor = .white.withAlphaComponent(0.82)
        label.verticalAlignmentMode = .center
        hint.addChild(label)

        let rightChevron = SKLabelNode(fontNamed: "AvenirNext-Medium")
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
            pagesNode.addChild(page)
        }
    }

    private func makePage(for chapter: MapChapterConfiguration) -> SKNode {
        let page = SKNode()
        let state = viewModel.state(for: chapter)

        let card = SKShapeNode(
            rectOf: CGSize(width: pageWidth * 0.82, height: sceneSize.height * 0.53),
            cornerRadius: 26
        )
        card.fillColor = SKColor(red: 0.13, green: 0.16, blue: 0.23, alpha: 0.74)
        card.strokeColor = .white.withAlphaComponent(0.30)
        card.lineWidth = 1
        page.addChild(card)

        let chapterNumber = SKLabelNode(fontNamed: "AvenirNext-Bold")
        chapterNumber.text = "CHAPTER \(romanNumeral(chapter.order))"
        chapterNumber.fontSize = 25
        chapterNumber.fontColor = .white
        chapterNumber.position = CGPoint(x: 0, y: sceneSize.height * 0.19)
        page.addChild(chapterNumber)

        if chapter.isComingSoon {
            addClue(chapter.clue, to: page, y: 20)
            addStateLabel(
                chapter.progressionTitle,
                to: page,
                y: -sceneSize.height * 0.16,
                color: .white.withAlphaComponent(0.82)
            )
            return page
        }

        switch state {
        case .locked:
            addClue(chapter.clue, to: page, y: 20)
            addStateLabel("Locked", to: page, y: -sceneSize.height * 0.16, color: .white.withAlphaComponent(0.72))
            addStateLabel("Complete the previous chapter", to: page, y: -sceneSize.height * 0.22, color: .white.withAlphaComponent(0.54), size: 14)

        case .unlocked:
            addClue(chapter.clue, to: page, y: 20)
            addActionButton("Enter Chapter", chapterID: chapter.id, to: page)

        case .completed:
            let flower = SKSpriteNode(imageNamed: chapter.flowerAssetName)
            flower.size = CGSize(width: 128, height: 128)
            flower.position = CGPoint(x: 0, y: 26)
            page.addChild(flower)

            let flowerName = SKLabelNode(fontNamed: "AvenirNext-Bold")
            flowerName.text = chapter.flowerDisplayName
            flowerName.fontSize = 23
            flowerName.fontColor = .white
            flowerName.position = CGPoint(x: 0, y: -72)
            page.addChild(flowerName)

            addStateLabel("Chapter complete", to: page, y: -sceneSize.height * 0.19, color: .white.withAlphaComponent(0.76))
            addActionButton("Revisit Chapter", chapterID: chapter.id, to: page, y: -sceneSize.height * 0.26)
        }

        return page
    }

    private func addClue(_ clue: String, to page: SKNode, y: CGFloat) {
        let lines = clue.components(separatedBy: "\n")
        let lineSpacing: CGFloat = 25
        let startY = y + CGFloat(lines.count - 1) * lineSpacing / 2

        for (index, line) in lines.enumerated() {
            let label = SKLabelNode(fontNamed: "AvenirNext-Medium")
            label.text = line
            label.fontSize = 18
            label.fontColor = .white.withAlphaComponent(0.92)
            label.position = CGPoint(x: 0, y: startY - CGFloat(index) * lineSpacing)
            page.addChild(label)
        }
    }

    private func addStateLabel(
        _ text: String,
        to page: SKNode,
        y: CGFloat,
        color: SKColor,
        size: CGFloat = 18
    ) {
        let label = SKLabelNode(fontNamed: "AvenirNext-Medium")
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
        y: CGFloat? = nil
    ) {
        let button = SKShapeNode(rectOf: CGSize(width: 172, height: 48), cornerRadius: 20)
        button.name = "map-chapter-\(chapterID)"
        button.fillColor = SKColor(red: 0.83, green: 0.54, blue: 0.38, alpha: 1.0)
        button.strokeColor = .white.withAlphaComponent(0.35)
        button.lineWidth = 1
        button.position = CGPoint(x: 0, y: y ?? -sceneSize.height * 0.19)
        page.addChild(button)

        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = text
        label.fontSize = 16
        label.verticalAlignmentMode = .center
        label.fontColor = .white
        button.addChild(label)
    }

    private func selectChapter(at location: CGPoint) {
        var node: SKNode? = atPoint(location)

        while let currentNode = node {
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
