//
//  PostView.swift
//  finalMobile
//
//  Created by firesalts on 11/24/24.
//

import UIKit

class PostView: UIView {
    
    // MARK: - UI Elements
    let tableTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Posts"
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.textColor = UIColor(named: "TextMiddle") ?? .black
        label.textAlignment = .center
        label.layer.cornerRadius = 8
//        label.layer.borderWidth = 2
//        label.layer.borderColor = UIColor.bottomNavi.cgColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let addPostButton: UIButton = {
        let button = UIButton(type: .system)
        let plusIcon = UIImage(systemName: "plus") // Use a system "+" icon
        button.setImage(plusIcon, for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.bottomNavi
        button.layer.cornerRadius = 30
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = UIColor(named: "BackgroundColor")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .red
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    private func setupView() {
        backgroundColor = UIColor(named: "BackgroundColor")
        // Add subviews
        addSubview(tableTitleLabel)
        addSubview(tableView)
        addSubview(addPostButton)
        
        bringSubviewToFront(addPostButton)
        // Configure layout constraints
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // TableView Constraints
            // Table Title Constraints
            tableTitleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
            tableTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            tableTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            tableView.topAnchor.constraint(equalTo: tableTitleLabel.bottomAnchor,constant: 10),
            tableView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            // Floating Button Constraints
            addPostButton.widthAnchor.constraint(equalToConstant: 60),
            addPostButton.heightAnchor.constraint(equalToConstant: 60),
            addPostButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            addPostButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
        ])
    }
}

