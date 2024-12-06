//
//  ViewController.swift
//  finalMobile
//
//  Created by firesalts on 10/30/24.
//  Obeseleted class , only used for testing 

import UIKit

class ViewController: UIViewController {

    // Create a button programmatically
    private let showDetailButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Show Detail", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupButton()
    }

    // Setup the button in the view hierarchy
    private func setupButton() {
        view.addSubview(showDetailButton)
        
        // Set up Auto Layout constraints for the button
        NSLayoutConstraint.activate([
            showDetailButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            showDetailButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            showDetailButton.widthAnchor.constraint(equalToConstant: 200),
            showDetailButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Add action to the button
        showDetailButton.addTarget(self, action: #selector(navigateToDetail), for: .touchUpInside)
    }

    // Action to navigate to DetailViewController
    @objc private func navigateToDetail() {
//        let detailVC = DetailViewController(fileName: "testFemale", fileExtension: "wav")
//        detailVC.frequencyData = FrequencyData()  // Set up with an instance of FrequencyData
//        detailVC.pitchDetector = PitchDetector()  // Set up with an instance of PitchDetector
//        navigationController?.pushViewController(detailVC, animated: true)
    }
}

