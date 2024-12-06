//
//  PostDetailView.swift
//  finalMobile
//
//  Created by firesalts on 11/26/24.
//

import UIKit

class PostDetailView: UIView {
    // MARK: - Properties
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    
    let mainImageView = UIImageView()
    let otherImagesStackView = UIStackView()
    let chatTableView = UITableView()
    let messageInputContainer : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.bottomNavi // Set the background color of the container
        return view
    }()
    let messageTextField = UITextField()
    let sendButton = UIButton(type: .system)
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.bottomNavi
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup View
    private func setupView() {
        contentView.backgroundColor = UIColor(named: "BackgroundColor")
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = UIColor(named: "BackgroundColor")
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        addSubview(contentView)
        // Add Subviews to ContentView
        contentView.addSubview(mainImageView)
        contentView.addSubview(otherImagesStackView)
        //contentView.addSubview(chatTableView)
        
        contentView.bringSubviewToFront(mainImageView)
        contentView.bringSubviewToFront(otherImagesStackView)
        //contentView.bringSubviewToFront(chatTableView)
        
        //contentView.addSubview(messageInputContainer)
        addSubview(chatTableView)
        addSubview(messageInputContainer)
        // Main Image
        mainImageView.contentMode = .scaleAspectFill
        mainImageView.clipsToBounds = true
        mainImageView.layer.cornerRadius = 10
        mainImageView.layer.borderWidth = 2
        mainImageView.layer.borderColor = UIColor.bottomNavi.cgColor
        mainImageView.translatesAutoresizingMaskIntoConstraints = false
        //addSubview(mainImageView)
        
        // Other Images
        otherImagesStackView.axis = .horizontal
        otherImagesStackView.backgroundColor = UIColor(named: "BackgroundColor")
        otherImagesStackView.distribution = .fillProportionally
        otherImagesStackView.spacing = 8
        otherImagesStackView.translatesAutoresizingMaskIntoConstraints = false
        //addSubview(otherImagesStackView)
        
        // Chat Table View
        chatTableView.register(ChatTableViewCell.self, forCellReuseIdentifier: "ChatTableViewCell")
        chatTableView.translatesAutoresizingMaskIntoConstraints = false
        chatTableView.backgroundColor = UIColor(named: "BackgroundColor")
        //chatTableView.isScrollEnabled = false
        //addSubview(chatTableView)
        
        // Message Input Area
        messageInputContainer.translatesAutoresizingMaskIntoConstraints = false
        //addSubview(messageInputContainer)
        
        messageTextField.placeholder = "Type a message..."
        messageTextField.borderStyle = .roundedRect
        messageTextField.translatesAutoresizingMaskIntoConstraints = false
        messageInputContainer.addSubview(messageTextField)
        
        sendButton.setTitle(" Send ", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.backgroundColor = .white
        sendButton.setTitleColor(UIColor.bottomNavi, for: .normal)
        sendButton.layer.borderColor = UIColor.clear.cgColor
        sendButton.layer.backgroundColor = UIColor.white.cgColor
        sendButton.layer.borderWidth = 2
        sendButton.layer.cornerRadius = 10
        sendButton.clipsToBounds = true
        messageInputContainer.addSubview(sendButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: contentView.topAnchor),
            
            contentView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: chatTableView.topAnchor),
            contentView.widthAnchor.constraint(equalTo: widthAnchor) // Important for horizontal scrolling
        ])
        
        
        // Constraints
        NSLayoutConstraint.activate([
            // Main Image View
            
            mainImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
                 mainImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
                 mainImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
                 mainImageView.heightAnchor.constraint(equalToConstant: 150),
                 
                 // Other Images Stack View
                 otherImagesStackView.topAnchor.constraint(equalTo: mainImageView.bottomAnchor, constant: 8),
                 otherImagesStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
                 otherImagesStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
                 otherImagesStackView.heightAnchor.constraint(equalToConstant: 50),
                 
                 // Chat Table View
                 chatTableView.topAnchor.constraint(equalTo: otherImagesStackView.bottomAnchor, constant: 5),
                 chatTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                 chatTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                 chatTableView.heightAnchor.constraint(equalToConstant: 400), // Set fixed height
                 
                 // Message Input Container
                 messageInputContainer.topAnchor.constraint(equalTo: chatTableView.bottomAnchor, constant: 8),
                 messageInputContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                 messageInputContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                 messageInputContainer.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
                 messageInputContainer.heightAnchor.constraint(equalToConstant: 50),
                 
                 // Message TextField
                 messageTextField.leadingAnchor.constraint(equalTo: messageInputContainer.leadingAnchor, constant: 8),
                 messageTextField.centerYAnchor.constraint(equalTo: messageInputContainer.centerYAnchor),
                 messageTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -10),
                 messageTextField.heightAnchor.constraint(equalToConstant: 40),
                 
                 // Send Button
                 sendButton.trailingAnchor.constraint(equalTo: messageInputContainer.trailingAnchor, constant: -10),
                 sendButton.centerYAnchor.constraint(equalTo: messageInputContainer.centerYAnchor),
                 sendButton.widthAnchor.constraint(equalToConstant: 80),
                 sendButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    // Helper to add other images
    func addOtherImages(images: [UIImage]) {
        otherImagesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() } // Clear existing images
        otherImagesStackView.alignment = .leading // Align items to the left
        otherImagesStackView.spacing = 8 // Add spacing between images
        otherImagesStackView.distribution = .fill // Let the child views define their sizes

        for (index, image) in images.enumerated() {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFill // Ensure the image fills the view while maintaining aspect ratio
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 10 // Add corner radius for aesthetics
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 2
            imageView.layer.borderColor = UIColor.bottomNavi.cgColor
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.isUserInteractionEnabled = true // Enable user interaction

            // Add tap gesture recognizer to handle image tap
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
            imageView.addGestureRecognizer(tapGesture)
            imageView.tag = index // Use tag to identify the tapped image

            // Add the image view to the stack view
            otherImagesStackView.addArrangedSubview(imageView)

            // Apply explicit constraints to make the image a square
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: 50), // Fixed width
                imageView.heightAnchor.constraint(equalToConstant: 50) // Enforce 1:1 aspect ratio
            ])
        }
    }
    
    @objc private func imageTapped(_ sender: UITapGestureRecognizer) {
        if let tappedImageView = sender.view as? UIImageView {
            print("Image \(tappedImageView.tag) tapped!")
            // Notify the controller to preview the tapped image
            imageTappedHandler?(tappedImageView.tag)
        }
    }

    // Add a handler to notify the view controller of the tapped image
    var imageTappedHandler: ((Int) -> Void)?
}
// Custom TableView Cell for Chat
class ChatTableViewCell: UITableViewCell {
    // Profile image view for the sender's profile picture
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 25 // Make it circular (adjust based on size)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let customSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    // Label for displaying the sender's name
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Label for displaying the message content
    let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0 // Allow multi-line
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.cornerRadius = 15
        label.clipsToBounds = false
        return label
    }()
    
    // Background view for the message content styled like a chat bubble
    let messageBackgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Label for displaying the timestamp
    let timestampLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Constraints to control alignment dynamically
    var messageLeadingConstraint: NSLayoutConstraint!
    var messageTrailingConstraint: NSLayoutConstraint!
    var timestampLeadingConstraint: NSLayoutConstraint!
    var timestampTrailingConstraint: NSLayoutConstraint!
    var profileImageLeadingConstraint: NSLayoutConstraint!
    var profileImageTrailingConstraint: NSLayoutConstraint!
    var titleLabelLeadingConstraint: NSLayoutConstraint!
    var titleLabelTrailingConstraint: NSLayoutConstraint!

    override func setSelected(_ selected: Bool, animated: Bool) {
        // Override and do nothing to prevent selection shading
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Make the cell background translucent
        backgroundColor = UIColor(named: "BackgroundColor")
        // Add subviews to the content view
        contentView.addSubview(profileImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(messageBackgroundView)
        messageBackgroundView.addSubview(messageLabel)
        contentView.addSubview(timestampLabel)
        contentView.addSubview(customSeparator)
        
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        // Set up constraints for dynamic alignment
        messageLeadingConstraint = messageBackgroundView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 15)
        messageTrailingConstraint = messageBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -75)
        
        timestampLeadingConstraint = timestampLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: -58)
        timestampTrailingConstraint = timestampLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        
        profileImageLeadingConstraint = profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8)
        profileImageTrailingConstraint = profileImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        
        // Title label constraints
        titleLabelLeadingConstraint = titleLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 15)
        titleLabelTrailingConstraint = titleLabel.trailingAnchor.constraint(equalTo: profileImageView.leadingAnchor, constant: -15)
        
        NSLayoutConstraint.activate([
            customSeparator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            customSeparator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            customSeparator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 6),
            customSeparator.heightAnchor.constraint(equalToConstant: 2) // Custom thickness
        ])
        
        NSLayoutConstraint.activate([
            // Profile image view constraints
            profileImageLeadingConstraint,
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            profileImageView.widthAnchor.constraint(equalToConstant: 60), // Fixed size
            profileImageView.heightAnchor.constraint(equalToConstant: 60), // Fixed size
            
            // Title label (sender's display name) constraints
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            
            // Message background constraints
            messageLeadingConstraint,
            messageTrailingConstraint,
            messageBackgroundView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            messageBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
            
            // Message label inside the bubble with increased padding
            messageLabel.leadingAnchor.constraint(equalTo: messageBackgroundView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: messageBackgroundView.trailingAnchor, constant: -12),
            messageLabel.topAnchor.constraint(equalTo: messageBackgroundView.topAnchor, constant: 10),
            messageLabel.bottomAnchor.constraint(equalTo: messageBackgroundView.bottomAnchor, constant: -10),
            
            // Timestamp constraints
            timestampLeadingConstraint,
            timestampLabel.topAnchor.constraint(equalTo: messageBackgroundView.bottomAnchor, constant: 4)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(senderName: String, message: String, timestamp: String, profileImage: UIImage?, isCurrentUser: Bool) {
        profileImageView.image = profileImage ?? UIImage(named: "person.fill")

        titleLabel.text = isCurrentUser ? "Me" : senderName
        messageLabel.text = message
        timestampLabel.text = timestamp
        
        if isCurrentUser {
            // Current user's message: align message to the right and timestamp beneath the bubble on the right
            titleLabel.textAlignment = .right
            messageBackgroundView.backgroundColor = UIColor.blue.withAlphaComponent(0.3)
            messageLabel.textColor = .white
            
            // Update constraints for right alignment
            profileImageLeadingConstraint.isActive = false
            profileImageTrailingConstraint.isActive = true
            
            messageLeadingConstraint.isActive = false
            messageTrailingConstraint.isActive = true
            timestampLeadingConstraint.isActive = false
            timestampTrailingConstraint.isActive = true
            
            
            timestampLabel.textAlignment = .right
            titleLabelLeadingConstraint.isActive = false
            titleLabelTrailingConstraint.isActive = true
            
            // Hide profile image for the current user
 
        } else {
            // Other user's message: align message to the left and timestamp above the bubble on the left
            messageBackgroundView.backgroundColor = UIColor.green.withAlphaComponent(0.3)
            messageLabel.textColor = .black
            
            // Update constraints for left alignment
            profileImageTrailingConstraint.isActive = false
            profileImageLeadingConstraint.isActive = true
            
            titleLabelTrailingConstraint.isActive = false
            titleLabelLeadingConstraint.isActive = true
            
            messageLeadingConstraint.isActive = true
            messageTrailingConstraint.isActive = false
            timestampLeadingConstraint.isActive = true
            timestampTrailingConstraint.isActive = false
            timestampLabel.textAlignment = .left

        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Reset label properties and constraints
        titleLabel.textAlignment = .left // or your default alignment
        titleLabel.text = nil
        profileImageView.isHidden = false
        profileImageView.image = nil
        
        // Reset constraints if needed
        messageLeadingConstraint.isActive = true
        messageTrailingConstraint.isActive = false
        timestampLeadingConstraint.isActive = true
        timestampTrailingConstraint.isActive = false
    }
}

