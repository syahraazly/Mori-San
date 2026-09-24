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

    init(
        beats: [StoryBeat] = StorylineViewModel.defaultBeats,
        onComplete: @escaping () -> Void = {}
    ) {
        precondition(
            !beats.isEmpty,
            "StorylineViewModel requires at least one beat."
        )

        self.beats = beats
        self.onComplete = onComplete
    }

    // MARK: - Derived State

    var currentBeat: StoryBeat {
        beats[currentBeatIndex]
    }

    var isLastBeat: Bool {
        currentBeatIndex == beats.count - 1
    }

    // MARK: - Actions

    func advanceStory() {
        if isLastBeat {
            onComplete()
        } else {
            currentBeatIndex += 1
        }
    }

    func skipStory() {
        onComplete()
    }

    // MARK: - Default Content

    static let defaultBeats: [StoryBeat] = [

        // 01 — A Small World
        StoryBeat(
            id: 1,
            imageName: "story-scene-01",
            narration: """
            Mori's world has always been small.
            Everything he knows is right here.
            """,
            thought: "I like it this way.",
            layout: .topLeading
        ),

        // 02 — Little Moments
        StoryBeat(
            id: 2,
            imageName: "story-scene-02",
            narration: """
            His days are simple and familiar.
            And that's enough for Mori.
            """,
            thought: "I could stay like this forever.",
            layout: .topLeading
        ),

        // 03 — Something Changes
        StoryBeat(
            id: 3,
            imageName: "story-scene-03",
            narration: """
            Until one night, something feels different.
            """,
            thought: "...Was that always there?",
            layout: .topLeading
        ),

        // 04 — The World Breaks
        StoryBeat(
            id: 4,
            imageName: "story-scene-04",
            narration: """
            One by one, the things that were always close begin to drift away.
            """,
            thought: "Wait... what's happening?",
            layout: .centerLeading
        ),

        // 05 — Pulled In
        StoryBeat(
            id: 5,
            imageName: "story-scene-05",
            narration: """
            Mori tries to hold on. But his little world is already slipping away.
            """,
            thought: "No—!",
            layout: .bottomLeading
        ),

        // 06 — Waking Up
        StoryBeat(
            id: 6,
            imageName: "story-scene-06",
            narration: """
            When Mori opens his eyes, the world he knows is gone.
            """,
            thought: "...Where am I?",
            layout: .topLeading
        )
    ]
}
