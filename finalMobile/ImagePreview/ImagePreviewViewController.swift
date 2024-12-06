//
//  ImagePreviewViewController.swift
//  finalMobile
//
//  Created by firesalts on 11/27/24.
//

import UIKit
import Photos

class ImagePreviewViewController: UIViewController, UIScrollViewDelegate {
    private let scrollView = UIScrollView()
    private let imageView = UIImageView()
    private let downloadButton = UIButton(type: .system)
    private let image: UIImage

    init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupScrollView()
        setupImageView()
        setupDownloadButton()
    }

    private func setupView() {
        // Set translucent gray background
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
    }

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0
        scrollView.delegate = self
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupImageView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        scrollView.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            imageView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        ])

        // Add tap gesture to dismiss the view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPreview))
        imageView.addGestureRecognizer(tapGesture)
    }

    private func setupDownloadButton() {
        downloadButton.setTitle("Download", for: .normal)
        downloadButton.setTitleColor(.white, for: .normal)
        downloadButton.backgroundColor = UIColor(white: 0.2, alpha: 0.8)
        downloadButton.layer.cornerRadius = 8
        downloadButton.translatesAutoresizingMaskIntoConstraints = false
        downloadButton.addTarget(self, action: #selector(downloadImageToGallery), for: .touchUpInside)
        view.addSubview(downloadButton)

        NSLayoutConstraint.activate([
            downloadButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            downloadButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            downloadButton.widthAnchor.constraint(equalToConstant: 100),
            downloadButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    @objc private func dismissPreview() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func downloadImageToGallery() {
        // Check photo library authorization
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized || status == .limited {
                self.saveImageToGallery()
            } else {
                DispatchQueue.main.async {
                    self.showAlert(title: "Permission Denied", message: "Please allow access to the photo library in Settings to download images.")
                }
            }
        }
    }

    private func saveImageToGallery() {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(imageSaved(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc private func imageSaved(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        DispatchQueue.main.async {
            if let error = error {
                self.showAlert(title: "Error", message: "Could not save image: \(error.localizedDescription)")
            } else {
                self.showAlert(title: "Success", message: "Image saved to your photo library.")
            }
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // MARK: - UIScrollViewDelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
