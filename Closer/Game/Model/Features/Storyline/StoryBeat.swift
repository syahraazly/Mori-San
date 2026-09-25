import Foundation

struct StoryBeat {

    /// Scene number (1–6), matching storyboard scene numbering.
    let id: Int

    /// Asset catalog name for the scene illustration.
    let imageName: String

    /// External narrator voice.
    let narration: String?

    /// Mori's inner thought.
    let thought: String?

    /// General text placement for the scene.
    let layout: StoryTextLayout

    /// Optional override for the top padding (in points) of the text block.
    /// When nil, StoryPageView uses its default value of 110pt.
    /// Increase to push text lower; decrease to push it higher.
    var textTopPadding: CGFloat? = nil
    
    var textLeadingPadding: CGFloat? = nil
}

enum StoryTextLayout {
    case topLeading
    case centerLeading
    case bottomLeading
}
