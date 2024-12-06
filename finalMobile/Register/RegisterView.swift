//
//  RegisterView.swift
//  assignment7
//
//  Created by firesalts on 10/23/24.
//
// the keybaord improvement

import Foundation
import UIKit
class RegisterView: UIView {
    
    // MARK: - UI Elements
    
    let profileImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "person.fill"), for: .normal)
        button.tintColor = .gray
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Set the button’s size and make it circular
        button.widthAnchor.constraint(equalToConstant: 100).isActive = true
        button.heightAnchor.constraint(equalToConstant: 100).isActive = true
        button.layer.cornerRadius = 50
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lightGray.cgColor
        
        // Action to show image picker
        button.addTarget(nil, action: #selector(RegisterViewController.showImagePickerMenu), for: .touchUpInside)
        return button
    }()
    
    let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Name"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        return textField
    }()
    
    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.textContentType = .none
        return textField
    }()
    
    let reEnterPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Re-enter Password"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.textContentType = .none
        return textField
    }()
    
    let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Register", for: .normal)
        button.backgroundColor = UIColor(named: "ButtonColorLeft")
        button.setTitleColor(UIColor(named: "TextLeft"), for: .normal)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.bottomNavi.cgColor
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.addTarget(nil, action: #selector(RegisterViewController.registerTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func setupLayout() {
        addSubview(profileImageButton)
        addSubview(nameTextField)
        addSubview(emailTextField)
        addSubview(passwordTextField)
        addSubview(reEnterPasswordTextField)
        addSubview(registerButton)
        backgroundColor = UIColor(named: "BackgroundColor")
        profileImageButton.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        reEnterPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Profile Image Button
            profileImageButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            profileImageButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),

            
            // Name TextField
            nameTextField.centerXAnchor.constraint(equalTo: centerXAnchor),
            nameTextField.topAnchor.constraint(equalTo: profileImageButton.bottomAnchor, constant: 20),
            nameTextField.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            
            // Email TextField
            emailTextField.centerXAnchor.constraint(equalTo: centerXAnchor),
            emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 16),
            emailTextField.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            
            // Password TextField
            passwordTextField.centerXAnchor.constraint(equalTo: centerXAnchor),
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
            passwordTextField.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            
            // Re-enter Password TextField
            reEnterPasswordTextField.centerXAnchor.constraint(equalTo: centerXAnchor),
            reEnterPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 16),
            reEnterPasswordTextField.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            
            // Register Button
            registerButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            registerButton.topAnchor.constraint(equalTo: reEnterPasswordTextField.bottomAnchor, constant: 16),
            registerButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            registerButton.heightAnchor.constraint(equalToConstant: 50) 
        ])
    }

}
