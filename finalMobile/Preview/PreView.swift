//
//  PreView.swift
//  finalMobile
//
//  Created by firesalts on 11/14/24.
//

import Foundation
import UIKit

class PreviewView: UIView {
    
    // MARK: - UI Elements
    
    // Top logo
    let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logoNoBC") // Placeholder for the logo
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // Scroll view for the carousel
    let carouselScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    // Carousel text label
    let carouselTextLabel: UILabel = {
        let label = UILabel()
        label.text = "Oh hello!\nStart Pitching Today! :)"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    // Page control for the carousel
    let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = 3 // Assume 3 slides for now
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .black
        return pageControl
    }()
    
    // Register button
    let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Register", for: .normal)
        button.setTitleColor(UIColor.textLeft, for: .normal)
        button.backgroundColor = UIColor.buttonColorLeft
        button.layer.borderWidth = 2
        button.layer.backgroundColor = UIColor.buttonColorLeft.cgColor
        button.layer.cornerRadius = 8
        button.addTarget(nil, action: #selector(PreviewViewController.registerTapped), for: .touchUpInside)
        return button
    }()
    
    // Log In button
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.setTitleColor(UIColor.textRight, for: .normal)
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.bottomNavi.cgColor
        button.layer.cornerRadius = 8
        button.layer.backgroundColor = UIColor.buttonColorRight.cgColor
        button.addTarget(nil, action: #selector(PreviewViewController.loginTapped), for: .touchUpInside)
        return button
    }()
    
    // Stack view for the buttons
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
        addSubview(logoImageView)
        //addSubview(carouselImageView)
        addSubview(carouselScrollView)
        addSubview(carouselTextLabel)
        addSubview(pageControl)
        
        buttonStackView.addArrangedSubview(registerButton)
        buttonStackView.addArrangedSubview(loginButton)
        addSubview(buttonStackView)
        
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        //carouselImageView.translatesAutoresizingMaskIntoConstraints = false
        carouselScrollView.translatesAutoresizingMaskIntoConstraints = false
        carouselTextLabel.translatesAutoresizingMaskIntoConstraints = false
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Logo Image View
            logoImageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            logoImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            logoImageView.widthAnchor.constraint(equalToConstant: 100),
            logoImageView.heightAnchor.constraint(equalToConstant: 60),
            
            // Carousel Scroll View
            carouselScrollView.centerXAnchor.constraint(equalTo: centerXAnchor),
            carouselScrollView.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 40),
            carouselScrollView.widthAnchor.constraint(equalTo: widthAnchor),
            carouselScrollView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 0.6),
            
            // Carousel Text Label
            carouselTextLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            //carouselTextLabel.topAnchor.constraint(equalTo: carouselImageView.bottomAnchor, constant: 20),
            carouselTextLabel.topAnchor.constraint(equalTo: carouselScrollView.bottomAnchor, constant: 20),
            carouselTextLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            
            // Page Control
            pageControl.centerXAnchor.constraint(equalTo: centerXAnchor),
            pageControl.topAnchor.constraint(equalTo: carouselTextLabel.bottomAnchor, constant: 20),
            
            // Button Stack View
            buttonStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            buttonStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -30),
            buttonStackView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            buttonStackView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Populate Carousel
    func populateCarousel(with images: [UIImage]) {
        
        carouselScrollView.subviews.forEach { $0.removeFromSuperview() }
        
        layoutIfNeeded() // Ensure layout is up-to-date
        let scrollViewWidth = carouselScrollView.frame.width
        let scrollViewHeight = carouselScrollView.frame.height

        guard scrollViewWidth > 0 && scrollViewHeight > 0 else {
            return
        }
        
        for (index, image) in images.enumerated() {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.frame = CGRect(
                x: scrollViewWidth * CGFloat(index),
                y: 0,
                width: scrollViewWidth,
                height: scrollViewHeight
            )
            carouselScrollView.addSubview(imageView)
        }

        carouselScrollView.contentSize = CGSize(
            width: scrollViewWidth * CGFloat(images.count),
            height: scrollViewHeight
        )
        print("Carousel content size: \(carouselScrollView.contentSize)")
        pageControl.numberOfPages = images.count
    }
}
