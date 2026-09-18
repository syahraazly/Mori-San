import CoreGraphics

enum WhiteLilyLevelData {
    // Level 2.1: Introduction of 1x2 shape
    static let level2_1 = GameLevel(
        id: "2.1",
        category: .family,
        interaction: .perspectiveCompact,
        platforms: [
            PlatformModel(
                id: "platformA",
                horizontalPosition: 0.18,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.18, y: 0.33),
                sidePosition: CGPoint(x: 0.18, y: 0.55),
                shape: .single1x1
            ),
            PlatformModel(
                id: "platformB",
                horizontalPosition: 0.45,
                size: CGSize(width: 92, height: 44),
                isDraggable: true,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.45, y: 0.33),
                sidePosition: CGPoint(x: 0.45, y: 0.33),
                shape: .horizontal1x2
            ),
            PlatformModel(
                id: "platformC",
                horizontalPosition: 0.82,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.82, y: 0.55),
                sidePosition: CGPoint(x: 0.68, y: 0.33),
                shape: .single1x1
            )
        ],
        player: PlayerModel(name: "Mori", startingPlatformID: "platformA"),
        exitPlatformID: "platformC",
        platformHeightRatio: 0.35,
        exitConfiguration: ExitConfiguration(platformID: "platformC", offset: CGPoint(x: 0, y: 55)),
        petalConfiguration: PetalConfiguration(platformID: "platformB", offset: CGPoint(x: 0, y: 48))
    )

    // Level 2.2: Introduction of 1x3 shape
    static let level2_2 = GameLevel(
        id: "2.2",
        category: .family,
        interaction: .perspectiveCompact,
        platforms: [
            PlatformModel(
                id: "platformA",
                horizontalPosition: 0.15,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.15, y: 0.33),
                sidePosition: CGPoint(x: 0.15, y: 0.55),
                shape: .single1x1
            ),
            PlatformModel(
                id: "platformB",
                horizontalPosition: 0.48,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.43, y: 0.33),
                sidePosition: CGPoint(x: 0.45, y: 0.33),
                shape: .horizontal1x3
            ),
            PlatformModel(
                id: "platformC",
                horizontalPosition: 0.85,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.85, y: 0.55),
                sidePosition: CGPoint(x: 0.73, y: 0.33),
                shape: .single1x1
            )
        ],
        player: PlayerModel(name: "Mori", startingPlatformID: "platformA"),
        exitPlatformID: "platformC",
        platformHeightRatio: 0.35,
        exitConfiguration: ExitConfiguration(platformID: "platformC", offset: CGPoint(x: 0, y: 55)),
        petalConfiguration: PetalConfiguration(platformID: "platformB", offset: CGPoint(x: 0, y: 48))
    )

    // Level 2.3: Pengenalan L-shape
    // Layar 390pt. A (1x1, eff=92): center=50.7, right=96.7
    // B (lShape, eff=132) start x=0.52: center=202.8, left=136.8, right=268.8
    //   Gap A↔B = 136.8-96.7 = 40.1 > 25 → tidak auto-connect ✓
    //   Gap B↔C = 293.3-268.8 = 24.5 ≤ 25 → auto-connect via perspectiveConnections ✓
    // C (1x1, eff=92) x=0.87: center=339.3, left=293.3
    // Setelah snap B→A: B.center=162.7, B.right=228.7 → gap B↔C=64.6 > 25 (perspConn hilang)
    //   → initialConnection B↔C mempertahankan link ✓
    // Puzzle: drag B kiri → snap → A↔B(snap)+B↔C(initial) → hop A→B(petal)→C(exit)
    static let level2_3 = GameLevel(
        id: "2.3",
        category: .family,
        interaction: .perspectiveCompact,
        platforms: [
            PlatformModel(
                id: "platformA",
                horizontalPosition: 0.13,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.13, y: 0.40),
                sidePosition: CGPoint(x: 0.13, y: 0.40),
                shape: .single1x1
            ),
            PlatformModel(
                id: "platformB",
                horizontalPosition: 0.52,
                size: CGSize(width: 92, height: 44),
                isDraggable: true,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.52, y: 0.40),
                sidePosition: CGPoint(x: 0.52, y: 0.40),
                shape: .lShape
            ),
            PlatformModel(
                id: "platformC",
                horizontalPosition: 0.87,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.87, y: 0.40),
                sidePosition: CGPoint(x: 0.87, y: 0.40),
                shape: .single1x1
            )
        ],
        player: PlayerModel(name: "Mori", startingPlatformID: "platformA"),
        exitPlatformID: "platformC",
        platformHeightRatio: 0.40,
        snapRules: [
            SnapRule(draggablePlatformID: "platformB", targetPlatformIDs: ["platformA"], threshold: 50)
        ],
        initialConnections: [
            ConnectionModel(firstPlatformID: "platformB", secondPlatformID: "platformC")
        ],
        exitConfiguration: ExitConfiguration(platformID: "platformC", offset: CGPoint(x: 0, y: 55)),
        petalConfiguration: PetalConfiguration(platformID: "platformB", offset: CGPoint(x: -20, y: 55))
    )

    // Level 2.4: Pengenalan Reverse-L shape
    // Sama dengan 2.3 tapi menggunakan reverseLShape untuk B.
    // reverseLShape juga eff=132pt, geometri identik.
    // Puzzle: drag B kiri → snap → A↔B(snap)+B↔C(initial) → hop A→B(petal)→C(exit)
    static let level2_4 = GameLevel(
        id: "2.4",
        category: .family,
        interaction: .perspectiveCompact,
        platforms: [
            PlatformModel(
                id: "platformA",
                horizontalPosition: 0.13,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.13, y: 0.40),
                sidePosition: CGPoint(x: 0.13, y: 0.40),
                shape: .single1x1
            ),
            PlatformModel(
                id: "platformB",
                horizontalPosition: 0.52,
                size: CGSize(width: 92, height: 44),
                isDraggable: true,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.52, y: 0.40),
                sidePosition: CGPoint(x: 0.52, y: 0.40),
                shape: .reverseLShape
            ),
            PlatformModel(
                id: "platformC",
                horizontalPosition: 0.87,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.87, y: 0.40),
                sidePosition: CGPoint(x: 0.87, y: 0.40),
                shape: .single1x1
            )
        ],
        player: PlayerModel(name: "Mori", startingPlatformID: "platformA"),
        exitPlatformID: "platformC",
        platformHeightRatio: 0.40,
        snapRules: [
            SnapRule(draggablePlatformID: "platformB", targetPlatformIDs: ["platformA"], threshold: 50)
        ],
        initialConnections: [
            ConnectionModel(firstPlatformID: "platformB", secondPlatformID: "platformC")
        ],
        exitConfiguration: ExitConfiguration(platformID: "platformC", offset: CGPoint(x: 0, y: 55)),
        petalConfiguration: PetalConfiguration(platformID: "platformB", offset: CGPoint(x: 20, y: 55))
    )

    // Level 2.5: Kombinasi 1x2 bridge + L-shape destination
    // A (1x1, eff=92) x=0.13: center=50.7, right=96.7
    // B (1x2, eff=88) start x=0.50: center=195, left=151, right=239
    //   Gap A↔B = 151-96.7 = 54.3 > 25 → tidak auto-connect ✓
    //   Gap B↔C = 268-239 = 29 > 25 → tidak auto-connect via perspective ✓ → butuh initialConnection
    // C (lShape, eff=132) x=0.80: center=312, left=246, right=378
    //   Setelah snap B→A: B.center=96.7+44=140.7, B.right=184.7
    //   Gap B↔C = 246-184.7 = 61.3 > 25 → perspConn hilang, initialConnection B↔C bertahan ✓
    // Puzzle: drag B kiri → snap A → A↔B(snap)+B↔C(initial) → A→B→C(petal+exit)
    static let level2_5 = GameLevel(
        id: "2.5",
        category: .family,
        interaction: .perspectiveCompact,
        platforms: [
            PlatformModel(
                id: "platformA",
                horizontalPosition: 0.13,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.13, y: 0.40),
                sidePosition: CGPoint(x: 0.13, y: 0.40),
                shape: .single1x1
            ),
            PlatformModel(
                id: "platformB",
                horizontalPosition: 0.50,
                size: CGSize(width: 92, height: 44),
                isDraggable: true,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.50, y: 0.40),
                sidePosition: CGPoint(x: 0.50, y: 0.40),
                shape: .horizontal1x2
            ),
            PlatformModel(
                id: "platformC",
                horizontalPosition: 0.80,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.80, y: 0.40),
                sidePosition: CGPoint(x: 0.80, y: 0.40),
                shape: .lShape
            )
        ],
        player: PlayerModel(name: "Mori", startingPlatformID: "platformA"),
        exitPlatformID: "platformC",
        platformHeightRatio: 0.40,
        snapRules: [
            SnapRule(draggablePlatformID: "platformB", targetPlatformIDs: ["platformA"], threshold: 50)
        ],
        initialConnections: [
            ConnectionModel(firstPlatformID: "platformB", secondPlatformID: "platformC")
        ],
        exitConfiguration: ExitConfiguration(platformID: "platformC", offset: CGPoint(x: -20, y: 55)),
        petalConfiguration: PetalConfiguration(platformID: "platformC", offset: CGPoint(x: -20, y: 55))
    )

    // Level 2.6: Reverse-L bridge + 1x3 destination
    // A (1x1, eff=92) x=0.13: center=50.7, right=96.7
    // B (reverseLShape, eff=132) start x=0.52: center=202.8, left=136.8, right=268.8
    //   Gap A↔B = 136.8-96.7 = 40.1 > 25 → tidak auto-connect ✓
    // C (1x3, eff=132) x=0.87: center=339.3, left=273.3
    //   Gap B↔C = 273.3-268.8 = 4.5 ≤ 25 → auto-connect via perspectiveConnections ✓
    //   Setelah snap B→A: B.center=162.7, B.right=228.7 → gap B↔C=44.6 > 25 → hilang
    //   → initialConnection B↔C mempertahankan link ✓
    // Puzzle: drag B kiri → snap → A↔B(snap)+B↔C(initial) → A→B(petal)→C(exit)
    static let level2_6 = GameLevel(
        id: "2.6",
        category: .family,
        interaction: .perspectiveCompact,
        platforms: [
            PlatformModel(
                id: "platformA",
                horizontalPosition: 0.13,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.13, y: 0.40),
                sidePosition: CGPoint(x: 0.13, y: 0.40),
                shape: .single1x1
            ),
            PlatformModel(
                id: "platformB",
                horizontalPosition: 0.52,
                size: CGSize(width: 92, height: 44),
                isDraggable: true,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.52, y: 0.40),
                sidePosition: CGPoint(x: 0.52, y: 0.40),
                shape: .reverseLShape
            ),
            PlatformModel(
                id: "platformC",
                horizontalPosition: 0.87,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.87, y: 0.40),
                sidePosition: CGPoint(x: 0.87, y: 0.40),
                shape: .horizontal1x3
            )
        ],
        player: PlayerModel(name: "Mori", startingPlatformID: "platformA"),
        exitPlatformID: "platformC",
        platformHeightRatio: 0.40,
        snapRules: [
            SnapRule(draggablePlatformID: "platformB", targetPlatformIDs: ["platformA"], threshold: 50)
        ],
        initialConnections: [
            ConnectionModel(firstPlatformID: "platformB", secondPlatformID: "platformC")
        ],
        exitConfiguration: ExitConfiguration(platformID: "platformC", offset: CGPoint(x: 0, y: 55)),
        petalConfiguration: PetalConfiguration(platformID: "platformB", offset: CGPoint(x: 20, y: 55))
    )

    static let goal = FlowerGoal(
        id: "chapter-2",
        title: "CHAPTER 2: WHITE LILY",
        levelIDs: ["2.1", "2.2", "2.3", "2.4", "2.5", "2.6"],
        petalAssetName: "white-lily-petal"
    )

    static let levels = [level2_1, level2_2, level2_3, level2_4, level2_5, level2_6]
}
