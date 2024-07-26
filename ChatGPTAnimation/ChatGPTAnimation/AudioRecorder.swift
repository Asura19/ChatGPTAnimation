//
//  AudioRecorder.swift
//  OpenAIUX
//
//  Created by phoenix on 2024/5/27.
//

import Foundation
import AVFoundation

class AudioRecorder {
    var avAudioRecorder: AVAudioRecorder
    
    init() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatAppleLossless),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            avAudioRecorder = try AVAudioRecorder(url: Self.audioFileURL, settings: settings)
            avAudioRecorder.isMeteringEnabled = true
            avAudioRecorder.prepareToRecord()
        } catch {
            fatalError("Failed to setup audio recorder: \(error)")
        }
    }
    
    static var audioFileURL: URL {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory.appendingPathComponent("recording.m4a")
    }
    
    var normalizedValue: Float {
        avAudioRecorder.updateMeters()
        let averagePower = avAudioRecorder.averagePower(forChannel: 0)
        return pow(10, averagePower / 40)
    }
    
    func record() {
        avAudioRecorder.record()
    }
    
    func pause() {
        avAudioRecorder.pause()
    }
    
    func stop() {
        avAudioRecorder.stop()
    }
}
