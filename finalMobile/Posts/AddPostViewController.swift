//
//  AddPostViewController.swift
//  finalMobile
//
//  Created by firesalts on 11/24/24.
//

import UIKit
import PhotosUI
import FirebaseStorage
import FirebaseFirestore

class AddPostViewController: UIViewController, UITextViewDelegate, PHPickerViewControllerDelegate, UICollectionViewDataSource {
    private let addPostView = AddPostView()
    private var selectedImages: [UIImage] = []
    private let characterLimit = 250
    private let user: User // Store the passed User instance

    // Custom initializer to accept a User instance
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    // Overloaded initializer to accept a User, an image, and text
    init(user: User, initialImage: UIImage, initialText: String) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
        DispatchQueue.main.async {
            self.selectedImages.append(initialImage)
            self.addPostView.textView.text = initialText
            self.addPostView.imageCollectionView.reloadData()
            self.updateCollectionViewVisibility()
            self.updateButtonPosition()
        }

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = addPostView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCloseButton()
        setupKeyboardDismissHandlers()
        addPostView.textView.delegate = self
        addPostView.submitButton.isEnabled = false // Initially disabled
        addPostView.submitButton.alpha = 0.5 
        addPostView.imageCollectionView.dataSource = self
        addPostView.imageCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "imageCell")
        setupActions()
        
        updateCollectionViewVisibility()
        updateButtonPosition()
    }

    private func setupActions() {
        addPostView.addImagesButton.addTarget(self, action: #selector(handleAddImages), for: .touchUpInside)
        addPostView.submitButton.addTarget(self, action: #selector(handleSubmitPost), for: .touchUpInside)
    }
    // MARK: - UICollectionView DataSource
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         print("Number of items: \(selectedImages.count)")
         return selectedImages.count
     }
     
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath)
         
         // Add image view to cell
         let imageView = UIImageView(image: selectedImages[indexPath.item])
         imageView.contentMode = .scaleAspectFill
         imageView.clipsToBounds = true
         imageView.translatesAutoresizingMaskIntoConstraints = false
         cell.contentView.addSubview(imageView)
         
         NSLayoutConstraint.activate([
             imageView.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
             imageView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
             imageView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
             imageView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
         ])
         
         return cell
     }
     

    // MARK: - Multi-Photo Selection with PHPickerViewController
    @objc private func handleAddImages() {
        guard selectedImages.count < 6 else {
            showAlert(title: "Limit Reached", message: "You can only select up to 6 images.")
            return
        }

        var config = PHPickerConfiguration()
        config.filter = .images // Allow only images
        config.selectionLimit = 6 - selectedImages.count

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }

    // PHPickerViewControllerDelegate Method
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)

        for result in results {
            if selectedImages.count > 6 {
                break // Prevent adding more than 6 images
            }
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    guard let self = self, let image = image as? UIImage, error == nil else {
                        print("Error loading image: \(String(describing: error))")
                        return
                    }
                    DispatchQueue.main.async {
                        self.selectedImages.append(image)
                        self.addPostView.imageCollectionView.reloadData()
                        self.updateCollectionViewVisibility()
                        self.updateButtonPosition()
                    }
                }
            }
        }
    }

    @objc private func handleSubmitPost() {
        
        guard !selectedImages.isEmpty else {
            showAlert(title: "Error", message: "Please select at least one image.")
            return
        }
        
        guard let postText = addPostView.textView.text, !postText.isEmpty else {
            showAlert(title: "Error", message: "Please add text for your post")
            return
        }

        let postID = UUID().uuidString
        let storageRef = Storage.storage().reference().child("post_images").child(postID)
        var uploadedImageURLs: [String] = []

        let dispatchGroup = DispatchGroup()

        for (index, image) in selectedImages.enumerated() {
            // Compress the image without resizing
            guard let compressedImageData = image.jpegData(compressionQuality: 0.7) else { continue }

            dispatchGroup.enter()
            let imageRef = storageRef.child("image_\(index).jpg")
            imageRef.putData(compressedImageData, metadata: nil) { metadata, error in
                guard error == nil else {
                    print("Failed to upload image \(index): \(String(describing: error))")
                    dispatchGroup.leave()
                    return
                }
                imageRef.downloadURL { url, error in
                    if let url = url {
                        uploadedImageURLs.append(url.absoluteString)
                    }
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.savePostToDatabase(postID: postID, postText: postText, imageURLs: uploadedImageURLs)
        }
    }

    private func savePostToDatabase(postID: String, postText: String, imageURLs: [String]) {
        let db = Firestore.firestore()
        let postData: [String: Any] = [
            "postID": postID,
            "creatorID": user.uid, // Use the UID from the User instance
            "imageURLs": imageURLs,
            "messages": postText,
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        // Data for the "posts_msg" collection
        let postMessageData: [String: Any] = [
            "postID": postID,
            "creatorID": user.uid, // Use the UID from the User instance
            "message": postText,
            "timestamp": FieldValue.serverTimestamp()
        ]

        // Write to the "posts" collection
        db.collection("posts").document(postID).setData(postData) { error in
            if let error = error {
                self.showAlert(title: "Error", message: "Failed to save post: \(error.localizedDescription)")
                return
            } else {
                // If the first write is successful, write to the "posts_msg" collection
                db.collection("posts_msg").document(postID).setData(postMessageData) { msgError in
                    if let msgError = msgError {
                        self.showAlert(title: "Error", message: "Failed to save post message: \(msgError.localizedDescription)")
                        return
                    } else {
                        self.showAlert(title: "Success", message: "Post added successfully!")
                    }
                }
            }
        }
        // Write as the first comments in the post
        let comment = [
            "message": postText,
            "senderID": user.uid, // Replace with actual user ID
            "timestamp": Timestamp(date: Date())
        ] as [String: Any]

        db.collection("comments").document(postID).collection("messages").addDocument(data: comment) { error in
            if let error = error {
                self.showAlert(title: "Error", message: "Failed to save comments: \(error.localizedDescription)")
                return
            }
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            if title == "Success" {
                self.dismiss(animated: true, completion: nil)
            }
        }))
        present(alert, animated: true, completion: nil)
    }

    private func setupCloseButton() {
        addPostView.closeButton.addTarget(self, action: #selector(handleClose), for: .touchUpInside)
    }

    @objc private func handleClose() {
        dismiss(animated: true, completion: nil)
    }

    private func setupKeyboardDismissHandlers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // UITextViewDelegate: Dismiss keyboard when pressing the return key
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" { // Detect the return key
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let characterCount = textView.text.count

        if characterCount > characterLimit {
            // Truncate the text if it exceeds the character limit
            textView.text = String(textView.text.prefix(characterLimit))
        }

        // Update the label with remaining characters
        let remainingCharacters = max(characterLimit - characterCount, 0)
        addPostView.wordCountLabel.text = "\(remainingCharacters) characters remaining"

        // Disable/Enable the "Submit Post" button based on character limit
        addPostView.submitButton.isEnabled = remainingCharacters > 0
        addPostView.submitButton.alpha = remainingCharacters > 0 ? 1.0 : 0.5 // Visual feedback
    }
    
    private func updateCollectionViewVisibility() {
        addPostView.imageCollectionView.isHidden = selectedImages.isEmpty
    }
    
    private func updateButtonPosition() {
        addPostView.buttonTopConstraint.constant = selectedImages.isEmpty ? 0 : 20
        addPostView.imageCollectionView.isHidden = selectedImages.isEmpty
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }

}
