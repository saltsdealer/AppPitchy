//
//  PitchDetector.swift
//  pitchy
//
//  Created by firesalts on 7/17/24.
//

import Foundation
import AVFoundation
import Accelerate

protocol PitchDetectorDelegate: AnyObject {
    func player(_ player: PitchDetector, didGenerateSpectrum spectrum: Float)
}


class PitchDetector: ObservableObject {
    
    var audioPlayer: AVAudioPlayer?
    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    weak var delegate: PitchDetectorDelegate?
    
    private var fftSize: Int = 4096
    private lazy var fftSetup = vDSP_create_fftsetup(vDSP_Length(Int(round(log2(Double(fftSize))))), FFTRadix(kFFTRadix2))
    @Published var frequencyData: FrequencyData?
    
    public var bufferSize: Int? {
        didSet {
            if let bufferSize = self.bufferSize {
                analyzer = RealtimeAnalyzer(fftSize: bufferSize)
                
                engine.mainMixerNode.removeTap(onBus: 0)
                engine.mainMixerNode.installTap(onBus: 0, bufferSize: AVAudioFrameCount(bufferSize), format: nil, block: {[weak self](buffer, when) in
                    guard let strongSelf = self else { return }
                    if !strongSelf.player.isPlaying { return }
                    buffer.frameLength = AVAudioFrameCount(bufferSize)
                    //let freq = strongSelf.analyzer.analyseForPitch(with: buffer)
                    //let freq = strongSelf.analyzer.analyse(with: buffer)
                    let freq = strongSelf.analyzer.analyseSimpler(with: buffer)
                    //if freq != 0.0 { print(freq ?? "default") }
                    if strongSelf.delegate != nil {
                        strongSelf.delegate!.player(strongSelf, didGenerateSpectrum: freq)
                    }
                    if freq != 0.0{
                        DispatchQueue.main.async {
                            strongSelf.frequencyData?.frequencies.append(freq)
                        }
                    }
                })
            }
        }
    }
    
    public var analyzer: RealtimeAnalyzer!
    
    private var audioFile: AVAudioFile?
    private var currentPlaybackTime: TimeInterval = 0.0
    
    init(bufferSize: Int = 2048) {
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: nil)
        engine.prepare()
        try! engine.start()
    
        defer {
            self.bufferSize = bufferSize
        }
    }
    
    
    // test method, should not be called in normal settings
    func playAudio(forResource: String, ofType: String) {
        let path = Bundle.main.path(forResource: forResource, ofType: ofType)!
        let url = URL(fileURLWithPath: path)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Something wrong with loading the file")
        }
    }
    
    
    func play(fileName: String, fileExtension: String) {
        guard let audioFileURL = Bundle.main.url(forResource: fileName, withExtension: fileExtension),
              let audioFile = try? AVAudioFile(forReading: audioFileURL) else {
            print("Failed to load audio file")
            return
        }
        self.audioFile = audioFile
        player.stop()
        
        // Calculate playback start time
        let playbackFramePosition = AVAudioFramePosition(currentPlaybackTime * audioFile.processingFormat.sampleRate)
        let frameCount = AVAudioFrameCount(audioFile.length - playbackFramePosition)
        
//        player.scheduleFile(audioFile, at: nil) { [weak self] in
//            DispatchQueue.main.async {
//                self?.stop()
//            }
//        }
        // Schedule playback
        player.scheduleSegment(audioFile, startingFrame: playbackFramePosition, frameCount: frameCount, at: nil) { [weak self] in
            DispatchQueue.main.async {
                self?.stop()
            }
        }

        
        player.play()
       
    }
    
    func play(fileURL: URL) {
        guard let audioFile = try? AVAudioFile(forReading: fileURL) else {
            print("Failed to load audio file at URL: \(fileURL.path)")
            return
        }
        self.audioFile = audioFile
        player.stop()
        
        // Calculate playback start time
        let playbackFramePosition = AVAudioFramePosition(currentPlaybackTime * audioFile.processingFormat.sampleRate)
        let frameCount = AVAudioFrameCount(audioFile.length - playbackFramePosition)
        
        // Schedule playback
        player.scheduleSegment(audioFile, startingFrame: playbackFramePosition, frameCount: frameCount, at: nil) { [weak self] in
            DispatchQueue.main.async {
                self?.stop()
            }
        }

        player.play()
    }
    
    func stop(){
//        player.stop()
//        // Remove the tap from the main mixer node
//        engine.mainMixerNode.removeTap(onBus: 0)
//        // Stop the audio engine
//        if engine.isRunning {
//            engine.stop()
//        }
        guard player.isPlaying else { return }

        if let lastRenderTime = player.lastRenderTime,
           let playerTime = player.playerTime(forNodeTime: lastRenderTime) {
            // Calculate the current playback time in seconds
            let sampleRate = audioFile?.processingFormat.sampleRate ?? 44100
            currentPlaybackTime += Double(playerTime.sampleTime) / sampleRate
        }
        player.stop()
    }
    
    func reset() {
        stop()
        currentPlaybackTime = 0.0
    }
}

