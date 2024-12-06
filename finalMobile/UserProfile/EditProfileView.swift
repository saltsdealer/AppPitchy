//
//  EditProfileView.swift
//  finalMobile
//
//  Created by firesalts on 11/21/24.
//


import Foundation
import UIKit

class EditProfileView: UIView {
    
    // MARK: - UI Elements
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    let profileImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .gray
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        
        // Set the button’s size and make it circular
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 100).isActive = true
        button.heightAnchor.constraint(equalToConstant: 100).isActive = true
        button.layer.cornerRadius = 50
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lightGray.cgColor
        
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
        button.setTitle("Save", for: .normal)
        button.setTitleColor(UIColor.textRight, for: .normal)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.bottomNavi.cgColor
        button.layer.backgroundColor = UIColor.wordBubbleTheme.cgColor
        button.layer.masksToBounds = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
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
        backgroundColor = UIColor(named: "BackgroundColor") ?? .white
        
        // Add scrollView and contentView
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Add subviews to contentView
        contentView.addSubview(profileImageButton)
        contentView.addSubview(nameTextField)
        contentView.addSubview(emailTextField)
        contentView.addSubview(passwordTextField)
        contentView.addSubview(reEnterPasswordTextField)
        contentView.addSubview(registerButton)
        
        // Disable autoresizing masks
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        profileImageButton.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        reEnterPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Layout scrollView
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        // Layout contentView
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor) // Match width for no horizontal scroll
        ])
        
        // Layout subviews inside contentView
        NSLayoutConstraint.activate([
            // Profile Image Button
            profileImageButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            
            // Name TextField
            nameTextField.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            nameTextField.topAnchor.constraint(equalTo: profileImageButton.bottomAnchor, constant: 20),
            nameTextField.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8),
            
            // Email TextField
            emailTextField.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 16),
            emailTextField.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8),
            
            // Password TextField
            passwordTextField.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
            passwordTextField.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8),
            
            // Re-enter Password TextField
            reEnterPasswordTextField.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            reEnterPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 16),
            reEnterPasswordTextField.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8),
            
            // Register Button
            registerButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            registerButton.topAnchor.constraint(equalTo: reEnterPasswordTextField.bottomAnchor, constant: 16),
            registerButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8),
            registerButton.heightAnchor.constraint(equalToConstant: 50),
            registerButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20) // Ensure bottom spacing
        ])
    }
}
