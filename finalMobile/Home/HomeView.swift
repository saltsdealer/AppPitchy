//
//  HomeView.swift
//  finalMobile
//
//  Created by firesalts on 11/14/24.
//

import Foundation
import UIKit

class HomeView: UIView {

    var onNavigateToDetails: (() -> Void)?

    // MARK: - UI Elements
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "BackgroundColor")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Click Pitchy To Sing or Pick!"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor(named: "TextMiddle")
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let navigateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Pitchy!", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.setTitleColor(UIColor(named: "TextRight"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(navigateButtonTapped), for: .touchUpInside)
        
        // Configure the rounded border
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 2
        button.layer.backgroundColor = UIColor(named: "WordBubbleTheme")?.cgColor
        button.layer.borderColor = UIColor.bottomNavi.cgColor
        return button
    }()
    
    let imageTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Your Latest Pitching Result: "
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = UIColor(named: "TextMiddle")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor(named: "BackgroundColor")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "logoNoBC")

        return imageView
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 10
    
        tableView.backgroundColor = UIColor(named: "BackgroundColor")
        return tableView
    }()

    let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log Out", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.setTitleColor(UIColor.textRight, for: .normal)
        button.backgroundColor = UIColor.wordBubbleTheme
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.bottomNavi.cgColor
        button.layer.backgroundColor = UIColor(named: "WordBubbleTheme")?.cgColor
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(named: "BackgroundColor") // Ensure visible background
        setupViews()
        setupConstraints()
        print("HomeView initialized")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup UI
    private func setupViews() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(messageLabel)
        contentView.addSubview(navigateButton)
        contentView.addSubview(imageTitleLabel)
        contentView.addSubview(imageView)
        contentView.addSubview(tableView)
        contentView.addSubview(logoutButton)
    }

    private func setupConstraints() {
        // ScrollView constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor) // Match scrollView width
        ])
        // Subview constraints
        NSLayoutConstraint.activate([
            // Message Label
             messageLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
             messageLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
             messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
             messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

             // Navigate Button
             navigateButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20),
             navigateButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
             navigateButton.widthAnchor.constraint(equalTo: tableView.widthAnchor),
             navigateButton.heightAnchor.constraint(equalToConstant: 50),
             
             imageTitleLabel.topAnchor.constraint(equalTo: navigateButton.bottomAnchor, constant: 20),
             imageTitleLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor,constant: 40),
             
             // Image View
             imageView.topAnchor.constraint(equalTo: imageTitleLabel.bottomAnchor, constant: 20),
             imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
             imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.72), // 90% of contentView width
             imageView.heightAnchor.constraint(equalToConstant: 200), // Fixed height
             
             tableView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
             tableView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
             tableView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20),
             tableView.heightAnchor.constraint(equalToConstant: 190),
             
             // Logout Button
             logoutButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 20),
             logoutButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
             logoutButton.widthAnchor.constraint(equalTo: tableView.widthAnchor),
             logoutButton.heightAnchor.constraint(equalToConstant: 50),
             logoutButton.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20)
        ])
    }

    @objc private func navigateButtonTapped() {
        onNavigateToDetails?()
    }

    // MARK: - Debugging Layout
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
