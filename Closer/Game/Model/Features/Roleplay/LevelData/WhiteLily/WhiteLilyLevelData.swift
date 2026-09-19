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
                size: CGSize(width: 44, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.28, y: 0.60),
                sidePosition: CGPoint(x: 0.28, y: 0.33),
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
                horizontalPosition: 0.45,
                size: CGSize(width: 44, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.82, y: 0.33),
                sidePosition: CGPoint(x: 0.71, y: 0.55),
                shape: .single1x1
            ),
            PlatformModel(
                id: "platformD",
                horizontalPosition: 0.45,
                size: CGSize(width: 44, height: 44),
                isDraggable: true,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.68, y: 0.60),
                sidePosition: CGPoint(x: 0.45, y: 0.64),
                shape: .single1x1
            ),
            PlatformModel(
                id: "platformE",
                horizontalPosition: 0.82,
                size: CGSize(width: 44, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.82, y: 0.55),
                sidePosition: CGPoint(x: 0.82, y: 0.55),
                shape: .single1x1
            )
        ],
        player: PlayerModel(name: "Mori", startingPlatformID: "platformA"),
        exitPlatformID: "platformE",
        platformHeightRatio: 0.35,
        exitConfiguration: ExitConfiguration(platformID: "platformE", offset: CGPoint(x: 0, y: 55)),
        petalConfiguration: PetalConfiguration(platformID: "platformD", offset: CGPoint(x: 0, y: 48))
    )

    // Level 2.2: Introduction of 1x3 shape
    static let level2_2 = GameLevel(
        id: "2.2",
        category: .family,
        interaction: .perspectiveCompact,
        platforms: [
            PlatformModel(
                id: "platformA",
                horizontalPosition: 0.18,
                size: CGSize(width: 44, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.16, y: 0.42),
                sidePosition: CGPoint(x: 0.16, y: 0.42),
                shape: .single1x1
            ),
            PlatformModel(
                id: "platformB",
                horizontalPosition: 0.45,
                size: CGSize(width: 92, height: 44),
                isDraggable: true,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.42, y: 0.24),
                sidePosition: CGPoint(x: 0.42, y: 0.42),
                shape: .horizontal1x2
            ),
            PlatformModel(
                id: "platformC",
                horizontalPosition: 0.45,
                size: CGSize(width: 44, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.82, y: 0.24),
                sidePosition: CGPoint(x: 0.71, y: 0.42),
                shape: .single1x1
            ),
            PlatformModel(
                id: "platformD",
                horizontalPosition: 0.45,
                size: CGSize(width: 44, height: 44),
                isDraggable: true,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.45, y: 0.42),
                sidePosition: CGPoint(x: 0.68, y: 0.64),
                shape: .horizontal1x3
            ),
            PlatformModel(
                id: "platformE",
                horizontalPosition: 0.82,
                size: CGSize(width: 44, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.68, y: 0.52),
                sidePosition: CGPoint(x: 0.24, y: 0.64),
                shape: .single1x1
            )
        ],
        player: PlayerModel(name: "Mori", startingPlatformID: "platformA"),
        exitPlatformID: "platformE",
        platformHeightRatio: 0.35,
        exitConfiguration: ExitConfiguration(platformID: "platformE", offset: CGPoint(x: 0, y: 55)),
        petalConfiguration: PetalConfiguration(platformID: "platformC", offset: CGPoint(x: 0, y: 48))
    )

    // Level 2.3: Pengenalan L-shape
    // Layar 390pt. A (1x1, eff=92): center=50.7, right=96.7
    // B (lShape, eff=132) start x=0.52: center=202.8, left=136.8, right=268.8
    //   Gap A↔B = 136.8-96.7 = 40.1 > 25 → tidak auto-connect ✓
    //   Gap B↔C = 293.3-268.8 = 24.5 ≤ 25 → auto-connect via perspectiveConnections ✓
    // C (1x1, eff=92) x=0.87: center=339.3, left=293.3
    // Setelah snap B→A: B.center=162.7, B.right=228.7 → gap B↔C=64.6 > 25 (perspConn hilang)
    //   → initialConnection B↔C mempertahankan link ✓
    // Level 2.3: Pengenalan L-shape
    // Puzzle: drag B kiri → snap A → jalan A→B(petal) → drag B kanan → snap C → jalan B→C(exit)
    static let level2_3 = GameLevel(
        id: "2.3",
        category: .family,
        interaction: .perspectiveCompact,
        platforms: [
            PlatformModel(
                id: "platformA",
                horizontalPosition: 0.13,
                size: CGSize(width: 44, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.13, y: 0.24),
                sidePosition: CGPoint(x: 0.13, y: 0.55),
                shape: .single1x1
            ),
            PlatformModel(
                id: "platformB",
                horizontalPosition: 0.52,
                size: CGSize(width: 92, height: 44),
                isDraggable: true,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.48, y: 0.49),
                sidePosition: CGPoint(x: 0.48, y: 0.49),
                shape: .lShape
            ),
            PlatformModel(
                id: "platformC",
                horizontalPosition: 0.52,
                size: CGSize(width: 44, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.13, y: 0.55),
                sidePosition: CGPoint(x: 0.72, y: 0.49),
                shape: .single1x1
            ),
            PlatformModel(
                id: "platformD",
                horizontalPosition: 0.52,
                size: CGSize(width: 44, height: 44),
                isDraggable: true,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.68, y: 0.24),
                sidePosition: CGPoint(x: 0.68, y: 0.24),
                shape: .horizontal1x2
            ),
            PlatformModel(
                id: "platformE",
                horizontalPosition: 0.87,
                size: CGSize(width: 44, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.87, y: 0.40),
                sidePosition: CGPoint(x: 0.87, y: 0.24),
                shape: .single1x1
            )
        ],
        player: PlayerModel(name: "Mori", startingPlatformID: "platformA"),
        exitPlatformID: "platformE",
        platformHeightRatio: 0.40,
        snapRules: [
            SnapRule(draggablePlatformID: "platformB", targetPlatformIDs: ["platformA", "platformC"], threshold: 50)
        ],
        exitConfiguration: ExitConfiguration(platformID: "platformE", offset: CGPoint(x: 0, y: 55)),
        petalConfiguration: PetalConfiguration(platformID: "platformC", offset: CGPoint(x: 0, y: 40))
    )

    // Level 2.4: Pengenalan Reverse-L shape
    // Sama dengan 2.3 tapi menggunakan reverseLShape untuk B.
    // reverseLShape juga eff=132pt, geometri identik.
    // Puzzle: drag B kiri → snap → A↔B(snap) → hop A→B(petal) → drag B kanan → snap B↔C → C(exit)
    static let level2_4 = GameLevel(
        id: "2.4",
        category: .family,
        interaction: .perspectiveCompact,
        platforms: [
            PlatformModel(
                id: "platformA",
                horizontalPosition: 0.13,
                size: CGSize(width: 44, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.13, y: 0.34),
                sidePosition: CGPoint(x: 0.48, y: 0.72),
                shape: .single1x1
            ),
            PlatformModel(
                id: "platformB",
                horizontalPosition: 0.52,
                size: CGSize(width: 92, height: 44),
                isDraggable: true,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.52, y: 0.34),
                sidePosition: CGPoint(x: 0.52, y: 0.54),
                shape: .reverseLShape
            ),
            PlatformModel(
                id: "platformC",
                horizontalPosition: 0.52,
                size: CGSize(width: 44, height: 44),
                isDraggable: true,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.42, y: 0.54),
                sidePosition: CGPoint(x: 0.64, y: 0.72),
                shape: .horizontal1x2
            ),
            PlatformModel(
                id: "platformD",
                horizontalPosition: 0.87,
                size: CGSize(width: 44, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.87, y: 0.54),
                sidePosition: CGPoint(x: 0.87, y: 0.40),
                shape: .single1x1
            )
        ],
        player: PlayerModel(name: "Mori", startingPlatformID: "platformA"),
        exitPlatformID: "platformC",
        platformHeightRatio: 0.40,
        snapRules: [
            SnapRule(draggablePlatformID: "platformB", targetPlatformIDs: ["platformA", "platformC"], threshold: 50)
        ],
        exitConfiguration: ExitConfiguration(platformID: "platformD", offset: CGPoint(x: 0, y: 55)),
        petalConfiguration: PetalConfiguration(platformID: "platformB", offset: CGPoint(x: 0, y: 40))
    )

    // Level 2.5: Kombinasi 1x2 bridge + L-shape destination
    // A (1x1, eff=92) x=0.13: center=50.7, right=96.7
    // B (1x2, eff=88) start x=0.50: center=195, left=151, right=239
    // C (lShape, eff=132) x=0.80: center=312, left=246, right=378
    // Puzzle: drag B kiri → snap A → hop A→B → drag B kanan → snap C → hop B→C(petal+exit)
    static let level2_5 = GameLevel(
        id: "2.5",
        category: .family,
        interaction: .perspectiveCompact,
        platforms: [
            PlatformModel(
                id: "platformA",
                horizontalPosition: 0.13,
                size: CGSize(width: 44, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.13, y: 0.40),
                sidePosition: CGPoint(x: 0.13, y: 0.24),
                shape: .single1x1
            ),
            PlatformModel(
                id: "platformB",
                horizontalPosition: 0.24,
                size: CGSize(width: 44, height: 44),
                isDraggable: true,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.24, y: 0.40),
                sidePosition: CGPoint(x: 0.24, y: 0.64),
                shape: .single1x1
            ),
            PlatformModel(
                id: "platformC",
                horizontalPosition: 0.50,
                size: CGSize(width: 92, height: 44),
                isDraggable: true,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.62, y: 0.34),
                sidePosition: CGPoint(x: 0.42, y: 0.34),
                shape: .lShape
            ),
            PlatformModel(
                id: "platformD",
                horizontalPosition: 0.50,
                size: CGSize(width: 92, height: 44),
                isDraggable: true,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.42, y: 0.20),
                sidePosition: CGPoint(x: 0.13, y: 0.40),
                shape: .horizontal1x2
            ),
            PlatformModel(
                id: "platformE",
                horizontalPosition: 0.50,
                size: CGSize(width: 42, height: 44),
                isDraggable: true,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.82, y: 0.72),
                sidePosition: CGPoint(x: 0.64, y: 0.64),
                shape: .single1x1
            ),
            PlatformModel(
                id: "platformF",
                horizontalPosition: 0.80,
                size: CGSize(width: 92, height: 44),
                isDraggable: false,
                remainsDraggableWhenConnected: false,
                frontPosition: CGPoint(x: 0.80, y: 0.20),
                sidePosition: CGPoint(x: 0.80, y: 0.34),
                shape: .reverseLShape
            )
        ],
        player: PlayerModel(name: "Mori", startingPlatformID: "platformA"),
        exitPlatformID: "platformC",
        platformHeightRatio: 0.40,
        snapRules: [
            SnapRule(draggablePlatformID: "platformB", targetPlatformIDs: ["platformA", "platformE"], threshold: 50)
        ],
        exitConfiguration: ExitConfiguration(platformID: "platformE", offset: CGPoint(x: 0, y: 55)),
        petalConfiguration: PetalConfiguration(platformID: "platformF", offset: CGPoint(x: 0, y: 55))
    )

    // Level 2.6: Reverse-L bridge + 1x3 destination
    // A (1x1, eff=92) x=0.13: center=50.7, right=96.7
    // B (reverseLShape, eff=132) start x=0.52: center=202.8, left=136.8, right=268.8
    // C (1x3, eff=132) x=0.87: center=339.3, left=273.3
    // Puzzle: drag B kiri → snap A → hop A→B(petal) → drag B kanan → snap C → hop B→C(exit)
    static let level2_6 = GameLevel(
            id: "2.6",
            category: .family,
            interaction: .perspectiveCompact,
            platforms: [
                // A: starting platform (single1x1)
                PlatformModel(
                    id: "platformA",
                    horizontalPosition: 0.13,
                    size: CGSize(width: 44, height: 44),
                    isDraggable: false,
                    remainsDraggableWhenConnected: false,
                    frontPosition: CGPoint(x: 0.13, y: 0.40),
                    sidePosition: CGPoint(x: 0.13, y: 0.40),
                    shape: .single1x1
                ),
                // B: lShape draggable — drag left to bridge A→C
                PlatformModel(
                    id: "platformB",
                    horizontalPosition: 0.52,
                    size: CGSize(width: 92, height: 44),
                    isDraggable: true,
                    remainsDraggableWhenConnected: false,
                    frontPosition: CGPoint(x: 0.52, y: 0.34),
                    sidePosition: CGPoint(x: 0.52, y: 0.72),
                    shape: .lShape
                ),
                // C: static horizontal1x2 — intermediate hub in front view
                PlatformModel(
                    id: "platformC",
                    horizontalPosition: 0.50,
                    size: CGSize(width: 92, height: 44),
                    isDraggable: false,
                    remainsDraggableWhenConnected: false,
                    frontPosition: CGPoint(x: 0.50, y: 0.40),
                    sidePosition: CGPoint(x: 0.50, y: 0.72),
                    shape: .horizontal1x2
                ),
                // D: reverseLShape draggable — drag left to bridge C→E
                PlatformModel(
                    id: "platformD",
                    horizontalPosition: 0.80,
                    size: CGSize(width: 92, height: 44),
                    isDraggable: true,
                    remainsDraggableWhenConnected: false,
                    frontPosition: CGPoint(x: 0.80, y: 0.34),
                    sidePosition: CGPoint(x: 0.80, y: 0.72),
                    shape: .reverseLShape
                ),
                // E: static horizontal1x3 — holds petal, right side front view
                PlatformModel(
                    id: "platformE",
                    horizontalPosition: 0.50,
                    size: CGSize(width: 92, height: 44),
                    isDraggable: false,
                    remainsDraggableWhenConnected: false,
                    frontPosition: CGPoint(x: 0.87, y: 0.40),
                    sidePosition: CGPoint(x: 0.36, y: 0.72),
                    shape: .horizontal1x3
                ),
                // F: static single1x1 — only meaningful in side view, bridges A→G
                PlatformModel(
                    id: "platformF",
                    horizontalPosition: 0.50,
                    size: CGSize(width: 44, height: 44),
                    isDraggable: false,
                    remainsDraggableWhenConnected: false,
                    frontPosition: CGPoint(x: 0.50, y: 0.20),
                    sidePosition: CGPoint(x: 0.50, y: 0.40),
                    shape: .single1x1
                ),
                // G: exit platform (single1x1) — reachable only via side view
                PlatformModel(
                    id: "platformG",
                    horizontalPosition: 0.87,
                    size: CGSize(width: 44, height: 44),
                    isDraggable: false,
                    remainsDraggableWhenConnected: false,
                    frontPosition: CGPoint(x: 0.87, y: 0.20),
                    sidePosition: CGPoint(x: 0.87, y: 0.40),
                    shape: .single1x1
                )
            ],
            player: PlayerModel(name: "Mori", startingPlatformID: "platformA"),
            exitPlatformID: "platformG",
            platformHeightRatio: 0.40,
            snapRules: [
                SnapRule(draggablePlatformID: "platformB", targetPlatformIDs: ["platformA", "platformC"], threshold: 50),
                SnapRule(draggablePlatformID: "platformD", targetPlatformIDs: ["platformC", "platformE"], threshold: 50)
            ],
            exitConfiguration: ExitConfiguration(platformID: "platformG", offset: CGPoint(x: 0, y: 55)),
            petalConfiguration: PetalConfiguration(platformID: "platformE", offset: CGPoint(x: 0, y: 55))
        )

    static let goal = FlowerGoal(
        id: "chapter-2",
        title: "CHAPTER 2: WHITE LILY",
        levelIDs: ["2.1", "2.2", "2.3", "2.4", "2.5", "2.6"],
        petalAssetName: "white-lily-petal"
    )

    static let levels = [level2_1, level2_2, level2_3, level2_4, level2_5, level2_6]
}
