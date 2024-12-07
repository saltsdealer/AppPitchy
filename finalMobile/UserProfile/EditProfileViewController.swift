//
//  EditProfileViewController.swift
//  finalMobile
//
//  Created by firesalts on 11/21/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import TOCropViewController

class EditProfileViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TOCropViewControllerDelegate {
    
    // MARK: - Properties
    private let editProfileView = EditProfileView()
    private var user: User
    private var selectedImage: UIImage?
    var isEmailUpdateMode: Bool = false
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .black
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Init
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func loadView() {
        view = editProfileView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        
        setupGestureToDismissKeyboard()
        setupTextFieldDelegates()
        updateTextFieldStates()
    }
    
    private let waitIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .gray
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Setup
    private func setupUI() {
        title = "Edit Profile"
        // Populate existing user data
        editProfileView.nameTextField.text = user.displayName
        editProfileView.emailTextField.text = user.email
        let filePath = ProfileImageCache.shared.getFilePath(for: user.uid)
        self.selectedImage = ProfileImageCache.shared.getImage(for: user.uid)
        if FileManager.default.fileExists(atPath: filePath) {
            if let image = UIImage(contentsOfFile: filePath) {
                DispatchQueue.main.async {
                    let editedImage = image.withRenderingMode(.alwaysOriginal)
                    self.setProfileImageButton(editedImage)
                    self.selectedImage = editedImage
                }
            } else {
                print("Failed to create UIImage from file at path: \(filePath)")
            }
        } else {
            print("File does not exist at path: \(filePath)")
        }
        
    }

    
    private func updateTextFieldStates() {
        // Enable/disable text fields based on the mode
        editProfileView.emailTextField.isEnabled = isEmailUpdateMode
        editProfileView.nameTextField.isEnabled = !isEmailUpdateMode
        editProfileView.passwordTextField.isEnabled = !isEmailUpdateMode
        editProfileView.reEnterPasswordTextField.isEnabled = !isEmailUpdateMode
        editProfileView.profileImageButton.isEnabled = !isEmailUpdateMode
        
        // Optionally update visual feedback (e.g., background color or border)
        editProfileView.emailTextField.backgroundColor = isEmailUpdateMode ? .white : .lightGray
        editProfileView.nameTextField.backgroundColor = !isEmailUpdateMode ? .white : .lightGray
        editProfileView.passwordTextField.backgroundColor = !isEmailUpdateMode ? .white : .lightGray
        editProfileView.reEnterPasswordTextField.backgroundColor = !isEmailUpdateMode ? .white : .lightGray
    }
    
    private func setupActions() {
        // Assign actions for buttons
        editProfileView.registerButton.addTarget(self, action: #selector(saveChangesTapped), for: .touchUpInside)
        editProfileView.profileImageButton.addTarget(self, action: #selector(showImagePickerMenu), for: .touchUpInside)
    }
    
    // MARK: - Profile Image Selection
    @objc func showImagePickerMenu() {
        let alertController = UIAlertController(title: "Select Photo", message: nil, preferredStyle: .actionSheet)

        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            self.presentImagePicker(sourceType: .camera)
        }

        let galleryAction = UIAlertAction(title: "Gallery", style: .default) { _ in
            self.presentImagePicker(sourceType: .photoLibrary)
        }

        alertController.addAction(cameraAction)
        alertController.addAction(galleryAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alertController, animated: true)
    }
    
    func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = sourceType
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true)
        } else {
            showError("\(sourceType == .camera ? "Camera" : "Photo Library") Not Available")
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true) {
            if let selectedImage = info[.originalImage] as? UIImage {
                let cropViewController = TOCropViewController(image: selectedImage)
                cropViewController.delegate = self
                // Set the aspect ratio to square
                cropViewController.aspectRatioPreset = .presetSquare
                cropViewController.aspectRatioLockEnabled = true // Lock the aspect ratio to square
                cropViewController.resetAspectRatioEnabled = false // Prevent the user from changing the ratio
                
                self.present(cropViewController, animated: true, completion: nil)
            }
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    // MARK: - TOCropViewControllerDelegate
    func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
        DispatchQueue.main.async {
            let editedImage = image.withRenderingMode(.alwaysOriginal)
            self.setProfileImageButton(editedImage)
            self.selectedImage = editedImage
        }
        cropViewController.dismiss(animated: true)
    }

    func cropViewControllerDidCancel(_ cropViewController: TOCropViewController) {
        cropViewController.dismiss(animated: true)
    }
    
    func setProfileImageButton(_ image: UIImage) {
        // Set the button's image
        editProfileView.profileImageButton.setImage(image, for: .normal)
        
        // Ensure the image fills the button
        editProfileView.profileImageButton.imageView?.contentMode = .scaleAspectFill
        
        // Clip to the button's circular bounds
        editProfileView.profileImageButton.clipsToBounds = true
        
        // Ensure the button is circular
        editProfileView.profileImageButton.layer.cornerRadius = editProfileView.profileImageButton.frame.size.width / 2
        editProfileView.profileImageButton.layer.masksToBounds = true
    }

    func resizeImage(_ image: UIImage, to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, image.scale)
        image.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }

    // MARK: - Handle Return Key on Keyboard
    private func setupGestureToDismissKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupTextFieldDelegates() {
        for subview in view.subviews {
            if let textField = subview as? UITextField {
                textField.delegate = self
            }
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Dismiss the keyboard
        return true
    }
    // MARK: - Save Changes
    @objc public func saveChangesTapped() {
        if isEmailUpdateMode {
            // Email Update Logic
            guard let email = editProfileView.emailTextField.text, isValidEmail(email) else {
                showError("Please enter a valid email.")
                return
            }

            // Proceed with email update
            updateEmailTapped()
        } else {
            // Other Info Update Logic
            guard let displayName = editProfileView.nameTextField.text,
                  let password = editProfileView.passwordTextField.text,
                  let reEnterPassword = editProfileView.reEnterPasswordTextField.text else {
                showError("All fields are required.")
                return
            }

            guard password == reEnterPassword else {
                showError("Passwords do not match.")
                return
            }

            let profileImage = selectedImage ?? UIImage(systemName: "person.fill")!
            updateOtherInfoTapped()
        }
        
    }
    
    @objc private func updateEmailTapped() {
        guard let email = editProfileView.emailTextField.text, isValidEmail(email) else {
            showError("Please enter a valid email.")
            return
        }
        
        if Auth.auth().currentUser?.email == editProfileView.emailTextField.text {
            showError("Please enter a valid email.")
            return
        }

        let alertController = UIAlertController(title: "Confirm Email Change", message: "Changing your email will log you out. Do you want to proceed?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addAction(UIAlertAction(title: "Change", style: .destructive) { _ in
            self.updateEmail(email)
        })
        present(alertController, animated: true)
    }
    
    @objc private func updateOtherInfoTapped() {
        guard let displayName = editProfileView.nameTextField.text,
              let password = editProfileView.passwordTextField.text,
              let reEnterPassword = editProfileView.reEnterPasswordTextField.text else {
            showError("All fields are required.")
            return
        }

        guard password == reEnterPassword else {
            showError("Passwords do not match.")
            return
        }

        let profileImage = selectedImage ?? UIImage(systemName: "person.fill")!
        updateOtherProfileDetails(user: user, displayName: displayName, password: password, profileImage: profileImage)
    }
    
    //MARK: - EMAIL UPDATE
    private func updateEmail(_ email: String) {
        guard let user = Auth.auth().currentUser else {
            showError("User not logged in.")
            return
        }
        
        
        // Re-authenticate the user
        let alertController = UIAlertController(title: "Re-Authenticate", message: "Please enter your password to confirm email change.", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        let db = Firestore.firestore()
        db.collection("users").document(self.user.uid).updateData([
            "email": email
        ]) { error in
            if let error = error {
                self.showError("Error updating user email: \(error.localizedDescription)")
            } else {
                print("User email successfully updated!")
            }
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addAction(UIAlertAction(title: "Confirm", style: .default) { _ in
            guard let password = alertController.textFields?.first?.text, !password.isEmpty else {
                self.showError("Password cannot be empty.")
                self.hideWaitIndicator()
                return
            }

            let credential = EmailAuthProvider.credential(withEmail: user.email ?? "", password: password)
            user.reauthenticate(with: credential) { [weak self] _, error in
                if let error = error {
                    self?.showError("Re-authentication failed: \(error.localizedDescription)")
                    self!.hideWaitIndicator()
                    return
                }

                user.sendEmailVerification(beforeUpdatingEmail: email) { error in
                    if let error = error {
                        self?.showError("Failed to send verification email: \(error.localizedDescription)")
                        self!.hideWaitIndicator()
                        return
                    }

                    self?.waitForEmailVerification(user: self!.user, newEmail: email, displayName: "", password: "", profileImage: UIImage())
                }
            }
        })

        present(alertController, animated: true)
    }
    


    private func waitForEmailVerification(user: User, newEmail: String, displayName: String, password: String, profileImage: UIImage) {
        var retryCount = 0
        let maxRetries = 60

        // Begin background task
        var backgroundTask: UIBackgroundTaskIdentifier = .invalid
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "EmailVerificationTask") {
            // End the task if time expires
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }

        guard backgroundTask != .invalid else {
            print("Failed to start background task.")
            return
        }
        
        showWaitIndicator(withMessage: "Waiting for email verification...")
        
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            retryCount += 1
            if retryCount > maxRetries {
                timer.invalidate()
                self.hideWaitIndicator()
                self.showError("Email verification timed out. Please try again later.")
                
                UIApplication.shared.endBackgroundTask(backgroundTask)
                backgroundTask = .invalid
                return
            }
            Auth.auth().currentUser?.reload { error in
                if let error = error {
                    timer.invalidate()
                    self.hideWaitIndicator()
                    // Check if the error is due to user being signed out
                    self.logout() // Log the user out locally
                    UIApplication.shared.endBackgroundTask(backgroundTask)
                    backgroundTask = .invalid
                    return
                } else {
                    //self.showError("Failed to reload user, Please Retry some other times")
                }

            }
        }
    }
    
    // MARK: - Other info save
    private func updateOtherProfileDetails(user: User, displayName: String, password: String, profileImage: UIImage) {
        guard let currentUser = Auth.auth().currentUser else {
            showError("User not logged in.")
            return
        }
        
        showWaitIndicator(withMessage: "Updating profile...")
        
        // Prompt for re-authentication
        let alertController = UIAlertController(title: "Re-Authenticate", message: "Please enter your password to confirm changes.", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { [weak self] _ in
            guard let self = self else { return }
            guard let currentPassword = alertController.textFields?.first?.text, !currentPassword.isEmpty else {
                self.showError("Password cannot be empty.")
                return
            }

            // Re-authenticate the user
            let credential = EmailAuthProvider.credential(withEmail: currentUser.email ?? "", password: currentPassword)
            currentUser.reauthenticate(with: credential) { _, error in
                if let error = error {
                    self.showError("Re-authentication failed: \(error.localizedDescription)")
                    self.hideWaitIndicator()
                    return
                }

                // Proceed with updates after successful re-authentication
                self.performProfileDetailsUpdate(user: self.user, displayName: displayName, password: password, profileImage: profileImage)
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }

    private func performProfileDetailsUpdate(user: User, displayName: String, password: String, profileImage: UIImage) {
        // Update display name
        var backgroundTask: UIBackgroundTaskIdentifier = .invalid
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "INFO CHANING WAIT") {
            // End the task if time expires
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }

        guard backgroundTask != .invalid else {
            print("Failed to start background task.")
            return
        }
        
        let user = Auth.auth().currentUser
        let changeRequest = user!.createProfileChangeRequest()
        changeRequest.displayName = displayName
        changeRequest.commitChanges { [weak self] error in
            if let error = error {
                self?.showError("Failed to update display name: \(error.localizedDescription)")
                return
            }

            // Update password
            user!.updatePassword(to: password) { error in
                if let error = error {
                    self?.showError("Failed to update password: \(error.localizedDescription)")
                    return
                }

                // Update Firestore with the new details
                let db = Firestore.firestore()
                db.collection("users").document(user!.uid).updateData([
                    "displayName": displayName,
                    "email": self?.user.email ?? ""
                ]) { error in
                    if let error = error {
                        self?.showError("Failed to update Firestore: \(error.localizedDescription)")
                        return
                    }

                    // Update profile image
                    self?.updateProfileImage(user!.uid, image: profileImage) { success in
                        if success {
                            self?.user.displayName = displayName
                            self!.hideWaitIndicator()
                            self?.showSuccess("Profile updated successfully!")
                        } else {
                            self!.hideWaitIndicator()
                            self?.showError("Failed to update profile image.")
                        }
                    }
                }
            }
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func updateProfileImage(_ userId: String, image: UIImage, completion: @escaping (Bool) -> Void) {
        let storageRef = Storage.storage().reference().child("profile_images").child("\(userId).jpg")
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            showError("Failed to process image data.")
            completion(false)
            return
        }
        
        // Upload image to Firebase Storage
        storageRef.putData(imageData, metadata: nil) { [weak self] _, error in
            if let error = error {
                self?.showError("Failed to upload profile image: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            // Retrieve the download URL
            storageRef.downloadURL { [weak self] url, error in
                if let error = error {
                    self?.showError("Failed to get profile image URL: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                guard let profileImageUrl = url else {
                    self?.showError("Failed to retrieve profile image URL.")
                    completion(false)
                    return
                }
                
                // Update Firestore with the new profile image URL
                let db = Firestore.firestore()
                db.collection("users").document(userId).updateData([
                    "profileImageUrl": profileImageUrl.absoluteString
                ]) { error in
                    if let error = error {
                        self?.showError("Failed to update Firestore with image URL: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        // Cache the image locally
                        ProfileImageCache.shared.saveImage(image, for: userId)
                        self?.showSuccess("Profile updated successfully!")
                        completion(true)
                    }
                }
            }
        }
    }
    
    // MARK: - Helpers
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showSuccess(_ message: String) {
        let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
    
    private func showAlert(message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
    
    private func showWaitIndicator(withMessage message: String) {
        // Disable user interaction
        view.isUserInteractionEnabled = false

        // Add a dimming view to freeze other parts
        let dimmingView = UIView(frame: view.bounds)
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        dimmingView.tag = 100 // Set a tag to remove it later
        view.addSubview(dimmingView)

        // Add the indicator
        view.addSubview(waitIndicator)
        NSLayoutConstraint.activate([
            waitIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            waitIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        waitIndicator.startAnimating()

        // Optional: Add a label for additional context
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.textColor = .white
        messageLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        dimmingView.addSubview(messageLabel)
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: waitIndicator.bottomAnchor, constant: 20),
            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func hideWaitIndicator() {
        view.isUserInteractionEnabled = true
        waitIndicator.stopAnimating()
        waitIndicator.removeFromSuperview()

        // Remove the dimming view
        view.subviews.filter { $0.tag == 100 }.forEach { $0.removeFromSuperview() }
    }
    
    private func logout() {
        // Display an alert notifying the user about email changes and logout
        let alert = UIAlertController(
            title: "Email Changes Applied",
            message: "Your email changes have been saved. You will now be logged out to reauthenticate.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            // Perform logout after user acknowledges the alert
            do {
                self.loadingIndicator.startAnimating()
                try Auth.auth().signOut()
                DispatchQueue.main.async {
                    let previewVC = PreviewViewController()
                    // Preload content before navigating
                    previewVC.preloadContent {
                        let navigationController = UINavigationController(rootViewController: previewVC)
                        self.loadingIndicator.stopAnimating()
                        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
                           let window = sceneDelegate.window {
                            window.rootViewController = navigationController
                            window.makeKeyAndVisible()
                        }
                    }
                }
            } catch let error {
                print("Failed to log out: \(error.localizedDescription)")
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // Present the alert
        
        self.present(alert, animated: true)

    }
    
    private func handleSignOutAfterEmailUpdate() {
        // Redirect the user to the login screen or perform necessary cleanup
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "Session Expired",
                message: "Your email has been updated successfully. Please log in again to continue.",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                let previewVC = PreviewViewController()
                let navigationController = UINavigationController(rootViewController: previewVC)
                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
                   let window = sceneDelegate.window {
                    window.rootViewController = navigationController
                    window.makeKeyAndVisible()
                }
            })
            
            self.present(alert, animated: true)
        }
    }
}
