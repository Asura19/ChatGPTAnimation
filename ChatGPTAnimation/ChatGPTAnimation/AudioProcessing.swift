//
//  AudioProcessing.swift
//  SwiftChartsAudioVisualizer
//
//  Created by Vinicius Nakamura on 22/07/22.
//

import AVFoundation
import Accelerate

/**
 - I'm no expert in audio processing. What I did here, I learnt from this Article:
   - __Audio Visualization in Swift Using Metal and Accelerate__
   - _By Alex Barbulescu_
   - https://betterprogramming.pub/audio-visualization-in-swift-using-metal-accelerate-part-1-390965c095d7
 
 This works for the purposes of this demo, but if you want to add a sound visualizer to a real app,
 consider using something more robust, like the [AudioKit](https://audiokit.io/) framework.
 */
//class AudioProcessing {
//    static var shared: AudioProcessing = .init()
//    
//    private let engine = AVAudioEngine()
//    private let bufferSize = 1024
//    
//    let player = AVAudioPlayerNode()
//    var fftMagnitudes: [Float] = []
//    
//    init() {
//        _ = engine.mainMixerNode
//        
//        engine.prepare()
//        try! engine.start()
//        
//        /**
//         - Music: Moonlight Sonata Op. 27 No. 2 - III. Presto
//         - Performed by: Paul Pitman
//         - https://musopen.org/music/2547-piano-sonata-no-14-in-c-sharp-minor-moonlight-sonata-op-27-no-2/
//         */
//        let audioFile = try! AVAudioFile(
//            forReading: Bundle.main.url(forResource: "music", withExtension: "mp3")!
//        )
//        let format = audioFile.processingFormat
//            
//        engine.attach(player)
//        engine.connect(player, to: engine.mainMixerNode, format: format)
//            
//        player.scheduleFile(audioFile, at: nil)
//            
//        let fftSetup = vDSP_DFT_zop_CreateSetup(
//            nil,
//            UInt(bufferSize),
//            vDSP_DFT_Direction.FORWARD
//        )
//            
//        engine.mainMixerNode.installTap(
//            onBus: 0,
//            bufferSize: UInt32(bufferSize),
//            format: nil
//        ) { [self] buffer, _ in
//            let channelData = buffer.floatChannelData?[0]
//            fftMagnitudes = fft(data: channelData!, setup: fftSetup!)
//            NSLog("\(fftMagnitudes)")
//        }
//    }
//    
//    func fft(data: UnsafeMutablePointer<Float>, setup: OpaquePointer) -> [Float] {
//        var realIn = [Float](repeating: 0, count: bufferSize)
//        var imagIn = [Float](repeating: 0, count: bufferSize)
//        var realOut = [Float](repeating: 0, count: bufferSize)
//        var imagOut = [Float](repeating: 0, count: bufferSize)
//            
//        for i in 0 ..< bufferSize {
//            realIn[i] = data[i]
//        }
//        
//        vDSP_DFT_Execute(setup, &realIn, &imagIn, &realOut, &imagOut)
//        
//        var magnitudes = [Float](repeating: 0, count: Constants.barAmount)
//        
//        realOut.withUnsafeMutableBufferPointer { realBP in
//            imagOut.withUnsafeMutableBufferPointer { imagBP in
//                var complex = DSPSplitComplex(realp: realBP.baseAddress!, imagp: imagBP.baseAddress!)
//                vDSP_zvabs(&complex, 1, &magnitudes, 1, UInt(Constants.barAmount))
//            }
//        }
//        
//        var normalizedMagnitudes = [Float](repeating: 0.0, count: Constants.barAmount)
//        var scalingFactor = Float(1)
//        vDSP_vsmul(&magnitudes, 1, &scalingFactor, &normalizedMagnitudes, 1, UInt(Constants.barAmount))
//            
//        return normalizedMagnitudes
//    }
//}
//let inputNode = audioEngine.inputNode
//        let format = inputNode.inputFormat(forBus: 0)

class AudioProcessing {
    static var shared: AudioProcessing = .init(barAmount: 4)
    
    let barAmount: Int
    
    private let engine = AVAudioEngine()
    private let bufferSize = 1024
    
    var fftMagnitudes: [Float] = []
    
    init(barAmount: Int) {
        self.barAmount = barAmount
        let inputNode = engine.inputNode
        
        engine.prepare()
        try! engine.start()
        
        let fftSetup = vDSP_DFT_zop_CreateSetup(
            nil,
            UInt(bufferSize),
            vDSP_DFT_Direction.FORWARD
        )
        
        let inputFormat = inputNode.inputFormat(forBus: 0)
        inputNode.installTap(
            onBus: 0,
            bufferSize: UInt32(bufferSize),
            format: inputFormat
        ) { [self] buffer, _ in
            let channelData = buffer.floatChannelData?[0]
            fftMagnitudes = fft(data: channelData!, setup: fftSetup!)
//            NSLog("\(fftMagnitudes)")
        }
    }
    
    func fft(data: UnsafeMutablePointer<Float>, setup: OpaquePointer) -> [Float] {
        var realIn = [Float](repeating: 0, count: bufferSize)
        var imagIn = [Float](repeating: 0, count: bufferSize)
        var realOut = [Float](repeating: 0, count: bufferSize)
        var imagOut = [Float](repeating: 0, count: bufferSize)
        
        for i in 0 ..< bufferSize {
            realIn[i] = data[i]
        }
        
        vDSP_DFT_Execute(setup, &realIn, &imagIn, &realOut, &imagOut)
        
        var magnitudes = [Float](repeating: 0, count: barAmount)
        
        realOut.withUnsafeMutableBufferPointer { realBP in
            imagOut.withUnsafeMutableBufferPointer { imagBP in
                var complex = DSPSplitComplex(realp: realBP.baseAddress!, imagp: imagBP.baseAddress!)
                vDSP_zvabs(&complex, 1, &magnitudes, 1, UInt(barAmount))
            }
        }
        
        var normalizedMagnitudes = [Float](repeating: 0.0, count: barAmount)
        var scalingFactor = Float(1)
        vDSP_vsmul(&magnitudes, 1, &scalingFactor, &normalizedMagnitudes, 1, UInt(barAmount))
        
        return normalizedMagnitudes
    }
    
    func start() {
        try! engine.start()
    }
    
    func stop() {
        engine.stop()
    }
}



class AudioProcessing2 {
//    static var shared: AudioProcessing2 = .init(amount: 4)
    
    let amount: Int
    
    private let bufferSize = 1024
    
    var fftMagnitudes: [Float] = []

    var volume: Double = 0 {
        didSet {
            let floatSample = Float(volume)
            
            let floatPointer = UnsafeMutablePointer<Float>.allocate(capacity: bufferSize)
            defer {
                floatPointer.deallocate()
            }
            
            for i in 0..<bufferSize {
                floatPointer[i] = floatSample
            }
            let fftSetup = vDSP_DFT_zop_CreateSetup(
                nil,
                UInt(bufferSize),
                vDSP_DFT_Direction.FORWARD
            )
            
            fft(data: floatPointer, setup: fftSetup!)
        }
    }
    
    init(amount: Int = 4) {
        self.amount = amount
    }
    
    @discardableResult
    func fft(data: UnsafeMutablePointer<Float>, setup: OpaquePointer) -> [Float] {
        var realIn = [Float](repeating: 0, count: bufferSize)
        var imagIn = [Float](repeating: 0, count: bufferSize)
        var realOut = [Float](repeating: 0, count: bufferSize)
        var imagOut = [Float](repeating: 0, count: bufferSize)
        
        for i in 0 ..< bufferSize {
            realIn[i] = data[i]
        }
        
        vDSP_DFT_Execute(setup, &realIn, &imagIn, &realOut, &imagOut)
        
        var magnitudes = [Float](repeating: 0, count: amount)
        
        realOut.withUnsafeMutableBufferPointer { realBP in
            imagOut.withUnsafeMutableBufferPointer { imagBP in
                var complex = DSPSplitComplex(realp: realBP.baseAddress!, imagp: imagBP.baseAddress!)
                vDSP_zvabs(&complex, 1, &magnitudes, 1, UInt(amount))
            }
        }
        
        var normalizedMagnitudes = [Float](repeating: 0.0, count: amount)
        var scalingFactor = Float(1)
        vDSP_vsmul(&magnitudes, 1, &scalingFactor, &normalizedMagnitudes, 1, UInt(amount))
        
        return normalizedMagnitudes
    }
}
