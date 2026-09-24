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
}

enum StoryTextLayout {
    case topLeading
    case centerLeading
    case bottomLeading
}
