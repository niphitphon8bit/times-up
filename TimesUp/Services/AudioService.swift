import AVFoundation
import AudioToolbox

final class AudioService {
    static let shared = AudioService()
    private var audioPlayer: AVAudioPlayer?
    private var isPlaying = false

    private init() {
        configureAudioSession()
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }

    func startAlarmSound() {
        isPlaying = true

        guard let url = Bundle.main.url(forResource: "alarm_sound", withExtension: "caf") else {
            startSystemSound()
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.volume = 1.0
            audioPlayer?.play()
        } catch {
            startSystemSound()
        }
    }

    private func startSystemSound() {
        playSystemAlert()
    }

    private func playSystemAlert() {
        guard isPlaying else { return }
        AudioServicesPlayAlertSound(SystemSoundID(1005))
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.playSystemAlert()
        }
    }

    func stopAlarmSound() {
        isPlaying = false
        audioPlayer?.stop()
        audioPlayer = nil
    }
}
