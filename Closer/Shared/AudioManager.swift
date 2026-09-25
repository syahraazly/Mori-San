import AVFoundation
import UIKit

final class AudioManager {
    static let shared = AudioManager()
    
    private var musicPlayer: AVAudioPlayer?
    private var currentMusicName: String?
    private var sfxPlayers: [AVAudioPlayer] = []
    
    private init() {
        configureAudioSession()
    }
    
    private func configureAudioSession() {
        #if os(iOS)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set AVAudioSession category: \(error)")
        }
        #endif
    }
    
    // MARK: - File Lookup
    
    private func findURL(for name: String) -> URL? {
        let extensions = ["wav", "mp3", "m4a", "caf", "aac"]
        var variations: [String] = [name]
        
        if name.hasSuffix("0") {
            let base = String(name.dropLast())
            if !base.isEmpty {
                variations.append(base)
            }
        } else {
            variations.append("\(name)0")
        }
        
        let subdirectories = ["Sound/Music", "Sound/SFX", "Game/Sound/Music", "Game/Sound/SFX", ""]
        
        for variation in variations {
            for ext in extensions {
                for sub in subdirectories {
                    if let url = Bundle.main.url(forResource: variation, withExtension: ext, subdirectory: sub.isEmpty ? nil : sub) {
                        return url
                    }
                }
            }
        }
        
        // Recursive fallback in main bundle
        if let resourcePath = Bundle.main.resourcePath {
            let fm = FileManager.default
            if let enumerator = fm.enumerator(atPath: resourcePath) {
                while let relativePath = enumerator.nextObject() as? String {
                    let filename = (relativePath as NSString).lastPathComponent
                    for variation in variations {
                        for ext in extensions {
                            if filename.lowercased() == "\(variation).\(ext)".lowercased() {
                                return URL(fileURLWithPath: (resourcePath as NSString).appendingPathComponent(relativePath))
                            }
                        }
                    }
                }
            }
        }
        
        return nil
    }
    
    // MARK: - Music Management
    
    @discardableResult
    func playMusic(named name: String) -> Bool {
        // If the requested music is already playing, do nothing to allow continuous play
        if currentMusicName == name, let player = musicPlayer, player.isPlaying {
            return true
        }
        
        guard let url = findURL(for: name) else {
            print("[AudioManager] Music file not found for: \(name)")
            return false
        }
        
        do {
            musicPlayer?.stop()
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1 // Loop indefinitely
            player.prepareToPlay()
            player.play()
            musicPlayer = player
            currentMusicName = name
            print("[AudioManager] Playing music: \(name) from \(url.lastPathComponent)")
            return true
        } catch {
            print("[AudioManager] Error playing music '\(name)': \(error)")
            return false
        }
    }
    
    func stopMusic() {
        musicPlayer?.stop()
        musicPlayer = nil
        currentMusicName = nil
    }
    
    // MARK: - SFX Management
    
    func playSFX(named name: String) {
        guard let url = findURL(for: name) else {
            print("[AudioManager] SFX file not found for: \(name)")
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = 0 // Play once
            player.prepareToPlay()
            player.play()
            
            sfxPlayers.removeAll { !$0.isPlaying }
            sfxPlayers.append(player)
            print("[AudioManager] Played SFX: \(name) from \(url.lastPathComponent)")
        } catch {
            print("[AudioManager] Error playing SFX '\(name)': \(error)")
        }
    }
    
    // MARK: - Screen Music Updates
    
    func updateMusic(for screen: AppFlowViewModel.Screen) {
        switch screen {
        case .gameplay:
            playMusic(named: "gameplay0")
        case .congratulations:
            // Prioritize congrats0 first, fallback to onboarding0 if congrats0 is not available
            if !playMusic(named: "congrats0") {
                playMusic(named: "onboarding0")
            }
        case .splash, .storyline, .map, .goal, .levelTransition, .flowerReveal:
            playMusic(named: "onboarding0")
        }
    }
}
