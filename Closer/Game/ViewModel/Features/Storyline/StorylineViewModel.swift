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

        // Intro
        StoryBeat(
            id: 0,
            imageName: "storyboard-minimalist-background",
            narration: "The world was once connected... \nUntil the paths drifted apart...",
            thought: nil,
            layout: .centerLeading
        ),

        // 01 — A Small World
        StoryBeat(
            id: 1,
            imageName: "storyboard-1",
            narration: """
            Mori's world has always been small.
            Everything Mori knows is right here.
            """,
            thought: "I like it this way.",
            layout: .topLeading
        ),

        // 02 — Little Moments
        StoryBeat(
            id: 2,
            imageName: "storyboard-2",
            narration: """
            Mori's days are simple and familiar.
            And that's enough for Mori.
            """,
            thought: "I could stay like this forever.",
            layout: .topLeading
        ),

        // 03 — Something Changes
        StoryBeat(
            id: 3,
            imageName: "storyboard-3",
            narration: """
            Until one night, something feels different.
            """,
            thought: "...Was that always there?",
            layout: .topLeading,
            textTopPadding: 160
        ),

        // 04 — The World Breaks
        StoryBeat(
            id: 4,
            imageName: "storyboard-4",
            narration: """
            One by one, the things that were always close begin to drift away.
            """,
            thought: "Wait... what's happening?",
            layout: .centerLeading
        ),

        // 05 — Pulled In (Beat 1)
        StoryBeat(
            id: 5,
            imageName: "storyboard-5",
            narration: "Mori tries to hold on. But the little world is already slipping away.",
            thought: nil,
            layout: .topLeading,
            textTopPadding: 350
        ),

        // 05 — Pulled In (Beat 2)
        StoryBeat(
            id: 6,
            imageName: "storyboard-6",
            narration: nil,
            thought: "No-!",
            layout: .topLeading,
            textTopPadding: 280,
            textLeadingPadding: 40
        ),

        // 06 — Waking Up (Beat 1)
        StoryBeat(
            id: 7,
            imageName: "storyboard-mori-jatuh-2",
            narration: "When Mori opens the eyes, \nthe world Mori's knows is gone.",
            thought: nil,
            layout: .topLeading,
            textTopPadding: 260
        ),
        
        // 06 — Waking Up (Beat 2)
        StoryBeat(
            id: 8,
            imageName: "storyboard-mori-jatuh-4",
            narration: nil,
            thought: "...Where am I?",
            layout: .topLeading,
            textTopPadding: 340
        )
    ]
}
