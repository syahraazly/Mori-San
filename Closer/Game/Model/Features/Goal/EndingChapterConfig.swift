import Foundation

struct EndingChapterBeat {
    let assetName: String?
    let narration: String?
    let thought: String?
    let customThoughtPosition: CGPoint?
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
                    EndingChapterBeat(assetName: "endingchapter-lv1-1", narration: "You've been walking for so long.", thought: nil, customThoughtPosition: nil),
                    EndingChapterBeat(assetName: "endingchapter-lv1-2", narration: "But when was the last time you looked at yourself?", thought: nil, customThoughtPosition: nil),
                    EndingChapterBeat(assetName: "endingchapter-lv1-3", narration: nil, thought: "\"I... forgot.\"", customThoughtPosition: CGPoint(x: 0.65, y: 0.55))
                ]
            )
        case "chapter-2":
            return EndingChapterConfig(
                backgroundName: "background-chapter-2",
                beats: [
                    EndingChapterBeat(assetName: nil, narration: "You called it home.", thought: nil, customThoughtPosition: nil),
                    EndingChapterBeat(assetName: nil, narration: "But were you ever really there?", thought: nil, customThoughtPosition: nil),
                    EndingChapterBeat(assetName: nil, narration: nil, thought: "\"...were they?\"", customThoughtPosition: nil)
                ]
            )
        case "balinese-frangipani", "chapter-3":
            return EndingChapterConfig(
                backgroundName: "background-chapter-3",
                beats: [
                    EndingChapterBeat(assetName: nil, narration: "You said you needed no one.", thought: nil, customThoughtPosition: nil),
                    EndingChapterBeat(assetName: nil, narration: "Did you believe it?", thought: nil, customThoughtPosition: nil),
                    EndingChapterBeat(assetName: nil, narration: nil, thought: "\"I wanted to.\"", customThoughtPosition: nil),
                    EndingChapterBeat(assetName: nil, narration: "Then why do you still leave the door open?", thought: nil, customThoughtPosition: nil)
                ]
            )
        default:
            return nil
        }
    }
}
