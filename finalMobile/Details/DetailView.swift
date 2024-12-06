//
//  DetailView.swift
//  finalMobile
//
//  Created by firesalts on 10/30/24.
//

import Foundation
import UIKit

class DetailView: UIView {
    
    // ScrollView to make the view scrollable
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = UIColor(named: "BackgroundColor")
        return scrollView
    }()
    
    // Container View inside ScrollView
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Spectrum view to display frequency data
    let spectrumUIView: SpectrumView = {
        let view = SpectrumView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        view.layer.borderColor = UIColor.bottomNavi.cgColor
        view.layer.borderWidth = 3
        view.clipsToBounds = true
        view.backgroundColor = .clear
        return view
    }()

    // Button to clear the frequency data
    let clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Clear", for: .normal)
        button.backgroundColor = UIColor(named: "ButtonColorLeft")
        button.setTitleColor(UIColor(named: "TextLeft"), for: .normal)
        button.layer.cornerRadius = 8
        button.layer.borderColor = UIColor.bottomNavi.cgColor
        button.layer.borderWidth = 3
        return button
    }()
    
    // Play/Stop button
    let playStopButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.tintColor = UIColor(named: "GraphLine")
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.bottomNavi.cgColor
        button.layer.cornerRadius = 28
        return button
    }()
    
    // Button to save the spectrum view as an image
    let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Save", for: .normal)
        button.backgroundColor = UIColor(named: "ButtonColorRight")
        button.setTitleColor(UIColor(named: "TextRight"), for: .normal)
        button.layer.borderColor = UIColor.bottomNavi.cgColor
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 8
        return button
    }()
    
    // Video progress bar
    let progressBar: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progress = 0.0
        progressView.tintColor = UIColor.bottomNavi
        return progressView
    }()
    
    let postButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Post", for: .normal)
        button.backgroundColor = UIColor(named: "ButtonColorLeft")
        button.setTitleColor(UIColor(named: "TextLeft"), for: .normal)
        button.layer.borderColor = UIColor.bottomNavi.cgColor
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 8
        return button
    }()
    
    // Word bubble to display the result message
    let wordBubble: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor(named: "WordBubbleTheme")
        label.textColor = UIColor(named: "TextRight")
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.layer.cornerRadius = 10
        label.layer.borderWidth = 2
        label.layer.masksToBounds = true
        label.text = "Click the play to start analysis!"
        label.layer.shadowColor = UIColor.gray.cgColor
        label.layer.shadowOpacity = 1 // Shadow transparency (0 to 1)
        label.layer.shadowOffset = CGSize(width: -2, height: 2) // Shadow position offset
        label.layer.shadowRadius = 5 // Blur radius of the shadow
        label.isHidden = false // Initially hidden
        return label
    }()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    // Setup view layout and subviews
    private func setupView() {
        backgroundColor = UIColor(named: "BackgroundColor")
        
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(spectrumUIView)
        contentView.addSubview(clearButton)
        contentView.addSubview(saveButton)
        contentView.addSubview(playStopButton)
        contentView.addSubview(progressBar)
        contentView.addSubview(wordBubble)
        contentView.addSubview(postButton)
        
        // Apply Auto Layout constraints
        NSLayoutConstraint.activate([
            // ScrollView constraints
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            
            // ContentView constraints
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 25),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor), // Important for vertical scrolling
            
            // SpectrumUIView constraints
            spectrumUIView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            spectrumUIView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            spectrumUIView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            spectrumUIView.heightAnchor.constraint(equalToConstant: 250),
            
            // PlayStopButton constraints
            playStopButton.topAnchor.constraint(equalTo: spectrumUIView.bottomAnchor, constant: 20),
            playStopButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            playStopButton.widthAnchor.constraint(equalToConstant: 44),
            playStopButton.heightAnchor.constraint(equalToConstant: 44),
            
            // ProgressBar constraints
            progressBar.centerYAnchor.constraint(equalTo: playStopButton.centerYAnchor),
            progressBar.leadingAnchor.constraint(equalTo: playStopButton.trailingAnchor, constant: 20),
            progressBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // ClearButton constraints (left-aligned)
            clearButton.topAnchor.constraint(equalTo: playStopButton.bottomAnchor, constant: 20),
            clearButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            clearButton.widthAnchor.constraint(equalToConstant: 120),
            clearButton.heightAnchor.constraint(equalToConstant: 44),

            // SaveButton constraints (right-aligned, same size as ClearButton)
            saveButton.topAnchor.constraint(equalTo: clearButton.topAnchor),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            saveButton.widthAnchor.constraint(equalTo: clearButton.widthAnchor),
            saveButton.heightAnchor.constraint(equalTo: clearButton.heightAnchor),

            // WordBubble constraints (centered below the buttons)
            wordBubble.topAnchor.constraint(equalTo: clearButton.bottomAnchor, constant: 20),
            wordBubble.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            wordBubble.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            wordBubble.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),

            // PostButton constraints
            postButton.topAnchor.constraint(equalTo: wordBubble.bottomAnchor, constant: 20),
            postButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            postButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            postButton.heightAnchor.constraint(equalToConstant: 44),

            // Update ContentView bottom constraint
            postButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
}
