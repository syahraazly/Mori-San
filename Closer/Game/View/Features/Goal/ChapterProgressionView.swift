import SwiftUI

// MARK: - Chapter Progression

struct ChapterProgressionView: View {
    @ObservedObject var appFlow: AppFlowViewModel
    let goalID: GoalID

    private var goal: FlowerGoal? {
        FlowerGoalData.goal(for: goalID)
    }

    private var chapter: MapChapterConfiguration? {
        MapChapterData.chapter(for: goalID)
    }

    var body: some View {
        Group {
            if let goal, let chapter {
                ZStack {
                    Image(chapter.backgroundAssetName)
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()

                    Color.black.opacity(0.08)
                        .ignoresSafeArea()

                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            Button(action: appFlow.openMap) {
                                Label("Map", systemImage: "chevron.left")
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(.white)
                                    .frame(width: 90, height: 40)
                                    .background(
                                        Color.moriPurple.opacity(0.94),
                                        in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    )
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(Color.white.opacity(0.35), lineWidth: 2)
                                    }
                            }
                            .accessibilityLabel("Kembali ke Map")

                            ChapterHeaderView(chapter: chapter)
                                .padding(20)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            PetalProgressView(
                                collected: appFlow.progress.petalCount(for: goal),
                                total: goal.totalPetals,
                                petalAssetName: goal.petalAssetName
                            )
                            .padding(20)
                            .frame(maxWidth: .infinity, alignment: .leading)

                            LevelPathView(
                                levelIDs: goal.levelIDs,
                                isCompleted: appFlow.isLevelCompleted,
                                isUnlocked: appFlow.isLevelUnlocked,
                                onSelectLevel: appFlow.startLevel
                            )
                            .padding(.horizontal, 8)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 54)
                        .padding(.bottom, 18)
                        .frame(maxWidth: 620)
                        .frame(maxWidth: .infinity)
                    }
                }
            } else {
                ContentUnavailableView("Chapter tidak ditemukan", systemImage: "map")
            }
        }
    }
}

private struct ChapterHeaderView: View {
    let chapter: MapChapterConfiguration

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("CHAPTER \(romanNumeral(chapter.order))")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.white.opacity(0.72))
                .tracking(1.2)

            Text(chapter.progressionTitle)
                .font(.system(.title, design: .serif).weight(.semibold))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func romanNumeral(_ value: Int) -> String {
        ["I", "II", "III", "IV"][max(0, min(value - 1, 3))]
    }
}

// MARK: - Petal Progress

private struct PetalProgressView: View {
    let collected: Int
    let total: Int
    let petalAssetName: String

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Text("\(collected)/\(total) petals")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)

            HStack(spacing: 10) {
                ForEach(0..<total, id: \.self) { index in
                    PetalMark(
                        assetName: petalAssetName,
                        isCollected: index < collected
                    )
                        .accessibilityHidden(true)
                }
            }
            .frame(maxWidth: .infinity)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(collected) dari \(total) kelopak terkumpul")
        }
    }
}

private struct PetalMark: View {
    let assetName: String
    let isCollected: Bool

    var body: some View {
        Image(assetName)
            .resizable()
            .scaledToFit()
            .frame(width: 28, height: 28)
            .saturation(isCollected ? 1 : 0)
            .opacity(isCollected ? 1 : 0.28)
            .padding(5)
            .background(Color.white.opacity(isCollected ? 0.14 : 0.06), in: Circle())
    }
}

// MARK: - Level Journey

private struct LevelPathView: View {
    let levelIDs: [LevelID]
    let isCompleted: (LevelID) -> Bool
    let isUnlocked: (LevelID) -> Bool
    let onSelectLevel: (LevelID) -> Void

    var body: some View {
        GeometryReader { geometry in
            let points = journeyPoints(count: levelIDs.count, in: geometry.size)

            ZStack(alignment: .topLeading) {
                JourneyLine(points: points)
                    .stroke(Color.moriPath, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))

                ForEach(Array(levelIDs.enumerated()), id: \.element) { index, levelID in
                    LevelNodeView(
                        levelID: levelID,
                        state: state(for: levelID),
                        action: { onSelectLevel(levelID) }
                    )
                    .position(points[index])
                }
            }
        }
        .frame(height: journeyHeight(for: levelIDs.count))
        .accessibilityElement(children: .contain)
    }

    private func state(for levelID: LevelID) -> LevelNodeState {
        if isCompleted(levelID) { return .completed }
        return isUnlocked(levelID) ? .current : .locked
    }

    private func journeyPoints(count: Int, in size: CGSize) -> [CGPoint] {
        let layout: [(CGFloat, CGFloat)] = [
            (0.14, 0.16), (0.50, 0.16), (0.86, 0.16),
            (0.67, 0.50), (0.28, 0.50), (0.50, 0.78)
        ]
        return layout.prefix(count).map { point in
            CGPoint(x: size.width * point.0, y: size.height * point.1)
        }
    }

    private func journeyHeight(for count: Int) -> CGFloat {
        count > 4 ? 290 : 225
    }
}

private struct JourneyLine: Shape {
    let points: [CGPoint]

    func path(in rect: CGRect) -> Path {
        guard let first = points.first else { return Path() }
        var path = Path()
        path.move(to: first)
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        return path
    }
}

private struct LevelNodeView: View {
    let levelID: LevelID
    let state: LevelNodeState
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(state.fillColor)
                    .frame(width: 52, height: 52)
                    .overlay {
                        Circle().stroke(Color.white.opacity(0.8), lineWidth: state == .current ? 2 : 1)
                    }

                if state == .completed {
                    Image(systemName: "checkmark")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                } else {
                    Text(displayLevelID)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(state == .locked ? Color.moriMutedInk : .white)
                }
            }
            .frame(width: 60, height: 60)
        }
        .buttonStyle(.plain)
        .disabled(state == .locked)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(state == .locked ? "Level masih terkunci" : "Buka level")
    }

    private var accessibilityLabel: String {
        switch state {
        case .completed: return "Level \(displayLevelID), selesai"
        case .current: return "Level \(displayLevelID), tersedia"
        case .locked: return "Level \(displayLevelID), terkunci"
        }
    }

    private var displayLevelID: String {
        guard levelID.hasPrefix("balinese-"),
              let levelNumber = Int(levelID.dropFirst("balinese-".count)) else {
            return levelID
        }
        return "3.\(levelNumber)"
    }
}

private enum LevelNodeState {
    case completed
    case current
    case locked

    var fillColor: Color {
        switch self {
        case .completed: return .moriCompleted
        case .current: return .moriTerracotta
        case .locked: return .moriLocked
        }
    }
}

struct ChapterProgressionView_Previews: PreviewProvider {
    static var previews: some View {
        ChapterProgressionView(
            appFlow: AppFlowViewModel(),
            goalID: "forget-me-not"
        )
    }
}

private extension Color {
    static let moriCream = Color(red: 0.95, green: 0.90, blue: 0.82)
    static let moriInk = Color(red: 0.22, green: 0.24, blue: 0.30)
    static let moriPurple = Color(red: 0.38, green: 0.31, blue: 0.52)
    static let moriMutedInk = Color(red: 0.38, green: 0.31, blue: 0.52)
    static let moriTerracotta = Color(red: 0.66, green: 0.31, blue: 0.23)
    static let moriCompleted = Color(red: 0.37, green: 0.35, blue: 0.43)
    static let moriLocked = Color(red: 0.73, green: 0.70, blue: 0.68)
    static let moriPath = Color(red: 0.63, green: 0.57, blue: 0.54)
}
