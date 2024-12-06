//
//  RealtimeAnalyzer.swift
//  pitchy
//
//  Created by firesalts on 7/27/24.
//
import Foundation
import AVFoundation
import Accelerate

class RealtimeAnalyzer {
    private var fftSize: Int = 0
    private lazy var fftSetup = vDSP_create_fftsetup(vDSP_Length(Int(round(log2(Double(fftSize))))), FFTRadix(kFFTRadix2))

    // Define the human voice frequency range
    public var voiceFrequencyRange: (start: Float, end: Float) = (300, 3400)

    init(fftSize: Int) {
        self.fftSize = fftSize
        self.sampleRate = 44100.0
        self.inputFrameSize = 4096
    }
    
    deinit {
        vDSP_destroy_fftsetup(fftSetup)
    }
    
    
    var sampleRate: Double
    var inputFrameSize: Int
    
    
    func analyseSimpler (with buffer: AVAudioPCMBuffer) -> Float {
        guard var channelsAmplitudes = performFFT(buffer) else { return 0.0 }
        
        let magnitudes = calculateMagnitudeSpectrum(splitComplex: &channelsAmplitudes)
        
        let vocalMagnitudes = getVocalFrequencies(magnitudes: magnitudes)
        
        let frequency = getFrequencyFromMagnitudes(magnitudes: vocalMagnitudes)
        
        return Float(frequency)
        
    }
    

    private func fft(_ buffer: AVAudioPCMBuffer) -> [Float]? {
        guard let floatChannelData = buffer.floatChannelData else { return nil }
        
        let channelCount = Int(buffer.format.channelCount)
        let isInterleaved = buffer.format.isInterleaved

        var amplitudes = [Float](repeating: 0.0, count: fftSize / 2)
        var frequencies = [Float](repeating: 0.0, count: fftSize / 2)
        
        let nyquistFrequency = sampleRate / 2.0
        let frequencyResolution = Float(nyquistFrequency) / Float(fftSize / 2)
        for i in 0..<(fftSize / 2) {
            frequencies[i] = Float(i) * frequencyResolution
        }

        for i in 0..<channelCount {
            let channel = floatChannelData[i]

            var window = [Float](repeating: 0, count: fftSize)
            vDSP_hann_window(&window, vDSP_Length(fftSize), Int32(vDSP_HANN_NORM))
            vDSP_vmul(channel, 1, window, 1, channel, 1, vDSP_Length(fftSize))

            var realp = [Float](repeating: 0.0, count: fftSize / 2)
            var imagp = [Float](repeating: 0.0, count: fftSize / 2)
            var fftInOut = DSPSplitComplex(realp: &realp, imagp: &imagp)
            channel.withMemoryRebound(to: DSPComplex.self, capacity: fftSize) { typeConvertedTransferBuffer in
                vDSP_ctoz(typeConvertedTransferBuffer, 2, &fftInOut, 1, vDSP_Length(fftSize / 2))
            }

            vDSP_fft_zrip(fftSetup!, &fftInOut, 1, vDSP_Length(log2(Double(fftSize))), FFTDirection(FFT_FORWARD))

            fftInOut.imagp[0] = 0
            let fftNormFactor = Float(1.0 / Float(fftSize))
            vDSP_vsmul(fftInOut.realp, 1, [fftNormFactor], fftInOut.realp, 1, vDSP_Length(fftSize / 2))
            vDSP_vsmul(fftInOut.imagp, 1, [fftNormFactor], fftInOut.imagp, 1, vDSP_Length(fftSize / 2))
            var channelAmplitudes = [Float](repeating: 0.0, count: fftSize / 2)
            vDSP_zvabs(&fftInOut, 1, &channelAmplitudes, 1, vDSP_Length(fftSize / 2))
            channelAmplitudes[0] = channelAmplitudes[0] / 2

            let maxAmplitude = channelAmplitudes.max() ?? 0.0
            if let maxIndex = channelAmplitudes.firstIndex(of: maxAmplitude) {
                return [frequencies[maxIndex]]
            }
        }
        return nil
    }
    
    
    func analyseForPitch(with buffer: AVAudioPCMBuffer) -> Float? {
        if let frequencyData = fft(buffer) {
            return frequencyData.first
        }
        return nil
    }

    private func extractVoiceFrequency(from amplitudes: [Float], sampleRate: Float) -> Float {
        let bandWidth = sampleRate / Float(fftSize)
        let startIndex = Int(voiceFrequencyRange.start / bandWidth)
        let endIndex = min(Int(voiceFrequencyRange.end / bandWidth), amplitudes.count - 1)

        let maxAmplitude = amplitudes[startIndex...endIndex].max() ?? 0
        let maxIndex = amplitudes[startIndex...endIndex].firstIndex(of: maxAmplitude) ?? 0

        return (Float(startIndex + maxIndex) * bandWidth)
    }
    
    
    func performFFT(_ buffer: AVAudioPCMBuffer) -> DSPSplitComplex? {
        guard let channelData = buffer.floatChannelData else {
            return nil
        }
        
        let channelCount = Int(buffer.format.channelCount)
        let inputFrameSize = Int(buffer.frameLength)
        
        var combinedChannelData = [Float](repeating: 0.0, count: inputFrameSize)
        
        if channelCount == 1 {
            // Single channel
            for i in 0..<inputFrameSize {
                combinedChannelData[i] = channelData[0][i]
            }
        } else if channelCount == 2 {
            // Stereo channel, calculate average
            for i in 0..<inputFrameSize {
                combinedChannelData[i] = (channelData[0][i] + channelData[1][i]) / 2.0
            }
        } else {
            // Handle more than 2 channels if needed
            // Here, we simply take the average of all channels
            for i in 0..<inputFrameSize {
                var sum: Float = 0.0
                for j in 0..<channelCount {
                    sum += channelData[j][i]
                }
                combinedChannelData[i] = sum / Float(channelCount)
            }
        }
        
        guard let fftSetup = vDSP_create_fftsetup(vDSP_Length(log2(Float(inputFrameSize))), FFTRadix(kFFTRadix2)) else {
            return nil
        }
        
        var real = [Float](repeating: 0.0, count: inputFrameSize)
        var imaginary = [Float](repeating: 0.0, count: inputFrameSize)
        var splitComplex = DSPSplitComplex(realp: &real, imagp: &imaginary)
        
        combinedChannelData.withUnsafeBufferPointer { bufferPointer in
            bufferPointer.baseAddress?.withMemoryRebound(to: DSPComplex.self, capacity: inputFrameSize) { complexBuffer in
                vDSP_ctoz(complexBuffer, 2, &splitComplex, 1, vDSP_Length(inputFrameSize / 2))
            }
        }
        
        vDSP_fft_zip(fftSetup, &splitComplex, 1, vDSP_Length(log2(Float(inputFrameSize))), FFTDirection(FFT_FORWARD))
        vDSP_destroy_fftsetup(fftSetup)
        
        return splitComplex
    }
    
    func calculateMagnitudeSpectrum(splitComplex: inout DSPSplitComplex) -> [Float] {
        var magnitudes = [Float](repeating: 0.0, count: inputFrameSize / 2)
        vDSP_zvabs(&splitComplex, 1, &magnitudes, 1, vDSP_Length(inputFrameSize / 2))
        return magnitudes
    }
    
    func getVocalFrequencies(magnitudes: [Float]) -> [Float] {
        let minVocalFrequency: Double = 60.0
        
        let maxVocalFrequency: Double = 2500.0
        var vocalMagnitudes = [Float](repeating: 0.0, count: magnitudes.count)
        
        for (index, magnitude) in magnitudes.enumerated() {
            let frequency = Double(index) * sampleRate / Double(inputFrameSize)
            if frequency >= minVocalFrequency && frequency <= maxVocalFrequency {
                vocalMagnitudes[index] = magnitude
            } else {
                vocalMagnitudes[index] = 0.0
            }
        }
        return vocalMagnitudes
    }
    
    func getFrequencyFromMagnitudes(magnitudes: [Float]) -> Double {
        if let maxFrequencyIndex = magnitudes.firstIndex(of: magnitudes.max()!) {
            let frequency = Double(maxFrequencyIndex) * sampleRate / Double(inputFrameSize)
            return frequency
        } else {
            return 0.0
        }
    }
}
