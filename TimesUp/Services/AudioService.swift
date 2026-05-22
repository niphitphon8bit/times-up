import AVFoundation
import AudioToolbox

final class AudioService {
    static let shared = AudioService()
    private var audioPlayer: AVAudioPlayer?
    private var isPlaying = false

    private init() {}

    func startAlarmSound(_ sound: AlarmSound = .classic) {
        activateAudioSession()
        isPlaying = true

        guard let url = Bundle.main.url(forResource: "alarm_sound", withExtension: "caf") else {
            playSystemAlert(sound)
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.volume = 1.0
            audioPlayer?.play()
        } catch {
            playSystemAlert(sound)
        }
    }

    private func playSystemAlert(_ sound: AlarmSound) {
        guard isPlaying else { return }
        AudioServicesPlayAlertSound(sound.systemSoundID)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.playSystemAlert(sound)
        }
    }

    func stopAlarmSound() {
        isPlaying = false
        audioPlayer?.stop()
        audioPlayer = nil
        deactivateAudioSession()
    }

    private func activateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("[AudioService] Failed to activate audio session: \(error)")
        }
    }

    private func deactivateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("[AudioService] Failed to deactivate audio session: \(error)")
        }
    }
}
