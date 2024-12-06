//
//  ProfileViewController.swift
//  finalMobile
//
//  Created by firesalts on 11/20/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class ProfileViewController: UIViewController {
    
    // MARK: - Properties
    private let profileView = ProfileView()
    private let user: User
    var onEditTriggered: (() -> Void)?
    
    // MARK: - Initializer
    init(user: User) {
         self.user = user
         super.init(nibName: nil, bundle: nil)
     }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func loadView() {
        view = profileView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayUserData()
        // Add action to the Edit button
        profileView.editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        profileView.changeEmailButton.addTarget(self, action: #selector(changeEmailTapped), for: .touchUpInside)
    }
    
    // MARK: - Display User Data
    private func displayUserData() {
        let current = Auth.auth().currentUser
        profileView.displayNameLabel.text = current?.displayName
        profileView.emailLabel.text = "EMAIL: \(String((current?.email)!))"
        profileView.usernameLabel.text = "USER: \(String((current?.displayName)!))"
        // Load image from local file path
        let imagePath = user.profileImageUrl
        if FileManager.default.fileExists(atPath: imagePath) {
            if let image = UIImage(contentsOfFile: imagePath) {
                print("Image loaded successfully: \(image)")
                self.setProfileImage(image)
            } else {
                print("Failed to load image from local file: \(imagePath)")
            }
        } else {
            print("Image file does not exist at path: \(imagePath)")
        }
    }
    
    // MARK: - Actions
    @objc private func editButtonTapped() {
        print("Edit button tapped")
        // Notify MainContainerViewController that an edit has been triggered
        // Check if user object is empty or invalid
         if user.displayName.isEmpty || user.email.isEmpty {
             showAlert(title: "Error", message: "User data is incomplete. Please reload or check your account.")
             return
         } else {
             // Navigate to EditProfileViewController
             let editProfileVC = EditProfileViewController(user: user)
             editProfileVC.isEmailUpdateMode = false
             navigationController?.pushViewController(editProfileVC, animated: true)
             
         }
        onEditTriggered?()
    }
    
    @objc private func changeEmailTapped() {
        print("Edit button tapped")
         if user.displayName.isEmpty || user.email.isEmpty {
             showAlert(title: "Error", message: "User data is incomplete. Please reload or check your account.")
             return
         } else {
             // Navigate to EditProfileViewController
             let editProfileVC = EditProfileViewController(user: user)
             editProfileVC.isEmailUpdateMode = true
             navigationController?.pushViewController(editProfileVC, animated: true)
             
         }
        onEditTriggered?()
    }
    
    
    func setProfileImage(_ image: UIImage) {
        if let circularImage = image.cropToCircle() {
            profileView.profileImageView.image = circularImage
        } else {
            print("Failed to crop image to circle")
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    

}
