//
//  SpectrumView.swift
//  finalMobile
//
//  Created by firesalts on 10/30/24.
//

import Foundation
import UIKit
import FirebaseAuth

@IBDesignable
class SpectrumView: UIView {
    
    // Public property to set frequency values
    var frequencies: [Float] = [] {
        didSet {
            spectrumViewDrawer.frequencies = frequencies
            updateView()
        }
    }
    
    // Private spectrum view instance
    var spectrumViewDrawer: SpectrumViewDrawer!
    private var defaultImageView: UIImageView!

    // Initializer for programmatic use
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    // Initializer for storyboard/XIB use
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    // Sets up the spectrum view inside this container view
    private func setupView() {
        spectrumViewDrawer = SpectrumViewDrawer(frame: bounds)
        spectrumViewDrawer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(spectrumViewDrawer)
        
        // Setup the default image view
        defaultImageView = UIImageView(frame: bounds)
        defaultImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        defaultImageView.contentMode = .scaleAspectFit
        defaultImageView.image = UIImage(named: "logoNoBC") // Replace with your default image name
        defaultImageView.isHidden = true
        addSubview(defaultImageView)
    }
    
    // Updates the spectrum view and toggles the default image
    private func updateView() {
        if frequencies.isEmpty {
            defaultImageView.isHidden = false
            spectrumViewDrawer.isHidden = true
        } else {
            defaultImageView.isHidden = true
            spectrumViewDrawer.isHidden = false
            spectrumViewDrawer.frequencies = frequencies
        }
    }

    // Updates the spectrum view's frequency data
    func updateFrequencies(_ newFrequencies: [Float]) {
        frequencies = newFrequencies
        spectrumViewDrawer.frequencies = newFrequencies
    }
}

extension SpectrumView {
    
    func saveToPhotoGallery(completion: @escaping (UIImage?, Error?) -> Void) {
        // Render the SpectrumView as an image
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        let image = renderer.image { context in
            layer.render(in: context.cgContext)
        }
        let timestamp = Int(Date().timeIntervalSince1970)
        let userUID = Auth.auth().currentUser?.uid
        let filename = "pitchy-res-\(String(describing: userUID))-\(timestamp).jpg"
        // Save the image to the photo gallery
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(imageSaveCompletion(_:didFinishSavingWithError:contextInfo:)), nil)
        ProfileImageCache.shared.saveImage(image, as: filename)
        completion(image, nil)
        
    }

    @objc private func imageSaveCompletion(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        let alertController: UIAlertController
        if let error = error {
            alertController = UIAlertController(
                title: "Save Failed",
                message: error.localizedDescription,
                preferredStyle: .alert
            )
        } else {
            alertController = UIAlertController(
                title: "Save Successful",
                message: "The spectrum view has been saved to your photo gallery.",
                preferredStyle: .alert
            )
        }
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        // Find the active window scene
        if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
           let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
            keyWindow.rootViewController?.present(alertController, animated: true)
        }
    }
}
