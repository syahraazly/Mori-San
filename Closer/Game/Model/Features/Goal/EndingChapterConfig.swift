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
                    EndingChapterBeat(assetName: "endingchapter-lv2-1", narration: "You called it home.", thought: nil, customThoughtPosition: nil),
                    EndingChapterBeat(assetName: "endingchapter-lv2-2", narration: "But were you ever really there?", thought: nil, customThoughtPosition: nil),
                    EndingChapterBeat(assetName: "endingchapter-lv2-3", narration: nil, thought: "\"...were they?\"", customThoughtPosition: CGPoint(x: 0.64, y: 0.53))
                ]
            )
        case "balinese-frangipani", "chapter-3":
            return EndingChapterConfig(
                backgroundName: "background-chapter-3",
                beats: [
                    EndingChapterBeat(assetName: "endingchapter-lv3-1", narration: "You said you needed no one.\nDid you believe it?", thought: nil, customThoughtPosition: nil),
                    EndingChapterBeat(assetName: "endingchapter-lv3-2", narration: nil, thought: "\"I wanted to.\"", customThoughtPosition: CGPoint(x: 0.68, y: 0.47)),
                    EndingChapterBeat(assetName: "endingchapter-lv3-3", narration: "Then why do you still leave the door open?", thought: nil, customThoughtPosition: nil)
                ]
            )
        default:
            return nil
        }
    }
}
