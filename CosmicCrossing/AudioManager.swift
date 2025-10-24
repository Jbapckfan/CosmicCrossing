import AVFoundation
import SpriteKit

class AudioManager {
    static let shared = AudioManager()

    private var backgroundMusicPlayer: AVAudioPlayer?
    private var soundEffectPlayers: [String: AVAudioPlayer] = [:]

    private var isMusicEnabled = true
    private var areSoundEffectsEnabled = true

    private init() {
        setupAudioSession()
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }

    // MARK: - Music

    func playBackgroundMusic(named fileName: String, volume: Float = 0.5) {
        guard isMusicEnabled else { return }

        guard let url = Bundle.main.url(forResource: fileName, withExtension: nil) else {
            print("Background music file not found: \(fileName)")
            return
        }

        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundMusicPlayer?.numberOfLoops = -1 // Loop forever
            backgroundMusicPlayer?.volume = volume
            backgroundMusicPlayer?.prepareToPlay()
            backgroundMusicPlayer?.play()
        } catch {
            print("Could not play background music: \(error)")
        }
    }

    func stopBackgroundMusic(fadeOut: Bool = true) {
        if fadeOut {
            // Fade out over 1 second
            guard let player = backgroundMusicPlayer else { return }
            let fadeTime: TimeInterval = 1.0
            let steps = 20
            let volumeDecrement = player.volume / Float(steps)

            var currentStep = 0
            Timer.scheduledTimer(withTimeInterval: fadeTime / Double(steps), repeats: true) { timer in
                currentStep += 1
                player.volume -= volumeDecrement

                if currentStep >= steps {
                    timer.invalidate()
                    player.stop()
                }
            }
        } else {
            backgroundMusicPlayer?.stop()
        }
    }

    func pauseBackgroundMusic() {
        backgroundMusicPlayer?.pause()
    }

    func resumeBackgroundMusic() {
        guard isMusicEnabled else { return }
        backgroundMusicPlayer?.play()
    }

    func setMusicVolume(_ volume: Float) {
        backgroundMusicPlayer?.volume = max(0.0, min(1.0, volume))
    }

    // MARK: - Sound Effects

    func playSoundEffect(named fileName: String, volume: Float = 1.0) {
        guard areSoundEffectsEnabled else { return }

        guard let url = Bundle.main.url(forResource: fileName, withExtension: nil) else {
            print("Sound effect file not found: \(fileName)")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = volume
            player.prepareToPlay()
            player.play()

            // Keep reference to prevent deallocation
            soundEffectPlayers[fileName] = player

            // Remove reference after playing
            DispatchQueue.main.asyncAfter(deadline: .now() + player.duration) {
                self.soundEffectPlayers.removeValue(forKey: fileName)
            }
        } catch {
            print("Could not play sound effect: \(error)")
        }
    }

    // MARK: - SpriteKit Actions (Alternative for quick SFX)

    func playSKSound(named fileName: String, on node: SKNode, volume: Float = 1.0) {
        guard areSoundEffectsEnabled else { return }

        let playAction = SKAction.playSoundFileNamed(fileName, waitForCompletion: false)
        let volumeAction = SKAction.changeVolume(to: volume, duration: 0)
        node.run(SKAction.group([volumeAction, playAction]))
    }

    // MARK: - Settings

    func toggleMusic() {
        isMusicEnabled.toggle()
        if isMusicEnabled {
            resumeBackgroundMusic()
        } else {
            pauseBackgroundMusic()
        }
    }

    func toggleSoundEffects() {
        areSoundEffectsEnabled.toggle()
    }

    func setMusicEnabled(_ enabled: Bool) {
        isMusicEnabled = enabled
        if !enabled {
            stopBackgroundMusic()
        }
    }

    func setSoundEffectsEnabled(_ enabled: Bool) {
        areSoundEffectsEnabled = enabled
    }
}

// MARK: - Sound Effect Names
extension AudioManager {
    enum SoundEffect {
        static let jump = "jump.wav"
        static let shoot = "shoot.wav"
        static let explosion = "explosion.wav"
        static let hit = "hit.wav"
        static let collect = "collect.wav"
        static let levelComplete = "level_complete.wav"
        static let gameOver = "game_over.wav"
        static let powerUp = "powerup.wav"
    }

    enum Music {
        static let gameplay = "background_music.mp3"
        static let menu = "menu_music.mp3"
    }
}
