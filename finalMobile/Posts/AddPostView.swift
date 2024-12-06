//
//  AddPostView.swift
//  finalMobile
//
//  Created by firesalts on 11/24/24.
//

import Foundation

import UIKit


class AddPostView: UIView {
    let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Close", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 8
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    let wordCountLabel: UILabel = {
        let label = UILabel()
        label.text = "250 characters remaining"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let imageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.minimumLineSpacing = 10
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    let addImagesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Images", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 8
        button.backgroundColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Submit Post", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.backgroundColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var buttonTopConstraint: NSLayoutConstraint! // Dynamic constraint
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = UIColor.systemGray6
        addSubview(closeButton)
        addSubview(textView)
        addSubview(wordCountLabel)
        addSubview(imageCollectionView)
        addSubview(addImagesButton)
        addSubview(submitButton)
        
        // Constraints for Close Button
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
        
        // Constraints for TextView and Other Elements
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            textView.heightAnchor.constraint(equalToConstant: 150),
            
            wordCountLabel.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 8),
            wordCountLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            imageCollectionView.topAnchor.constraint(equalTo: wordCountLabel.bottomAnchor, constant: 20),
            imageCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            imageCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            imageCollectionView.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        // Dynamic button position constraint
        buttonTopConstraint = addImagesButton.topAnchor.constraint(equalTo: imageCollectionView.bottomAnchor, constant: 20)
        
        NSLayoutConstraint.activate([
            buttonTopConstraint,
            addImagesButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            addImagesButton.trailingAnchor.constraint(equalTo: centerXAnchor, constant: -10),
            addImagesButton.heightAnchor.constraint(equalToConstant: 50),
            
            submitButton.topAnchor.constraint(equalTo: addImagesButton.topAnchor),
            submitButton.leadingAnchor.constraint(equalTo: centerXAnchor, constant: 10),
            submitButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            submitButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}
