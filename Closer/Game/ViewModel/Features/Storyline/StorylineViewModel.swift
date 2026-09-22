import Combine

final class StorylineViewModel: ObservableObject {

    // MARK: - State

    let beats: [StoryBeat]
    @Published private(set) var currentBeatIndex: Int = 0

    // MARK: - Completion

    /// Called when the final beat is acknowledged or the user skips.
    /// Injected by the caller so this ViewModel stays ignorant of navigation.
    var onComplete: () -> Void

    // MARK: - Init

    init(beats: [StoryBeat] = StorylineViewModel.defaultBeats,
         onComplete: @escaping () -> Void = {}) {
        precondition(!beats.isEmpty, "StorylineViewModel requires at least one beat.")
        self.beats = beats
        self.onComplete = onComplete
    }

    // MARK: - Derived State

    var currentBeat: StoryBeat { beats[currentBeatIndex] }
    var isLastBeat: Bool { currentBeatIndex == beats.count - 1 }

    // MARK: - Actions

    /// Advances to the next beat, or signals completion on the final beat.
    func advanceStory() {
        if isLastBeat {
            onComplete()
        } else {
            currentBeatIndex += 1
        }
    }

    /// Skips the entire sequence and signals completion immediately.
    func skipStory() {
        onComplete()
    }

    // MARK: - Default Content

    static let defaultBeats: [StoryBeat] = [
        StoryBeat(id: 1, imageName: "story-scene-01", thought: "Everything I need is right here."),
        StoryBeat(id: 2, imageName: "story-scene-02", thought: "A peaceful day, as always."),
        StoryBeat(id: 3, imageName: "story-scene-03", thought: "...That wasn't there before."),
        StoryBeat(id: 4, imageName: "story-scene-04", thought: "Wait...!"),
        StoryBeat(id: 5, imageName: "story-scene-05", thought: "—!"),
        StoryBeat(id: 6, imageName: "story-scene-06", thought: "...Where am I?"),
    ]
}
