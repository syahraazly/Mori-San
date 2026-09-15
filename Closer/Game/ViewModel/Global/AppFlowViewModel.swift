import SwiftUI

final class AppFlowViewModel: ObservableObject {
    enum Screen {
        case opening
        case chapterOne
        case game
    }

    @Published private(set) var screen: Screen = .opening

    func beginChapterOne() {
        screen = .chapterOne
    }

    func startGame() {
        screen = .game
    }
}
