struct StoryBeat {
    /// Scene number (1–6), matching storyboard scene numbering.
    let id: Int
    /// Asset catalog name for the scene illustration.
    /// Placeholder names (story-scene-01…06) until final art is delivered.
    let imageName: String
    /// Mori's inner monologue for this beat. nil = visual-only beat.
    let thought: String?
}
