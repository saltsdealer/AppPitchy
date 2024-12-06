//
//  AudioRecorder.swift
//  pitchy
//
//  Created by firesalts on 7/11/24.
//

import Foundation
import AVFoundation

//class AudioRecorder: NSObject, ObservableObject, AVAudioRecorderDelegate {
//    @Published var recordingURL: URL?
//    private var audioRecorder: AVAudioRecorder?
//    var activeSelection: Int?
//    var completionHandler: ((URL?) -> Void)?
//    
//    func startRecording() {
//        let recordingSession = AVAudioSession.sharedInstance()
//        do {
//            try recordingSession.setCategory(.playAndRecord, mode: .default)
//            try recordingSession.setActive(true)
//
//            let tempDir = FileManager.default.temporaryDirectory
//            let url = tempDir.appendingPathComponent(UUID().uuidString + ".m4a")
//            recordingURL = url
//
//            let settings = [
//                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
//                AVSampleRateKey: 12000,
//                AVNumberOfChannelsKey: 1,
//                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
//            ]
//
//            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
//            audioRecorder?.delegate = self
//            audioRecorder?.record()
//            
//            // Add a delay to simulate recording time and stop the recording
//            DispatchQueue.main.asyncAfter(deadline: .now() + 5) { // Record for 5 seconds
//                self.stopRecording()
//            }
//        } catch {
//            print("Failed to set up recording session: \(error.localizedDescription)")
//        }
//    }
//
//    func stopRecording() {
//        audioRecorder?.stop()
//        if let url = recordingURL {
//            completionHandler?(url)
//            print("Recording saved to: \(url)")
//        }
//    }
//    
//    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
//        if flag {
//            print("Recording finished successfully.")
//        } else {
//            print("Recording failed.")
//        }
//    }
//}
import UIKit
import AVFoundation

class AudioRecorderViewController: UIViewController {

    private var audioRecorder: AVAudioRecorder?
    private var recordingURL: URL?

    // UI Elements
    private let recordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start Recording", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold) // Larger text size
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(toggleRecording), for: .touchUpInside)
        return button
    }()

    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Done", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium) // Slightly larger text
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(finishRecording), for: .touchUpInside)
        return button
    }()

    private let recordingIndicatorLabel: UILabel = {
        let label = UILabel()
        label.text = "Not Recording"
        label.font = UIFont.boldSystemFont(ofSize: 24) // Larger font size
        label.textColor = .systemRed
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    var onRecordingFinished: ((URL?) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        requestMicrophoneAccess()
    }

    private func setupUI() {
        view.addSubview(recordingIndicatorLabel)
        view.addSubview(recordButton)
        view.addSubview(doneButton)

        NSLayoutConstraint.activate([
            // Recording Indicator Label
            recordingIndicatorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordingIndicatorLabel.bottomAnchor.constraint(equalTo: recordButton.topAnchor, constant: -20),

            // Record Button
            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            // Done Button
            doneButton.topAnchor.constraint(equalTo: recordButton.bottomAnchor, constant: 20),
            doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func requestMicrophoneAccess() {
        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission { granted in
                if !granted {
                    DispatchQueue.main.async {
                        self.showPermissionAlert()
                    }
                }
            }
        } else {
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                if !granted {
                    DispatchQueue.main.async {
                        self.showPermissionAlert()
                    }
                }
            }
        }
    }

    private func showPermissionAlert() {
        let alert = UIAlertController(
            title: "Microphone Access Required",
            message: "Please grant microphone access to record audio.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func toggleRecording() {
        if audioRecorder?.isRecording == true {
            stopRecording()
            recordButton.setTitle("Start Recording", for: .normal)
            recordingIndicatorLabel.text = "Not Recording"
            recordingIndicatorLabel.textColor = .systemRed
        } else {
            startRecording()
            recordButton.setTitle("Stop Recording", for: .normal)
            recordingIndicatorLabel.text = "Recording..."
            recordingIndicatorLabel.textColor = .systemGreen
        }
    }

    private func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)

            // Set file path to save as `.wav`
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let recordingPath = documentsDirectory.appendingPathComponent("recording.wav")
            recordingURL = recordingPath

            // Configure recorder settings for `.wav`
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatLinearPCM), // WAV format
                AVSampleRateKey: 44100.0,                 // Sample rate
                AVNumberOfChannelsKey: 1,                 // Mono
                AVLinearPCMBitDepthKey: 16,               // Bits per sample
                AVLinearPCMIsBigEndianKey: false,
                AVLinearPCMIsFloatKey: false
            ]

            // Initialize recorder
            audioRecorder = try AVAudioRecorder(url: recordingURL!, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()

        } catch {
            print("Failed to start recording: \(error.localizedDescription)")
        }
    }

    private func stopRecording() {
        audioRecorder?.stop()
        if let recordingURL = recordingURL {
            onRecordingFinished?(recordingURL)
        } else {
            onRecordingFinished?(nil)
        }
        audioRecorder = nil
    }

    @objc private func finishRecording() {
        stopRecording()
        dismiss(animated: true, completion: nil)
    }
}

extension AudioRecorderViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            print("Recording failed.")
        }
    }
}
