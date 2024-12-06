//
//  LoginViewController.swift
//  assignment7
//
//  Created by firesalts on 10/23/24.
//
//

import Foundation
import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    private let loginView = LoginView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    override func loadView() {
        view = loginView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Login"
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 24, weight: .bold) // Set font size and weight
        ]
        // Check if the user is already logged in
        //checkIfUserIsLoggedIn()
        setupActivityIndicator()
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
    
    private func checkIfUserIsLoggedIn() {
        // Check if there is a current Firebase user
        if let currentUser = Auth.auth().currentUser {
            // User is logged in, navigate to HomeViewController
            DispatchQueue.main.async {
                let homeVC = HomeViewController()
                let navigationController = UINavigationController(rootViewController: homeVC)
                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                    sceneDelegate.window?.rootViewController = navigationController
                    sceneDelegate.window?.makeKeyAndVisible()
                }
            }
        } else {
            // No user is logged in; you may handle the case if needed, such as showing a login screen
            print("No user is currently logged in.")
        }
    }
    
    // MARK: - Actions
    @objc func loginTapped() {
        guard let email = loginView.emailTextField.text, !email.isEmpty,
              let password = loginView.passwordTextField.text, !password.isEmpty else {
                  showAlert(message: "Please enter email, password, and confirm your password")
            return
        }
        
        
        guard isValidEmail(email) else {
            showAlert(message: "Please enter a valid email address")
            return
        }
        
        activityIndicator.startAnimating()
        
        // Attempt to log in using Firebase Authentication
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            // Stop the activity indicator
            self?.activityIndicator.stopAnimating()
            
            if let error = error {
                // Show error alert if login fails
                self?.showAlert(message: "Login Failed: \(error.localizedDescription)")
            } else {
                // Navigate to HomeViewController upon successful login
                DispatchQueue.main.async {
                    let homeVC = MainContainerViewController()
                    let navigationController = UINavigationController(rootViewController: homeVC)
                    
                    // Set the home screen as the root view controller
                    if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
                       let window = sceneDelegate.window {
                        window.rootViewController = navigationController
                        window.makeKeyAndVisible()
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

    @objc func goToRegister() {
        let registerVC = RegisterViewController()
        navigationController?.pushViewController(registerVC, animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
