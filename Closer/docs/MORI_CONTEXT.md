# Mori-San / Closer: Context Audit

Tanggal analisis: 2026-09-20  
Branch / commit: `fix/gameplay-1` / `79aea84ec0db30b37fc87e390d6449dfbb00d526`

Dokumen ini adalah hasil pembacaan kode dan aset, bukan hasil playtest pada perangkat atau simulator. Tidak ada perubahan gameplay, refactor, commit, atau push yang dibuat dalam audit ini.

## Ringkasan arsitektur

Closer adalah aplikasi iPhone portrait native Swift (Swift 5.0; deployment target yang benar-benar tertera pada target Xcode adalah iOS 17.0). Arsitekturnya kecil dan langsung, bukan MVVM murni:

- **SwiftUI** memegang root aplikasi, onboarding, storyline, dan state navigasi global (`AppFlowViewModel`).
- **UIKit** menjembatani SwiftUI ke `GameViewController`.
- **SpriteKit** merender map, halaman level (walaupun rute itu saat ini tidak dipanggil dari map), transition, congratulations, dan gameplay dalam satu `GameScene`.
- **Model data statis** (`GameLevel`, `PlatformModel`, level-data enums) mendefinisikan stage.
- **`GameViewModel`** menyimpan state satu level: graf koneksi, platform Mori, status petal/exit, dan POV. Ia bukan `ObservableObject`; `GameScene` memakainya langsung.

Tidak ada entity-component system, engine fisika SpriteKit, repository/network layer, persistence database, audio, atau dependency/package pihak ketiga. Tidak ada physics body atau `SKPhysicsContactDelegate`: collision, support, dan koneksi dihitung manual.

## Alur game aktual

```text
CompactGameApp
  -> ContentView (SwiftUI switch pada AppFlowViewModel.screen)
  -> OnboardingScreen (empat beat teks; Begin)
  -> StorylineScreen (otomatis 1 dtk)
  -> AppFlowViewModel.openMap()
  -> SpriteKitGameView -> GameViewController -> GameView -> GameScene
  -> MapView: tap Chapter 1/2/3
  -> startChapter -> startLevel(level pertama)
  -> GameScene.renderLevel()
  -> drag/snap dan/atau swipe perspektif; tap platform untuk berjalan
  -> ambil petal (bila ada) -> exit/black hole -> completeLevel
  -> level berikutnya dalam chapter -> CongratulationsView -> map
```

`ContentView` membuat `GameViewController` untuk `.map`, `.goal`, `.gameplay`, dan `.levelTransition`; controller itu menyajikan satu `GameScene` ber-`scaleMode = .resizeFill`. `GameScene.update` membandingkan `appFlow.screen` dengan `renderedScreen`; perubahan screen kemudian merender subtree SpriteKit baru.

`GoalDetailView` dan state `.goal` tersedia, tetapi map tidak membuka rute itu: `MapView` langsung memanggil `startChapter`. Tutorial juga tersedia dalam katalog, tetapi tidak ada UI/rute yang memulainya dari alur normal.

## Peta fitur ke file dan simbol penting

| Fitur | Implementasi utama | Catatan |
| --- | --- | --- |
| Entry / dependency UI | `App/CompactGameApp.swift`, `App/ContentView.swift`, `GameViewController.swift`, `Game/View/Global/GameView.swift` | SwiftUI -> UIKit -> SpriteKit. |
| Onboarding dan cerita | `OnboardingScreen`, `StorylineScreen` | `OnboardingView` (SpriteKit) ada tetapi tidak direferensikan. |
| Navigasi/progress | `AppFlowViewModel`, `GoalProgress`, `FlowerGoalData`, `LevelCatalog` | Progress hanya `Set` dalam memori session. |
| Map & pemilih level | `MapView`, `GoalDetailView`, `GameScene.startMapLevel/startSelectedLevel` | Map chapter langsung; GoalDetailView tak tercapai dari UI saat ini. |
| Kontrak level | `LevelConfiguration.swift` (`GameLevel`, `SnapRule`, `ExitConfiguration`, `PetalConfiguration`) | `LevelConfiguration` adalah typealias `GameLevel`. |
| Katalog/load level | `LevelCatalog`, `TutorialLevelData`, `ForgetMeNotLevelData`, `WhiteLilyLevelData`, `KambojaBaliLevelData` | `LevelCatalog.configurations` adalah gabungan semua array `levels`. |
| Render platform/shape | `PlatformNode` | Bentuk digambar manual sebagai `SKShapeNode`. |
| Mori/animasi | `PlayerNode` | Sprite idle/walk, ukuran render 52 x 52 pt; sprite di-offset y=-6. |
| Drag, snap, koneksi, gerak, fall | `GameScene` | Pusat aturan input dan permainan. |
| State permainan | `GameViewModel` | BFS graf koneksi melalui `connectionPath`. |
| Exit dan petal | `ExitNode`, `PetalNode`, fungsi `checkPetalCollection`, `enterExit` | Tidak memakai physics contact. |
| Chapter UI | `ChapterTransitionView`, `CongratulationsView`, `renderChapterProgressHUD` | Transition tutorial hanya dapat terjadi bila tutorial diselesaikan secara programatik. |

## Data level yang aktif dalam katalog

`LevelCatalog.configurations` memuat 18 definisi: dua tutorial, lima Forget-Me-Not, enam White Lily, dan lima Kamboja Bali. Semua level chapter memakai `.perspectiveCompact`; tutorial memakai `.compact`. Tidak ada definisi aktif dengan `.perspective` saja.

| Kelompok | ID | Definisi | Status dari alur UI |
| --- | --- | --- | --- |
| Tutorial | `tutorial-1`, `tutorial-2` | Platform persegi panjang besar, drag/snap compact | Ada di katalog tetapi tak dipilih dari map/goal. |
| Forget-Me-Not | `1.1`–`1.5` | 3–6 blok `single1x1`; hanya switch POV/petal/exit | Chapter 1 dapat dimainkan dari map. |
| White Lily | `2.1`–`2.6` | Mengenalkan `horizontal1x2`, `horizontal1x3`, `lShape`, `reverseLShape`; sebagian memiliki `SnapRule` | Chapter 2 dapat dimainkan dari map. |
| Kamboja Bali | `3.1`–`3.5` | Kombinasi shape dan layout front/side lebih padat | Chapter 3 dapat dimainkan dari map. |

Data bukan preview yang terbukti tidak dipakai: alias `ForgetMeNotLevelData.mainLevelOne` sampai `mainLevelFive`, karena katalog memakai array `levels`, bukan alias. Definisi `TutorialLevelData.movingBridgeLevel` aktif di katalog namun belum punya rute UI.

## Sistem koordinat dan rendering

### Ruang scene

- `GameView` membuat `GameScene(size: bounds.size)` dan memakai `.resizeFill`; satuan layout akhir adalah point SpriteKit dari ukuran `SKView` saat layout pertama.
- Origin SpriteKit berada di kiri-bawah. Tidak ada konversi safe area atau reference resolution tetap.
- Level non-perspektif: pusat platform = `(scene.width * horizontalPosition, scene.height * platformHeightRatio)`.
- Level perspektif: pusat platform = `(scene.width * frontPosition.x/y)` atau `sidePosition`, bergantung `GameViewModel.perspectivePOV`; bila posisi POV `nil`, fallback ke rumus non-perspektif.
- Gestur swipe horizontal minimal 35 pt pada area kosong mengubah POV dan menganimasikan platform 0,35 detik. Drag mengubah posisi node aktual; mengganti POV kemudian menganimasi node kembali ke koordinat data POV.

### Geometri blok dan surface jalan

- `PlatformNode.cellSize` = **44 pt**. `single1x1` memakai `model.size`; bentuk multi-cell mengabaikan `model.size.width` untuk footprint dan memakai sel 44 pt.
- Shape: `single1x1` = satu sel; `horizontal1x2` = (0,0),(1,0); `horizontal1x3` = (0,0),(1,0),(2,0); `lShape` menambah (0,1) di kiri; `reverseLShape` menambah (2,1) di kanan.
- `effectiveWidth/effectiveHeight` untuk multi-cell adalah bounding box sel 44 pt. Ini dipakai untuk batas layar, gap, dan snap.
- `occupiedCellRects(at:)` membangun rectangle setiap sel; ini dipakai untuk overlap obstacle dan path blocking. Dengan demikian collision L memang per-sel, bukan bounding box tunggal.
- `playableSurfaces(at:)` mengambil sel tertinggi per kolom. Landing surface single = `center + (0,55)`; multi-cell = `cell.maxY + 33`. Jadi pada sel 44 pt permukaan selalu 33 pt di atas top rectangle, dan Mori berdiri di titik tersebut.
- `landingPosition` memilih surface dengan tinggi sekitar posisi asal (toleransi 8 pt) lalu yang terdekat. `moriCurrentSurfacePosition` melacak cell multi-shape bila Mori berjalan di dalam platform.
- `PlayerNode` sendiri berada pada landing point, sedangkan gambar Mori berada y=-6 di dalam node untuk menempatkan kaki secara visual.

### Drag dan snap

- Drag dimulai hanya setelah perpindahan horizontal >= **8 pt**; sebelum itu tap dibedakan dari drag. Hanya sumbu X yang berubah.
- Pusat platform dikunci ke margin horizontal 12 pt setelah footprint (`effectiveWidth`) diperhitungkan.
- Untuk `single1x1`, `constrainedPlatformX` mencegah platform melintasi platform non-draggable menurut half-width. Untuk multi-cell, `isPlacementValid` membandingkan rectangle sel dengan obstacle non-draggable dan binary-search hingga batas valid.
- Platform draggable lain **bukan** obstacle dalam `isPlacementValid`; dua movable block dapat overlap menurut kode.
- Lepas drag dapat snap ke platform non-draggable bila surface memiliki selisih Y <= 8 pt dan edge gap 0...threshold. Default threshold 44 pt; `SnapRule` level dapat membatasi target dan memakai threshold lain (50 pada White Lily 2.3, 2.4, 2.5, 2.6).
- Snap menempatkan footprint tepat bersentuhan secara X, memberi haptic, dan menambah edge pada graf. Drag berikutnya menghapus snap edge bagi platform itu.
- Properti data `remainsDraggableWhenConnected` tidak dibaca oleh kode, sehingga saat ini tidak memengaruhi drag.

### Koneksi, pergerakan, obstacle, dan jatuh

- `GameViewModel.connections` adalah graf tak berarah. `connectionPath` memakai BFS dan `canMoveMori` hanya mengizinkan target yang dapat dijangkau dalam graf dan bukan platform saat ini.
- `initialConnections` ada di kontrak level, tetapi seluruh data level yang dibaca memakai default kosong.
- Pada mode perspektif, `updatePerspectiveConnections` otomatis membentuk edge bila gap bounding-edge <= 25 pt, ada pasangan playable surface beda tinggi <= 8 pt, dan garis antar surface tidak memotong rectangle sel mana pun. Setelah drag/snap dipakai versi yang membaca `node.position` aktual.
- `isHopPathBlocked` menguji garis pada setiap occupied cell rectangle (inset 1 pt). Ini adalah collision jalur geometris manual, bukan tabrakan fisika saat frame bergerak.
- Tap platform yang terhubung menggerakkan Mori melewati setiap node BFS memakai `SKAction.move`; speed = 220 pt/detik, minimum 0,15 s. Mori tidak melompat; tidak ada aksi push box.
- `isMoriSupported` menganggap Mori aman bila dekat (Y <= 18 pt) suatu playable surface dan jarak X ada dalam toleransi lebar. Saat tidak sedang beraksi dan tanpa support, `update` menjalankan `handleFall`, memainkan fall/fade, lalu reload level.

### Petal dan black hole

- `PetalConfiguration` dan `ExitConfiguration` adalah **offset lokal terhadap parent platform**, bukan koordinat scene. Default petal = (0,48); exit fallback = (45,55), sedangkan data chapter biasanya eksplisit (0,55).
- Petal dapat ditempatkan di platform mana pun, tetapi collection terjadi ketika ID platform Mori sama dengan `petal.platformID`; tidak ada radius/contact check terhadap posisi sprite petal.
- Exit dikunci bila level memiliki petal yang belum dikumpulkan. Tap exit akan mengguncang dan menampilkan notice; setelah petal, Mori masuk exit dan level selesai.
- Pada non-`.perspective`, `ExitNode` ditempel sebagai child dari platform exit. Karena offset umum y=55 sama dengan landing height block datar/single, pusat black hole berada tepat pada titik landing Mori (bukan offset ke belakang/depan). Untuk L/reverse-L, offset tunggal tidak memilih top cell tertentu.

## Progress dan unlock

- `GoalProgress.completedLevelIDs` adalah `Set<LevelID>` in-memory, diubah oleh `completeLevel`; tidak ada `UserDefaults`, file, CloudKit, atau save/load.
- `isLevelUnlocked` membuka level pertama setiap goal; level selanjutnya hanya jika level sebelumnya selesai. Namun map langsung selalu memanggil `startChapter` dan tidak mengecek chapter lock.
- `completeLevel` mengarahkan tutorial ke `levelTransition` bila ada tutorial berikutnya; chapter biasa otomatis memulai level berikutnya atau menampilkan congratulations setelah yang terakhir.
- `FlowerGoal.totalPetals` = jumlah level goal; HUD menampilkan indeks level `n/total`. Ini bukan render bunga progresif.

## Perbandingan konteks desain dengan implementasi

| Rancangan yang diberikan | Bukti implementasi | Status |
| --- | --- | --- |
| Puzzle 2D tampak depan, geser platform untuk menyambung | Ada drag X/snap dan graf path; level chapter memakai front/side normalized layouts dengan swipe perspektif. | Sebagian sesuai; implementasi lebih tepat disebut SpriteKit 2D dengan dua proyeksi layout, bukan renderer isometrik nyata. |
| Mori berjalan, tidak melompat, bukan mendorong box | `moveMori` memakai gerak linear antar landing surface; tidak ada jump/push mechanic. | Sesuai. |
| Tiga chapter, masing-masing lima stage | Chapter 1=5, Chapter 3=5, **Chapter 2=6** (`2.1`–`2.6`). | Berbeda. |
| Bunga terungkap setelah chapter selesai; sebelumnya hint | Tiga flower imageset ada, tetapi tidak ada `imageNamed` untuk aset bunga di source. Congratulations dan HUD memakai **petal**, bukan flower. | Belum diterapkan sebagai flower reveal. |
| Blackhole asli/palsu dan restart saat jatuh | Ada satu `ExitNode` dan restart saat kehilangan support. Tidak ada data/kelas/status untuk fake black hole. | Restart diterapkan; fake/real distinction belum terbukti ada. |
| Chapter 3 jalur bertahap/bolak-balik | Data 3.1–3.5 memuat shape dan front/side positions kompleks; tidak ada state level khusus untuk phase, requirement balik, atau path script. | Layout mendukung kemungkinan; mekanik bertahap/bolak-balik belum dibuktikan. |

## Temuan terkonfirmasi (berdasarkan kode)

1. **Platform tampak sejajar belum tentu terhubung secara gameplay.** Koneksi perspektif menuntut gap <=25, Y surface <=8, dan jalur garis bebas cell; koneksi snap juga hanya dibuat saat release dalam threshold. Kesamaan posisi visual saja bukan edge graf (`GameScene.updatePerspectiveConnections`, `GameViewModel.connectionPath`).
2. **Collision untuk L/reverse-L memakai bentuk sel aktual.** `occupiedCellRects` dan `isPlacementValid`/`isHopPathBlocked` mengiterasi tiap cell, sehingga bukan collision rectangle bounding box tunggal. Namun coverage ini hanya mengecek obstacle non-draggable saat drag; movable block lain dapat overlap.
3. **Black hole ditempel sebagai child platform dengan offset lokal.** Config chapter umumnya `(0,55)`, sama dengan landing surface blok datar. Posisi ini menjelaskan mengapa visual dapat tampak berada “di atas titik jalan”/beririsan dengan Mori, dan tidak menyediakan parameter orientasi/perspective depth. Ini belum menjadi klaim bug tampilan perangkat karena belum playtest.
4. **Aset petal salah untuk Chapter 2/3 saat collectible di layar.** `PetalNode.init` selalu membuat `SKTexture(imageNamed: "forget-me-not-petal")`; config level tidak membawa asset name. HUD memakai asset chapter yang benar. Jadi visual collectible Chapter 2/3 pasti tetap Forget-Me-Not menurut source.
5. **Flower reveal belum dipakai.** Flower imageset terinventarisasi, tetapi pencarian referensi source tidak menemukan nama aset bunga. `CongratulationsView` juga mengambil `petalAssetName`.
6. **`exitPlatformID` dan platform yang memegang exit bisa berbeda.** Contoh White Lily 2.4: `exitPlatformID = platformC`, tetapi `ExitConfiguration(platformID: platformD, ...)`; 2.5: `platformC` vs `platformE`. Runtime memakai `resolvedExitPlatformID` (config bila ada), sehingga properti dasar tidak menentukan perilaku pada level tersebut.
7. **Progress tidak persisten.** Semua completion hilang bila `AppFlowViewModel` baru dibuat/app diluncurkan ulang.
8. **Beberapa komponen tersedia tetapi tak dipanggil dari flow normal:** `OnboardingView`, `GameScene.showLevelComplete`, dan `AppFlowViewModel.openGoal`/`GoalDetailView`. `remainsDraggableWhenConnected` juga tidak dibaca.
9. **README tidak sinkron dengan target aktual.** README mengatakan iOS 16+, sedangkan `project.pbxproj` menetapkan `IPHONEOS_DEPLOYMENT_TARGET = 17.0`.

## Gejala yang belum dapat dipastikan tanpa playtest

- Mori benar-benar “menembus” atau “menabrak” block dalam build: kode memiliki path/support tests, namun aksi `SKAction.move` tidak melakukan swept collision per-frame, jadi perilaku visual perlu diuji pada layout/gesture nyata.
- Layout melenceng pada device tertentu: koordinat dinormalisasi terhadap ukuran scene dinamis dan `.resizeFill`, tanpa safe-area/reference-resolution; ini adalah risiko yang jelas, tetapi belum diukur di simulator/device.
- Apakah black hole tampak menempel sisi block dalam komposisi sebenarnya: code placement telah dibuktikan, namun output visual final bergantung ukuran view dan art/anchor.
- Kelayakan/solvability setiap puzzle dan koneksi yang terbentuk setelah kombinasi drag/POV belum diverifikasi melalui walkthrough.

## Build dan test

Perintah/proyek yang ditemukan:

```sh
xcodebuild -project ../Closer.xcodeproj -scheme Closer -destination 'platform=iOS Simulator,name=<simulator>' build
```

Proyek memiliki satu target aplikasi `Closer`; tidak ada `*.xctest`, source test, test target, `Package.swift`, scheme file yang terlacak, atau instruksi test lain. Build/run **belum dijalankan** dalam audit ini agar laporan tidak mengklaim validasi runtime yang belum dilakukan dan karena tugas ini terbatas pada pembacaan/konteks. Code signing target saat ini menggunakan team lokal yang telah diubah di worktree, sehingga build device dapat memerlukan kredensial yang sesuai.

## Cakupan pembacaan dan pengecualian

### Dibaca penuh

- Seluruh 33 file source Swift dalam `App/`, `Game/Model/`, `Game/View/`, `Game/ViewModel/`, `Shared/`, serta `AppDelegate.swift` dan `GameViewController.swift` (3.728 baris total).
- `Info.plist`, `../Closer.xcodeproj/project.pbxproj`, dan `../README.md`.
- Semua 10 `Contents.json` katalog aset.
- Inventaris semua file terlacak dan pencarian seluruh referensi aset/source.

### Aset biner

- Tidak dibaca sebagai teks.
- Semua PNG diinventarisasi melalui katalog dan dimensi. Animasi Mori masing-masing 1280x1280 px; flower/petal 1x/2x/3x masing-masing berkas 2420x1668 px.
- Sampel visual diperiksa: `mori-idle-1`, serta flower Forget-Me-Not, White Lily, dan Kamboja Bali. Katalog menandai semua flower/petal pada scale 1x/2x/3x; image set Mori hanya menyediakan berkas 1x (slot 2x/3x kosong).

### Tidak dibaca / tidak ada

- Isi `.git`, build output, DerivedData, cache, dan dependency pihak ketiga dikecualikan.
- Tidak ada `AGENTS.md` ditemukan pada cakupan proyek yang dapat dibaca.
- Tidak ada file source/config/dokumentasi/test lain yang ditemukan dari inventaris `rg --files -uu` (di luar pengecualian di atas). Tidak ada file yang tersisa untuk dipelajari.

## Catatan worktree

Sebelum dokumen ini dibuat, worktree sudah memiliki perubahan lokal berikut dan perubahan tersebut dipertahankan:

```text
M ../Closer.xcodeproj/project.pbxproj
```

Diff lokal hanya mengganti `DEVELOPMENT_TEAM` Debug dan Release dari `BK8NMHYG7J` ke `44SL47VC38`. Audit ini tidak mengubah file tersebut. Satu-satunya perubahan dari pekerjaan ini adalah penambahan dokumen konteks ini.
