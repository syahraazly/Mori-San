import CoreGraphics

struct PlayerModel {
    let name: String
    let startingPlatformID: String
    let startingOffset: CGPoint

    init(name: String, startingPlatformID: String, startingOffset: CGPoint = .zero) {
        self.name = name
        self.startingPlatformID = startingPlatformID
        self.startingOffset = startingOffset
    }
}
