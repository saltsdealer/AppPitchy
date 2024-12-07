//
//  ProfileViewController.swift
//  finalMobile
//
//  Created by firesalts on 11/20/24.
//

import Foundation
import UIKit
import UIKit

class ProfileView: UIView {
    
    // MARK: - UI Elements
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let displayNameLabel: UILabel = {
        let label = UILabel()
        label.text = "User DisplayName"
        label.textColor = UIColor.textMiddle
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        return label
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
        return imageView
    }() 
    
    let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "EMAIL: xxxx@xxx.com"
        label.textColor = UIColor.textMiddle
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "USERNAME: DisplayName"
        label.textColor = UIColor.textMiddle
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()
    
    let editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("EDIT INFO", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setTitleColor(UIColor.textLeft, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.bottomNavi.cgColor
        button.layer.backgroundColor = UIColor.buttonColorLeft.cgColor
        return button
    }()
    
    let changeEmailButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("CHANGE EMAIL", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setTitleColor(UIColor.textRight, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.bottomNavi.cgColor
        button.layer.backgroundColor = UIColor.buttonColorRight.cgColor
        return button
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(named: "BackgroundColor") ?? .yellow
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Dynamically set corner radius based on the final frame size
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.layer.masksToBounds = true // Ensure it clips to the bounds
        profileImageView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Add scrollView and contentView
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Add subviews to contentView
        contentView.addSubview(displayNameLabel)
        contentView.addSubview(profileImageView)
        contentView.addSubview(emailLabel)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(buttonStackView)
        // Add buttons to stackView
        buttonStackView.addArrangedSubview(editButton)
        buttonStackView.addArrangedSubview(changeEmailButton)
        // Disable autoresizing masks
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        displayNameLabel.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Layout scrollView
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        // Layout contentView
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor) // Match scrollView width
        ])
        
        // Layout subviews within contentView
        NSLayoutConstraint.activate([
            displayNameLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 15),
            displayNameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            profileImageView.topAnchor.constraint(equalTo: displayNameLabel.bottomAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalTo: profileImageView.widthAnchor),
            
            emailLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            emailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            usernameLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 10),
            usernameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            usernameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            buttonStackView.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 20),
            buttonStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            buttonStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            buttonStackView.heightAnchor.constraint(equalToConstant: 40),
            buttonStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)// Ensure scrollable content height
        ])
    }
}

extension UIImage {
    func cropToCircle() -> UIImage? {
        let minDimension = min(size.width, size.height)
        let squareSize = CGSize(width: minDimension, height: minDimension)
        let origin = CGPoint(
            x: (size.width - minDimension) / 2,
            y: (size.height - minDimension) / 2
        )
        let cropRect = CGRect(origin: origin, size: squareSize)

        // Crop the image to a square
        guard let cgImage = cgImage?.cropping(to: cropRect) else { return nil }

        // Create a circular path
        UIGraphicsBeginImageContextWithOptions(squareSize, false, scale)
        let context = UIGraphicsGetCurrentContext()
        context?.addEllipse(in: CGRect(origin: .zero, size: squareSize))
        context?.clip()

        UIImage(cgImage: cgImage).draw(in: CGRect(origin: .zero, size: squareSize))

        let circularImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return circularImage
    }
}
