//
//  LoginView.swift
//  assignment7
//
//  Created by firesalts on 10/23/24.
//
import Foundation
import UIKit

class LoginView: UIView {
    
    // MARK: - UI Elements
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
        return textField
    }()
    
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.setTitleColor(UIColor(named: "TextLeft"), for: .normal)
        button.layer.borderWidth = 2
        button.layer.backgroundColor = UIColor(named: "ButtonColorLeft")?.cgColor
        button.layer.cornerRadius = 8
        button.layer.borderColor = UIColor.bottomNavi.cgColor
        button.addTarget(nil, action: #selector(LoginViewController.loginTapped), for: .touchUpInside)
        return button
    }()
    
    let goToRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Register", for: .normal)
        button.setTitleColor(UIColor(named: "TextRight"), for: .normal)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.bottomNavi.cgColor
        button.layer.backgroundColor = UIColor.buttonColorRight.cgColor
        button.addTarget(nil, action: #selector(LoginViewController.goToRegister), for: .touchUpInside)
        return button
    }()
    
    let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(named: "BackgroundColor")
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func setupLayout() {
        addSubview(emailTextField)
        addSubview(passwordTextField)
        
        // Add buttons to the stack view
        buttonStackView.addArrangedSubview(goToRegisterButton)
        buttonStackView.addArrangedSubview(loginButton)
        addSubview(buttonStackView)
        
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emailTextField.centerXAnchor.constraint(equalTo: centerXAnchor),
            emailTextField.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            emailTextField.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            
            passwordTextField.centerXAnchor.constraint(equalTo: centerXAnchor),
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
            passwordTextField.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            
            // Button Stack View
            buttonStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            buttonStackView.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 16),
            buttonStackView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            buttonStackView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}
