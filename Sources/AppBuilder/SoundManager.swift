import Foundation
import AVFoundation
import UIKit

/// High-performance offline sound synthesizer & haptics engine for App Builder.
/// Generates authentic arcade, 8-bit, and UI sounds on the fly using standard PCM WAV buffers.
@MainActor
final class SoundManager {
    static let shared = SoundManager()

    private var audioPlayers: [SoundEffectType: AVAudioPlayer] = [:]

    private init() {
        configureAudioSession()
        preloadSounds()
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            // Ambient fallback
        }
    }

    private func preloadSounds() {
        for effect in SoundEffectType.allCases where effect != .none {
            if let data = generateWAV(for: effect) {
                if let player = try? AVAudioPlayer(data: data) {
                    player.prepareToPlay()
                    audioPlayers[effect] = player
                }
            }
        }
    }

    func play(_ sound: SoundEffectType) {
        guard sound != .none else { return }

        if let player = audioPlayers[sound] {
            player.currentTime = 0
            player.play()
        } else if let data = generateWAV(for: sound), let player = try? AVAudioPlayer(data: data) {
            player.play()
            audioPlayers[sound] = player
        }
    }

    func playHaptic(_ type: HapticType) {
        switch type {
        case .none:
            break
        case .light:
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
        case .medium:
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
        case .heavy:
            let impact = UIImpactFeedbackGenerator(style: .heavy)
            impact.impactOccurred()
        case .success:
            let notification = UINotificationFeedbackGenerator()
            notification.notificationOccurred(.success)
        case .warning:
            let notification = UINotificationFeedbackGenerator()
            notification.notificationOccurred(.warning)
        case .error:
            let notification = UINotificationFeedbackGenerator()
            notification.notificationOccurred(.error)
        case .selection:
            let selection = UISelectionFeedbackGenerator()
            selection.selectionChanged()
        }
    }

    // MARK: - Waveform Synthesis

    private func generateWAV(for sound: SoundEffectType) -> Data? {
        let sampleRate: Double = 22050
        var samples: [Float] = []

        switch sound {
        case .coin:
            // 2-tone chime: B5 (987Hz) then E6 (1318Hz)
            let note1Len = Int(sampleRate * 0.08)
            let note2Len = Int(sampleRate * 0.28)
            for i in 0..<note1Len {
                let t = Double(i) / sampleRate
                let env = 1.0 - (Double(i) / Double(note1Len)) * 0.3
                let s = sin(2.0 * .pi * 987.77 * t) * env
                samples.append(Float(s * 0.4))
            }
            for i in 0..<note2Len {
                let t = Double(i) / sampleRate
                let env = exp(-t * 10.0)
                let s = sin(2.0 * .pi * 1318.51 * t) * env
                samples.append(Float(s * 0.45))
            }

        case .laser:
            // Downward pitch bend from 1200Hz to 120Hz
            let length = Int(sampleRate * 0.16)
            var phase: Double = 0
            for i in 0..<length {
                let progress = Double(i) / Double(length)
                let freq = 1200.0 * (1.0 - progress) + 120.0
                phase += 2.0 * .pi * freq / sampleRate
                let env = 1.0 - progress
                let s = sin(phase) * env
                samples.append(Float(s * 0.4))
            }

        case .jump:
            // Upward frequency sweep 200Hz -> 650Hz
            let length = Int(sampleRate * 0.18)
            var phase: Double = 0
            for i in 0..<length {
                let progress = Double(i) / Double(length)
                let freq = 200.0 + (450.0 * progress * progress)
                phase += 2.0 * .pi * freq / sampleRate
                let env = 1.0 - (progress * 0.5)
                let s = (sin(phase) + 0.3 * sin(phase * 2)) * env
                samples.append(Float(s * 0.35))
            }

        case .pop:
            // Short sine transient
            let length = Int(sampleRate * 0.07)
            for i in 0..<length {
                let t = Double(i) / sampleRate
                let freq = 420.0 - (t * 2000.0)
                let env = exp(-t * 50.0)
                let s = sin(2.0 * .pi * max(100.0, freq) * t) * env
                samples.append(Float(s * 0.5))
            }

        case .powerup:
            // Rapid 4-note ascending chord
            let notes: [Double] = [523.25, 659.25, 783.99, 1046.50] // C5, E5, G5, C6
            let noteLen = Int(sampleRate * 0.07)
            for freq in notes {
                for i in 0..<noteLen {
                    let t = Double(i) / sampleRate
                    let env = 1.0 - (Double(i) / Double(noteLen) * 0.4)
                    let s = sin(2.0 * .pi * freq * t) * env
                    samples.append(Float(s * 0.35))
                }
            }

        case .victory:
            // Fanfare arpeggio
            let fanfare: [(freq: Double, dur: Double)] = [
                (523.25, 0.09), (659.25, 0.09), (783.99, 0.09), (1046.50, 0.32)
            ]
            for (freq, dur) in fanfare {
                let count = Int(sampleRate * dur)
                for i in 0..<count {
                    let t = Double(i) / sampleRate
                    let env = dur > 0.2 ? exp(-t * 3.5) : 0.9
                    let s = (sin(2.0 * .pi * freq * t) + 0.25 * sin(2.0 * .pi * freq * 2.0 * t)) * env
                    samples.append(Float(s * 0.38))
                }
            }

        case .failure:
            // Descending sad tones
            let failNotes: [Double] = [349.23, 329.63, 311.13, 277.18]
            let count = Int(sampleRate * 0.12)
            for freq in failNotes {
                for i in 0..<count {
                    let t = Double(i) / sampleRate
                    let env = 1.0 - (Double(i) / Double(count) * 0.6)
                    let s = (sin(2.0 * .pi * freq * t) + 0.4 * sin(2.0 * .pi * freq * 0.5 * t)) * env
                    samples.append(Float(s * 0.35))
                }
            }

        case .click:
            // Crisp 10ms click
            let length = Int(sampleRate * 0.018)
            for i in 0..<length {
                let t = Double(i) / sampleRate
                let env = exp(-t * 250.0)
                let s = sin(2.0 * .pi * 1400.0 * t) * env
                samples.append(Float(s * 0.4))
            }

        case .tap:
            let length = Int(sampleRate * 0.025)
            for i in 0..<length {
                let t = Double(i) / sampleRate
                let env = exp(-t * 180.0)
                let s = sin(2.0 * .pi * 320.0 * t) * env
                samples.append(Float(s * 0.35))
            }

        case .chime:
            let length = Int(sampleRate * 0.4)
            for i in 0..<length {
                let t = Double(i) / sampleRate
                let env = exp(-t * 6.0)
                let s = (sin(2.0 * .pi * 1760.0 * t) + 0.5 * sin(2.0 * .pi * 2637.0 * t) + 0.25 * sin(2.0 * .pi * 3520.0 * t)) * env
                samples.append(Float(s * 0.3))
            }

        case .synth:
            let length = Int(sampleRate * 0.3)
            for i in 0..<length {
                let t = Double(i) / sampleRate
                let env = exp(-t * 4.0)
                let s = sin(2.0 * .pi * 440.0 * t) * env
                samples.append(Float(s * 0.4))
            }

        case .none:
            return nil
        }

        return createWAVFile(samples: samples, sampleRate: Int(sampleRate))
    }

    private func createWAVFile(samples: [Float], sampleRate: Int) -> Data {
        var data = Data()
        let numChannels: UInt16 = 1
        let bitsPerSample: UInt16 = 16
        let byteRate = UInt32(sampleRate * Int(numChannels) * Int(bitsPerSample / 8))
        let blockAlign = UInt16(numChannels * (bitsPerSample / 8))
        let dataSize = UInt32(samples.count * 2)
        let chunkSize = 36 + dataSize

        // RIFF header
        data.append(contentsOf: "RIFF".utf8)
        data.append(withUnsafeBytes(of: chunkSize.littleEndian) { Data($0) })
        data.append(contentsOf: "WAVE".utf8)

        // fmt chunk
        data.append(contentsOf: "fmt ".utf8)
        data.append(withUnsafeBytes(of: UInt32(16).littleEndian) { Data($0) }) // subchunk1size
        data.append(withUnsafeBytes(of: UInt16(1).littleEndian) { Data($0) })  // PCM
        data.append(withUnsafeBytes(of: numChannels.littleEndian) { Data($0) })
        data.append(withUnsafeBytes(of: UInt32(sampleRate).littleEndian) { Data($0) })
        data.append(withUnsafeBytes(of: byteRate.littleEndian) { Data($0) })
        data.append(withUnsafeBytes(of: blockAlign.littleEndian) { Data($0) })
        data.append(withUnsafeBytes(of: bitsPerSample.littleEndian) { Data($0) })

        // data chunk
        data.append(contentsOf: "data".utf8)
        data.append(withUnsafeBytes(of: dataSize.littleEndian) { Data($0) })

        for sample in samples {
            let clamped = max(-1.0, min(1.0, sample))
            let int16Sample = Int16(clamped * 32767.0)
            data.append(withUnsafeBytes(of: int16Sample.littleEndian) { Data($0) })
        }

        return data
    }
}
