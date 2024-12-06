//
//  PostDetailViewController.swift
//  finalMobile
//
//  Created by firesalts on 11/26/24.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import QuickLook
import FirebaseAuth

class PostDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let postDetailView = PostDetailView()
    private let post: Post
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private var comments: [Comment] = []
    private var commentsListener: ListenerRegistration?
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private var messageInputBottomConstraint: NSLayoutConstraint?
    private var contentViewHeightConstraint: NSLayoutConstraint?
    private var contentViewBottomConstraint: NSLayoutConstraint?
    
    init(post: Post) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = postDetailView
        setupActivityIndicator()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        //displayInitialPostData()
        loadPostImages()
        observeComments()
        
        // Set up keyboard observers
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        messageInputBottomConstraint = postDetailView.messageInputContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        messageInputBottomConstraint?.isActive = true

        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.orientationLock = .portrait
        }
        
        view.addGestureRecognizer(tapGesture)
        
        
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

    private func setupView() {
        postDetailView.chatTableView.dataSource = self
        postDetailView.chatTableView.delegate = self
        postDetailView.chatTableView.separatorColor = UIColor.clear
    
        postDetailView.messageTextField.delegate = self
        postDetailView.sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        // Assign handler for image taps
        postDetailView.imageTappedHandler = { [weak self] index in
            guard let self = self else { return }
            self.previewOtherImage(at: index)
        }
        
        // Add tap gesture for main image
         let mainImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(previewMainImage))
         postDetailView.mainImageView.isUserInteractionEnabled = true
         postDetailView.mainImageView.addGestureRecognizer(mainImageTapGesture)
        print("Main image interaction enabled: \(postDetailView.mainImageView.isUserInteractionEnabled)")

    }
    
    
    private func setupActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        view.bringSubviewToFront(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func handleKeyboardWillShow(notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardHeight = keyboardFrame.height
        
        // Adjust the bottom constraint to move the input field above the keyboard
        messageInputBottomConstraint?.constant = -keyboardHeight
        contentViewHeightConstraint = postDetailView.contentView.heightAnchor.constraint(equalToConstant: 0)
        contentViewHeightConstraint?.isActive = true
        // Adjust the content view height to ensure the chat table view is fully visible
        postDetailView.contentView.isHidden = true
        
        // Animate the layout change
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func handleKeyboardWillHide(notification: Notification) {
        // Reset the bottom constraint
        messageInputBottomConstraint?.constant = 0
        // Restore the content view height
        postDetailView.contentView.isHidden = false
        contentViewHeightConstraint?.isActive = false
        // Animate the layout change
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollToBottom()
    }
    
    private func scrollToBottom() {
        if !comments.isEmpty {
            let lastRow = IndexPath(row: comments.count - 1, section: 0)
            postDetailView.chatTableView.scrollToRow(at: lastRow, at: .bottom, animated: true)
        }
    }
    
    // obeselted
    private func displayInitialPostData() {
        // Fetch creator's profile image
        activityIndicator.startAnimating()
        let creatorID = post.creatorID
        // Fetch timestamp from the `posts` collection in Firebase
        db.collection("posts").document(post.postID).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching post timestamp: \(error)")
                return
            }
            guard let data = snapshot?.data(),
                  let timestamp = data["timestamp"] as? Timestamp else {
                print("No timestamp found for postID: \(self.post.postID)")
                return
            }

            // Add the first comment (from the post data)
            let initialComment = Comment(
                message: self.post.messages,
                senderID: creatorID,
                timestamp: timestamp.dateValue()
            )
            
            self.comments.append(initialComment) // Add the initial comment to the table
            self.postDetailView.chatTableView.reloadData() // Reload table to display the initial comment
            activityIndicator.stopAnimating()
        }
    }
    
    // MARK: - Full-Screen Preview for Images
    @objc private func previewMainImage() {
        print("Main image tapped")
        guard let image = postDetailView.mainImageView.image else { return }
        let previewVC = ImagePreviewViewController(image: image)
        present(previewVC, animated: true, completion: nil)
    }

    private func previewOtherImage(at index: Int) {
        guard index < post.postsPicsURL.count else { return }
        let ref = storage.reference(forURL: post.postsPicsURL[index])
        ref.getData(maxSize: 5 * 1024 * 1024) { [weak self] data, _ in
            guard let self = self else { return }
            if let data = data, let image = UIImage(data: data) {
                let previewVC = ImagePreviewViewController(image: image)
                self.present(previewVC, animated: true, completion: nil)
            }
        }
    }

    
    private func loadPostImages() {
        let imageURLs = post.postsPicsURL
        if !imageURLs.isEmpty {
            // Load the first image
            let ref = storage.reference(forURL: imageURLs[0])
            ref.getData(maxSize: 5 * 1024 * 1024) { [weak self] data, _ in
                if let data = data, let image = UIImage(data: data) {
                    self?.postDetailView.mainImageView.image = image
                }
            }

            // Load other images
            let otherImagesURLs = imageURLs.dropFirst()
            var otherImages: [UIImage] = []
            
            if otherImagesURLs.isEmpty {
                contentViewBottomConstraint = postDetailView.otherImagesStackView.heightAnchor.constraint(equalToConstant: 0)
                contentViewBottomConstraint?.isActive = true
            } else {
                contentViewBottomConstraint?.isActive = false
            }
            
            for url in otherImagesURLs {
                let ref = storage.reference(forURL: url)
                ref.getData(maxSize: 5 * 1024 * 1024) { data, _ in
                    if let data = data, let image = UIImage(data: data) {
                        otherImages.append(image)
                        if otherImages.count == otherImagesURLs.count {
                            DispatchQueue.main.async {
                                self.postDetailView.addOtherImages(images: otherImages)
                            }
                        }
                    }
                }
            }
        }
    }
    

    @objc private func sendMessage() {
        guard let text = postDetailView.messageTextField.text, !text.isEmpty, text.count <= 50 else { return }
        let comment = [
            "message": text,
            "senderID": String(Auth.auth().currentUser!.uid), // Replace with actual user ID
            "timestamp": Timestamp(date: Date())
        ] as [String: Any]

        db.collection("comments").document(post.postID).collection("messages").addDocument(data: comment)
        postDetailView.messageTextField.text = ""
    }
    
    func fetchDisplayName(for uid: String, completion: @escaping (String) -> Void) {
        let db = Firestore.firestore()
        let userDocument = db.collection("users").document(uid)
        
        userDocument.getDocument { document, error in
            if let document = document, document.exists, let data = document.data(),
               let displayName = data["displayName"] as? String {
                // Call the completion handler with the fetched display name
                completion(displayName)
            } else {
                // Call the completion handler with a fallback value
                print("Error fetching document: \(error?.localizedDescription ?? "Unknown error")")
                completion("Sender") // Default fallback name
            }
        }
    }

    // MARK: - Real-Time Comments Listener
    private func observeComments() {
        
        
        commentsListener = db.collection("comments").document(post.postID).collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] snapshot, _ in
                guard let self = self else { return }
                guard let documents = snapshot?.documents else { return }
                
                let previousCommentCount = self.comments.count
                
                self.comments = documents.compactMap { doc in
                    let data = doc.data()
                    guard let message = data["message"] as? String,
                          let senderID = data["senderID"] as? String,
                          let timestamp = data["timestamp"] as? Timestamp else { return nil }
                    return Comment(message: message, senderID: senderID, timestamp: timestamp.dateValue())
                }
                // Reload the table view after appending
                self.comments.sort { $0.timestamp < $1.timestamp }
                self.postDetailView.chatTableView.reloadData()
                
                if self.comments.count > previousCommentCount {
                    self.scrollToBottom()
                }
            }
    }
    

}

// MARK: - UITableViewDataSource
extension PostDetailViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("fetching comments: ",comments.count)
        return comments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTableViewCell", for: indexPath) as? ChatTableViewCell else {
            return UITableViewCell()
        }
        var name = ""
        
        let comment = comments[indexPath.row]
        // Configure the cell with a placeholder for the senderName initially
        let isUser = comment.senderID == Auth.auth().currentUser?.uid
        
        fetchDisplayName(for: comment.senderID) { displayName in
            name = displayName
            if !isUser {
                cell.titleLabel.text = name
            }
        }
        


        
        cell.configureCell(
            senderName: "Mysterious Sender", // Placeholder while fetching the displayName
            message: comment.message,
            timestamp: DateFormatter.localizedString(from: comment.timestamp, dateStyle: .none, timeStyle: .short),
            profileImage: nil, // Profile image will be loaded asynchronously
            isCurrentUser: isUser
        )
        
        // Check the cache for the profile image
        if let cachedImage = ProfileImageCache.shared.getImage(for: comment.senderID) {
            cell.profileImageView.image = cachedImage
        } else {
            // Fetch the profile image from Firebase Storage if not in cache
            let profileImageRef = storage.reference(withPath: "profile_images/\(comment.senderID).jpg")
            profileImageRef.getData(maxSize: 5 * 1024 * 1024) { data, _ in
                if let data = data, let image = UIImage(data: data) {
                    // Cache the image and update the cell
                    ProfileImageCache.shared.saveImage(image, for: comment.senderID)
                
                        // Check if the cell is still visible (to prevent wrong data due to cell reuse)
                        if let visibleCell = tableView.cellForRow(at: indexPath) as? ChatTableViewCell {
                            visibleCell.profileImageView.image = image
                        }
                    
                }
            }
        }

        return cell
    }
}

// MARK: - UITextFieldDelegate
extension PostDetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


