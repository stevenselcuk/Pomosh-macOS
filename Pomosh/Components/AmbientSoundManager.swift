//
//  AmbientSoundManager.swift
//  Pomosh
//

import AVFoundation
import SwiftUI

enum AmbientSound: String, CaseIterable, Identifiable {
    case none       = "None"
    case rain       = "Rain"
    case cafe       = "Café"
    case forest     = "Forest"
    case whiteNoise = "White Noise"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .none:       return "speaker.slash"
        case .rain:       return "cloud.rain"
        case .cafe:       return "cup.and.saucer"
        case .forest:     return "leaf"
        case .whiteNoise: return "waveform"
        }
    }
}

class AmbientSoundManager: ObservableObject {
    static let shared = AmbientSoundManager()

    private var engine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    private var eqNode: AVAudioUnitEQ?

    @Published var currentSound: AmbientSound = .none
    @Published var volume: Float = 0.25 {
        didSet { playerNode?.volume = volume }
    }

    private init() {}

    func play(_ sound: AmbientSound) {
        stop()
        currentSound = sound
        guard sound != .none else { return }
        playSynthetic(sound)
    }

    func stop() {
        playerNode?.stop()
        engine?.stop()
        engine = nil
        playerNode = nil
        eqNode = nil
        currentSound = .none
    }

    func pauseForBreak() {
        guard let node = playerNode else { return }
        let current = node.volume
        // Fade down to 30% over 1.5s
        let steps = 30
        for i in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * (1.5 / Double(steps))) {
                node.volume = current - (current * 0.7) * (Float(i) / Float(steps))
            }
        }
    }

    func resumeForWork() {
        guard let node = playerNode else { return }
        let target = volume
        let steps = 30
        for i in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * (1.5 / Double(steps))) {
                node.volume = target * (Float(i) / Float(steps))
            }
        }
    }

    // MARK: - Synthesis

    private func playSynthetic(_ sound: AmbientSound) {
        let sampleRate: Double = 44100
        let bufferSeconds: Double = 6.0
        let bufferSize = AVAudioFrameCount(sampleRate * bufferSeconds)

        let audioEngine = AVAudioEngine()
        let node = AVAudioPlayerNode()
        let eq = AVAudioUnitEQ(numberOfBands: 3)

        audioEngine.attach(node)
        audioEngine.attach(eq)

        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2),
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: bufferSize) else { return }
        buffer.frameLength = bufferSize

        configureBands(eq, for: sound)

        audioEngine.connect(node, to: eq, format: format)
        audioEngine.connect(eq, to: audioEngine.mainMixerNode, format: format)

        fillBuffer(buffer, sound: sound, sampleRate: sampleRate)

        node.scheduleBuffer(buffer, at: nil, options: .loops)

        do {
            try audioEngine.start()
            node.play()
            node.volume = volume
            self.engine = audioEngine
            self.playerNode = node
            self.eqNode = eq
        } catch {
            print("AmbientSoundManager error: \(error)")
        }
    }

    private func configureBands(_ eq: AVAudioUnitEQ, for sound: AmbientSound) {
        switch sound {
        case .rain:
            // Gentle high-pass to remove deep rumble, soft shelf around 3kHz
            eq.bands[0].filterType = .highPass
            eq.bands[0].frequency = 200
            eq.bands[0].bypass = false

            eq.bands[1].filterType = .parametric
            eq.bands[1].frequency = 3000
            eq.bands[1].bandwidth = 2.5
            eq.bands[1].gain = 2
            eq.bands[1].bypass = false

            eq.bands[2].filterType = .lowPass
            eq.bands[2].frequency = 9000
            eq.bands[2].bypass = false

        case .cafe:
            // Very soft warm mid, hard low-pass for muffled café feel
            eq.bands[0].filterType = .highPass
            eq.bands[0].frequency = 100
            eq.bands[0].bypass = false

            eq.bands[1].filterType = .parametric
            eq.bands[1].frequency = 600
            eq.bands[1].bandwidth = 2.0
            eq.bands[1].gain = 2
            eq.bands[1].bypass = false

            eq.bands[2].filterType = .lowPass
            eq.bands[2].frequency = 2500
            eq.bands[2].bypass = false

        case .forest:
            // Cut lows, gentle presence around 2kHz, soft top-end
            eq.bands[0].filterType = .highPass
            eq.bands[0].frequency = 200
            eq.bands[0].bypass = false

            eq.bands[1].filterType = .parametric
            eq.bands[1].frequency = 2000
            eq.bands[1].bandwidth = 3.0
            eq.bands[1].gain = 2
            eq.bands[1].bypass = false

            eq.bands[2].filterType = .lowPass
            eq.bands[2].frequency = 6000
            eq.bands[2].bypass = false

        case .whiteNoise:
            eq.bands[0].bypass = true
            eq.bands[1].bypass = true
            eq.bands[2].bypass = true

        default:
            eq.bands[0].bypass = true
            eq.bands[1].bypass = true
            eq.bands[2].bypass = true
        }
    }

    private func fillBuffer(_ buffer: AVAudioPCMBuffer, sound: AmbientSound, sampleRate: Double) {
        let count = Int(buffer.frameLength)
        guard let L = buffer.floatChannelData?[0],
              let R = buffer.floatChannelData?[1] else { return }

        switch sound {
        case .rain:
            // Brown noise — smooth, like distant rain on a window
            var runningL: Float = 0
            var runningR: Float = 0
            for i in 0..<count {
                runningL = (runningL + Float.random(in: -0.04...0.04)) * 0.998
                runningR = (runningR + Float.random(in: -0.04...0.04)) * 0.998
                L[i] = max(-0.12, min(0.12, runningL))
                R[i] = max(-0.12, min(0.12, runningR))
            }

        case .cafe:
            // Pink noise, very low amplitude — like a muffled background murmur
            var b0L: Float=0, b1L: Float=0, b2L: Float=0
            var b0R: Float=0, b1R: Float=0, b2R: Float=0
            for i in 0..<count {
                let wL = Float.random(in: -1...1)
                let wR = Float.random(in: -1...1)
                b0L = 0.99886*b0L + wL*0.0555179; b0R = 0.99886*b0R + wR*0.0555179
                b1L = 0.99332*b1L + wL*0.0750759; b1R = 0.99332*b1R + wR*0.0750759
                b2L = 0.96900*b2L + wL*0.1538520; b2R = 0.96900*b2R + wR*0.1538520
                L[i] = (b0L+b1L+b2L+wL*0.5362) * 0.045
                R[i] = (b0R+b1R+b2R+wR*0.5362) * 0.045
            }

        case .forest:
            // Pink noise with slow wind breath (0.05 Hz), very gentle
            var b0L: Float=0, b1L: Float=0
            var b0R: Float=0, b1R: Float=0
            for i in 0..<count {
                let wL = Float.random(in: -1...1)
                let wR = Float.random(in: -1...1)
                b0L = 0.99886*b0L + wL*0.0555179; b0R = 0.99886*b0R + wR*0.0555179
                b1L = 0.99332*b1L + wL*0.0750759; b1R = 0.99332*b1R + wR*0.0750759
                let wind = 0.7 + 0.3 * sin(2 * Float.pi * 0.05 * Float(i) / Float(sampleRate))
                L[i] = (b0L + b1L + wL*0.15) * 0.038 * wind
                R[i] = (b0R + b1R + wR*0.15) * 0.038 * wind
            }

        default:
            // Pure white noise, very soft
            for i in 0..<count {
                L[i] = Float.random(in: -0.018...0.018)
                R[i] = Float.random(in: -0.018...0.018)
            }
        }
    }
}
