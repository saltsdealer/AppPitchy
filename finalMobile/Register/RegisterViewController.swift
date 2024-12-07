//
//  RegisterViewController.swift
//  assignment7
//
//  Created by firesalts on 10/23/24.
//

import Foundation
import UIKit
import PhotosUI
import TOCropViewController
import Firebase
import FirebaseFirestore
import FirebaseAuth

class RegisterViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate,TOCropViewControllerDelegate {

    

    private let registerView = RegisterView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    var selectedImage = UIImage(systemName: "person.fill")
    
    override func loadView() {
        view = registerView
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Register"

        setupGestureToDismissKeyboard()
        setupTextFieldDelegates()
        setupTextFields()
        setupActivityIndicator()
        
        registerView.profileImageButton.addTarget(self, action: #selector(showImagePickerMenu), for: .touchUpInside)
    }
    
    private func setupActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        // Center the activity indicator in the view
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    
    // MARK: - Setup
    private func setupTextFields() {
        registerView.emailTextField.delegate = self
        registerView.nameTextField.delegate = self
        registerView.passwordTextField.delegate = self
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
            imagePicker.allowsEditing = false // Allow editing the selected or captured image
            present(imagePicker, animated: true)
        } else {
            showAlert(title: "\(sourceType == .camera ? "Camera" : "Photo Library") Not Available",
                      message: "This device does not support the selected source type.")
        }
    }

    // MARK: - UIImagePickerControllerDelegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
         picker.dismiss(animated: true) {
             if let selectedImage = info[.originalImage] as? UIImage {
                 // Present TOCropViewController with the selected image
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

     // MARK: - TOCropViewControllerDelegate Methods
    func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
         // Handle the cropped image
        DispatchQueue.main.async {
            let editedImage = image.withRenderingMode(.alwaysOriginal)
            self.setProfileImageButton(editedImage)
            self.selectedImage = editedImage
        }
        cropViewController.dismiss(animated: true)
     }

     func cropViewControllerDidCancel(_ cropViewController: TOCropViewController) {
         // Dismiss the crop view controller if canceled
         cropViewController.dismiss(animated: true)
     }
    
    // Set the image on the button and ensure it fills the circle
    func setProfileImageButton(_ image: UIImage) {
        // Set the button's image
        registerView.profileImageButton.setImage(image, for: .normal)
        
        // Ensure the image fills the button
        registerView.profileImageButton.imageView?.contentMode = .scaleAspectFill
        
        // Clip to the button's circular bounds
        registerView.profileImageButton.clipsToBounds = true
        
        // Ensure the button is circular
        registerView.profileImageButton.layer.cornerRadius = registerView.profileImageButton.frame.size.width / 2
        registerView.profileImageButton.layer.masksToBounds = true
    }

    
    // MARK: - Actions
    @objc func registerTapped() {
        guard let name = registerView.nameTextField.text, !name.isEmpty,
              let email = registerView.emailTextField.text, !email.isEmpty,
              let password = registerView.passwordTextField.text, !password.isEmpty,
              let reEnterPassword = registerView.reEnterPasswordTextField.text, !reEnterPassword.isEmpty  else {
            showAlert(message: "Please fill in all fields")
            return
        }

        // Validate email
        guard isValidEmail(email) else {
            showAlert(message: "Please enter a valid email")
            return
        }
        
        guard reEnterPassword == password else {
            showAlert(message: "Please enter matching passwords")
            return
        }
        
        activityIndicator.startAnimating()
        // Check for unique email and displayName in Firestore
        let db = Firestore.firestore()
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { emailQuerySnapshot, emailError in
            guard emailError == nil else {
                self.activityIndicator.stopAnimating()
                self.showAlert(message: "Error checking email: \(emailError!.localizedDescription)")
                return
            }
            
            if let emailDocuments = emailQuerySnapshot?.documents, !emailDocuments.isEmpty {
                self.activityIndicator.stopAnimating()
                self.showAlert(message: "This email is already in use.")
                return
            }
            
            db.collection("users").whereField("displayName", isEqualTo: name).getDocuments { nameQuerySnapshot, nameError in
                guard nameError == nil else {
                    self.activityIndicator.stopAnimating()
                    self.showAlert(message: "Error checking display name: \(nameError!.localizedDescription)")
                    return
                }
                
                if let nameDocuments = nameQuerySnapshot?.documents, !nameDocuments.isEmpty {
                    self.activityIndicator.stopAnimating()
                    self.showAlert(message: "This display name is already in use.")
                    return
                }
                
                // If both are unique, proceed with registration
                self.registerUser(email: email, password: password, displayName: name, profileImage: (self.selectedImage)!) { result in
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        switch result {
                        case .success(let message):
                            self.showAlertWithCompletion(title: "Success", message: message) {
                                self.redirectToHomeScreen()
                            }
                        case .failure(let error):
                            self.showAlert(title: "Registration Failed", message: error.localizedDescription)
                        }
                    }
                }
            }
        }
    }

    // Helper method to validate email format
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }


    
    // Updated showAlert method to include a completion handler
    private func showAlert(message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    private func showAlertWithCompletion(title: String, message: String, completion: @escaping () -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion()
        })
        present(alertController, animated: true, completion: nil)
    }

    // Redirect to login screen after successful registration
    private func redirectToLoginScreen() {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        } else {
            let loginViewController = LoginViewController() // Initialize your login view controller here
            loginViewController.modalPresentationStyle = .fullScreen
            present(loginViewController, animated: true, completion: nil)
        }
    }
    
    // Redirect to home screen after successful registration
    private func redirectToHomeScreen() {
        let homeViewController = MainContainerViewController()
        let homeNavigationController = UINavigationController(rootViewController: homeViewController)
        homeNavigationController.modalPresentationStyle = .fullScreen
        
        // Set HomeViewController as the root view controller, removing the registration screen
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
           let window = sceneDelegate.window {
            window.rootViewController = homeNavigationController
            window.makeKeyAndVisible()
        } else {
            // Fallback in case the scene delegate isn't available (e.g., if using AppDelegate in older projects)
            present(homeNavigationController, animated: true, completion: nil)
        }
    }

}

