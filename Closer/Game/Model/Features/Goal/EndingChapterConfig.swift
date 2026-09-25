import Foundation

struct EndingChapterBeat {
    let narration: String?
    let thought: String?
}

struct EndingChapterConfig {
    let backgroundName: String
    let beats: [EndingChapterBeat]
}

extension EndingChapterConfig {
    static func config(for goalID: GoalID) -> EndingChapterConfig? {
        guard let resolvedGoalID = FlowerGoalData.goal(for: goalID)?.id else { return nil }
        
        switch resolvedGoalID {
        case "chapter-1":
            return EndingChapterConfig(
                backgroundName: "background-chapter-1",
                beats: [
                    EndingChapterBeat(narration: "You've been walking for so long.", thought: nil),
                    EndingChapterBeat(narration: "But when was the last time you looked at yourself?", thought: nil),
                    EndingChapterBeat(narration: nil, thought: "\"I... forgot.\"")
                ]
            )
        case "chapter-2":
            return EndingChapterConfig(
                backgroundName: "background-chapter-2",
                beats: [
                    EndingChapterBeat(narration: "You called it home.", thought: nil),
                    EndingChapterBeat(narration: "But were you ever really there?", thought: nil),
                    EndingChapterBeat(narration: nil, thought: "\"...were they?\"")
                ]
            )
        case "balinese-frangipani", "chapter-3":
            return EndingChapterConfig(
                backgroundName: "background-chapter-3",
                beats: [
                    EndingChapterBeat(narration: "You said you needed no one.", thought: nil),
                    EndingChapterBeat(narration: "Did you believe it?", thought: nil),
                    EndingChapterBeat(narration: nil, thought: "\"I wanted to.\""),
                    EndingChapterBeat(narration: "Then why do you still leave the door open?", thought: nil)
                ]
            )
        default:
            return nil
        }
    }
}
