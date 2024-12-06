//
//  PostTableCellVIew.swift
//  finalMobile
//
//  Created by firesalts on 11/25/24.
//

import Foundation
import UIKit

class PostTableViewCell: UITableViewCell {
    
    // MARK: - UI Elements
    let mainContentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view // No appearance settings for the main container
    }()
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 30 // Assuming the circle diameter is 60
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let postingContentLabel: UILabel = {
        let label = UILabel()
        label.text = "Posting contents"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = UIColor.textMiddle
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let latestMessageLabel: UILabel = {
        let label = UILabel()
        label.text = "Latest msg"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.textMiddle
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .white // Set the desired line color
        return view
    }()
    
    
    let spacerView: UIView = {
        let spacer = UIView()
        spacer.backgroundColor = UIColor(named: "BackgroundColor") // Transparent view for spacing
        spacer.translatesAutoresizingMaskIntoConstraints = false
        return spacer
    }()
    
    // MARK: - Initializers
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    
    private func setupViews() {
//        contentView.addSubview(profileImageView)
//        contentView.addSubview(postingContentLabel)
//        contentView.addSubview(separatorLine)
//        contentView.addSubview(latestMessageLabel)
        contentView.addSubview(mainContentView)
        contentView.addSubview(spacerView)
        contentView.backgroundColor = UIColor(named: "BackgroundColor")
        
        // Add subviews to mainContentView
        mainContentView.addSubview(profileImageView)
        mainContentView.addSubview(postingContentLabel)
        mainContentView.addSubview(separatorLine)
        mainContentView.addSubview(latestMessageLabel)
        
//        contentView.layer.cornerRadius = 8
//        contentView.layer.borderWidth = 2
//        contentView.layer.borderColor = UIColor.bottomNavi.cgColor
//        contentView.layer.backgroundColor = UIColor.tableBack.cgColor
        mainContentView.layer.cornerRadius = 8
        mainContentView.layer.borderWidth = 2
        mainContentView.layer.borderColor = UIColor.bottomNavi.cgColor
        mainContentView.layer.backgroundColor = UIColor.tableBack.cgColor
        
    }
    
    private func setupConstraints() {
        
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        postingContentLabel.translatesAutoresizingMaskIntoConstraints = false
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        latestMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            // Main Content View Constraints
            mainContentView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainContentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // Spacer View Constraints
            spacerView.topAnchor.constraint(equalTo: mainContentView.bottomAnchor),
            spacerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            spacerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            spacerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            spacerView.heightAnchor.constraint(equalToConstant: 10),
            
            // Profile Image Constraints
            profileImageView.leadingAnchor.constraint(equalTo: mainContentView.leadingAnchor, constant: 15),
            profileImageView.topAnchor.constraint(equalTo: mainContentView.topAnchor, constant: 15),
            profileImageView.widthAnchor.constraint(equalToConstant: 60),
            profileImageView.heightAnchor.constraint(equalToConstant: 60),
            
            // Posting Content Label Constraints
            postingContentLabel.topAnchor.constraint(equalTo: mainContentView.topAnchor, constant: 15),
            postingContentLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 15),
            postingContentLabel.trailingAnchor.constraint(equalTo: mainContentView.trailingAnchor, constant: -15),
            
            // Separator Line Constraints
            separatorLine.topAnchor.constraint(equalTo: postingContentLabel.bottomAnchor, constant: 10),
            separatorLine.leadingAnchor.constraint(equalTo: postingContentLabel.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: postingContentLabel.trailingAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 1),
            
            // Latest Message Label Constraints
            latestMessageLabel.topAnchor.constraint(equalTo: separatorLine.bottomAnchor, constant: 10),
            latestMessageLabel.leadingAnchor.constraint(equalTo: postingContentLabel.leadingAnchor),
            latestMessageLabel.trailingAnchor.constraint(equalTo: postingContentLabel.trailingAnchor),
            latestMessageLabel.bottomAnchor.constraint(equalTo: mainContentView.bottomAnchor, constant: -15)
        ])
//
//        NSLayoutConstraint.activate([
//            contentView.topAnchor.constraint(equalTo: topAnchor),
//            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
//            contentView.bottomAnchor.constraint(equalTo: spacerView.topAnchor) // Ensure spacerView is below
//        ])
//        
//        NSLayoutConstraint.activate([
//            // Profile Image Constraints
//            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
//            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
//            profileImageView.widthAnchor.constraint(equalToConstant: 60),
//            profileImageView.heightAnchor.constraint(equalToConstant: 60),
//            
//            // Posting Content Label Constraints
//            postingContentLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
//            postingContentLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 15),
//            postingContentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
//            
//            // Separator Line Constraints
//            separatorLine.topAnchor.constraint(equalTo: postingContentLabel.bottomAnchor, constant: 10),
//            separatorLine.leadingAnchor.constraint(equalTo: postingContentLabel.leadingAnchor),
//            separatorLine.trailingAnchor.constraint(equalTo: postingContentLabel.trailingAnchor),
//            separatorLine.heightAnchor.constraint(equalToConstant: 1), // Set the line thickness
//            
//            // Latest Message Label Constraints
//            latestMessageLabel.topAnchor.constraint(equalTo: separatorLine.bottomAnchor, constant: 10),
//            latestMessageLabel.leadingAnchor.constraint(equalTo: postingContentLabel.leadingAnchor),
//            latestMessageLabel.trailingAnchor.constraint(equalTo: postingContentLabel.trailingAnchor),
//            latestMessageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
//            
//            spacerView.topAnchor.constraint(equalTo: contentView.bottomAnchor),
//            spacerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            spacerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            spacerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
//            spacerView.heightAnchor.constraint(equalToConstant: 10)
//        ])
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        // Override and do nothing to prevent selection shading
    }
}
