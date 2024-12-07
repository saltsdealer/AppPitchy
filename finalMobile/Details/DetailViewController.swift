//
//  DetailViewController.swift
//  finalMobile
//
//  Created by firesalts on 10/30/24.
//

import Foundation
import UIKit
import AVFoundation

class DetailViewController: UIViewController, PitchDetectorDelegate {
    func player(_ player: PitchDetector, didGenerateSpectrum spectrum: Float) {
        DispatchQueue.main.async {
            // Update the frequency data and refresh the spectrum view
            self.frequencyData.frequencies.append(spectrum)
            self.updateSpectrumView()
        }
    }
    
    // Properties for frequency data and pitch detector
    var frequencyData: FrequencyData!
    var pitchDetector: PitchDetector!
    var resultImage: UIImage
    var user: User
    
    private var fileName: String
    private var fileExtension: String
    private var totalPlayTime: Float
    private var fileURL: URL?
    
    // Timer for updating progress bar
    private var progressTimer: Timer?
    private var isPlaying: Bool = false
    private var currentPlayTime: Float = 0.0
    private var resMsg: String = ""
    
    

    // MARK: - Initializer
    init(fileName: String, fileExtension: String, user: User) {
        self.fileName = fileName
        self.fileExtension = fileExtension
        self.totalPlayTime = 0.0
        self.resultImage = UIImage()
        self.user = user
        // Load the duration asynchronously
        super.init(nibName: nil, bundle: nil)
        Task {
            if let duration = await getAudioFileDuration(fileName: fileName, fileExtension: fileExtension) {
                self.totalPlayTime = duration
            } else {
                print("Failed to load audio duration")
            }
        }
    }
    
    // New initializer for file URL
    init(fileURL: URL, user: User) {
        self.fileURL = fileURL
        self.totalPlayTime = 0.0
        self.resultImage = UIImage()
        self.user = user
        self.fileName = fileURL.deletingPathExtension().lastPathComponent
        self.fileExtension = fileURL.pathExtension
        
        super.init(nibName: nil, bundle: nil)
        Task {
            if let duration = await getAudioFileDuration(fileURL: fileURL) {
                self.totalPlayTime = duration
            } else {
                print("Failed to load audio duration")
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Cast the view to DetailView
    override func loadView() {
        self.view = DetailView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the title of the navigation bar
        self.title = "Spectrum View"
        // Access the custom view components
        guard let detailView = self.view as? DetailView else { return }
        pitchDetector.delegate = self
        // Start the pitch detector
        pitchDetector.frequencyData = frequencyData
        //pitchDetector.play(fileName: "testFemale", fileExtension: "wav")
        // Add action to Save Button
        detailView.saveButton.addTarget(self, action: #selector(saveSpectrum), for: .touchUpInside)
        // Initially disable the Save Button
        detailView.saveButton.isHidden = true
        // Add action to the Play/Stop button
        detailView.playStopButton.addTarget(self, action: #selector(togglePlayStop), for: .touchUpInside)

        // Set initial frequencies in the spectrum view
        detailView.spectrumUIView.updateFrequencies(frequencyData.frequencies)
    
        // Add action to the clear button
        detailView.clearButton.addTarget(self, action: #selector(clearFrequencies), for: .touchUpInside)
        //
        detailView.postButton.addTarget(self, action: #selector(postFunction), for: .touchUpInside)
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.orientationLock = .portrait
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Reset the orientation lock to allow other orientations
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.orientationLock = .all // Allow all orientations
        }
    }
    
    // MARK: - Actions
    // Add the postFunction
    @objc private func postFunction() {
        // Check if resultImage is still the default empty image
        if resultImage == UIImage() {
            // Show alert if image hasn't been saved yet
            let alert = UIAlertController(
                title: "Save Required",
                message: "Please wait for the playback to complete and save the spectrum image first.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true, completion: nil)
            return
        }
        
        // Proceed to AddPostViewController if resultImage is valid
        handleAddPost()
    }
    
    @objc private func handleAddPost() {
        let addPostVC = AddPostViewController(user: user,initialImage: resultImage, initialText: resMsg.trimmingCharacters(in: .whitespacesAndNewlines))
        addPostVC.modalPresentationStyle = .pageSheet
        if let sheet = addPostVC.sheetPresentationController {
            sheet.detents = [.large()] // Pop-up style
            sheet.prefersGrabberVisible = true // Optional grabber at the top
        }
        present(addPostVC, animated: true, completion: nil)
    }
    
    @objc private func saveSpectrum() {
        guard let detailView = self.view as? DetailView else { return }
        detailView.spectrumUIView.saveToPhotoGallery{ image, error in
            if let error = error {
                print("Error saving image: \(error.localizedDescription)")
            } else if let image = image {
                // Do something with the image
                self.resultImage = image
                print("Image generated and returned successfully")
            }
        }
    }
    
    @objc private func togglePlayStop() {
        guard let detailView = self.view as? DetailView else { return }

        if isPlaying {
            // Stop playback
            isPlaying = false
            pitchDetector.stop()
            progressTimer?.invalidate()
            detailView.playStopButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            detailView.saveButton.isHidden = true
            
            // Set the axis labels when playback stops
            if let maxFrequency = frequencyData.frequencies.max() {
                detailView.spectrumUIView.spectrumViewDrawer.setAxisLabels(
                    xLabel: "Time (s)",
                    yLabel: "Max Frequency: \(String(format: "%.1f", maxFrequency)) Hz"
                )
            }
        } else {
            // Start playback
            isPlaying = true
            if let fileURL = self.fileURL {
                // Use fileURL if available
                pitchDetector.play(fileURL: fileURL)
            } else {
                // Use fileName and fileExtension if fileURL is not set
                pitchDetector.play(fileName: fileName, fileExtension: fileExtension)
            }
            detailView.playStopButton.setImage(UIImage(systemName: "stop.fill"), for: .normal)
            detailView.saveButton.isHidden = true
            // Start or Resume progress timer
            if currentPlayTime >= totalPlayTime {
                // Restart if playback completed
                currentPlayTime = 0.0
                detailView.progressBar.progress = 0.0
            }
            progressTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateProgressBar), userInfo: nil, repeats: true)
        }
    }
    
    @objc private func updateProgressBar() {
        guard let detailView = self.view as? DetailView else { return }

        currentPlayTime += 0.1
        let progress = currentPlayTime / totalPlayTime
        detailView.progressBar.progress = progress

        if currentPlayTime >= totalPlayTime {
            // Stop playback once the audio is finished
            progressTimer?.invalidate()
            detailView.progressBar.progress = 1.0
            togglePlayStop()
            
            detailView.saveButton.isHidden = false
            
            // Show word bubble
            if let maxFrequency = frequencyData.frequencies.max(),
               let minFrequency = frequencyData.frequencies.filter({ $0 > 0 }).min() {
                self.resMsg = """
                
                You reached the highest of \(maxFrequency) Hz!
                And the lowest of \(minFrequency) Hz!
                You are a singer from \(calculateMusicalScale(highest: maxFrequency, lowest: minFrequency)).
                
                """
                detailView.wordBubble.text = self.resMsg
                detailView.wordBubble.isHidden = false
            }
        }
    }

    @objc private func clearFrequencies() {
        // Create an alert controller
        let alertController = UIAlertController(
            title: "Clear Frequencies",
            message: "This will clear all frequencies and reset playback, Are you sure?",
            preferredStyle: .alert
        )

        // Add a "Clear" action
        let clearAction = UIAlertAction(title: "DO IT", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            // Clear frequencies and reset playback
            self.frequencyData.frequencies = []
            guard let detailView = self.view as? DetailView else { return }
            detailView.spectrumUIView.updateFrequencies(self.frequencyData.frequencies)
            self.isPlaying = false
            self.pitchDetector.reset()
            self.currentPlayTime = 0.0
            detailView.progressBar.progress = 0.0
            detailView.playStopButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            self.progressTimer?.invalidate()
            detailView.saveButton.isHidden = true
        }

        // Add a "Cancel" action
        let cancelAction = UIAlertAction(title: "NOPE", style: .cancel, handler: nil)

        // Add actions to the alert controller
        alertController.addAction(clearAction)
        alertController.addAction(cancelAction)

        // Present the alert
        present(alertController, animated: true, completion: nil)
    }
    
    private func updateSpectrumView() {
        guard let detailView = self.view as? DetailView else { return }
        detailView.spectrumUIView.updateFrequencies(frequencyData.frequencies)
    }
    
    
    func getAudioFileDuration(fileName: String, fileExtension: String) async -> Float? {
        guard let fileURL = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
            print("File not found")
            return nil
        }
        
        let asset = AVAsset(url: fileURL)
        
        do {
            // Asynchronously load the duration property
            let duration = try await asset.load(.duration)
            return Float(CMTimeGetSeconds(duration))
        } catch {
            print("Error loading duration: \(error.localizedDescription)")
            return nil
        }
    }
    
    func getAudioFileDuration(fileURL: URL) async -> Float? {
        
        let asset = AVAsset(url: fileURL)
        // Debug asset properties
        do {
            // Asynchronously load the duration property
            let duration = try await asset.load(.duration)
            return Float(CMTimeGetSeconds(duration))
        } catch {
            print("Error loading duration: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func calculateMusicalScale(highest: Float, lowest: Float) -> String {
        let baseNotes = [
            (note: "C", frequency: 16.35),
            (note: "C#", frequency: 17.32),
            (note: "D", frequency: 18.35),
            (note: "D#", frequency: 19.45),
            (note: "E", frequency: 20.60),
            (note: "F", frequency: 21.83),
            (note: "F#", frequency: 23.12),
            (note: "G", frequency: 24.50),
            (note: "G#", frequency: 25.96),
            (note: "A", frequency: 27.50),
            (note: "A#", frequency: 29.14),
            (note: "B", frequency: 30.87)
        ]

        // Function to find the closest note and its octave
        func closestNoteAndOctave(for frequency: Float) -> String {
            var adjustedFrequency = Double(frequency)
            var octave = 0

            // Adjust frequency to be within the range of the base notes
            while adjustedFrequency > 31.0 {
                adjustedFrequency /= 2
                octave += 1
            }
            while adjustedFrequency < 16.35 {
                adjustedFrequency *= 2
                octave -= 1
            }

            // Find the closest note
            let closest = baseNotes.min(by: { abs($0.frequency - adjustedFrequency) < abs($1.frequency - adjustedFrequency) })

            // Return note and octave
            return "\(closest?.note ?? "?")\(octave)"
        }

        // Calculate the closest notes for the highest and lowest frequencies
        let highestNote = closestNoteAndOctave(for: highest)
        let lowestNote = closestNoteAndOctave(for: lowest)

        return "\(lowestNote) to \(highestNote) !"
    }
}
