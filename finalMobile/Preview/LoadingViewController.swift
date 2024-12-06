//
//  LoadingViewController.swift
//  finalMobile
//
//  Created by firesalts on 12/4/24.
//

import UIKit

class LoadingViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "BackgroundColor") 
        
        // Create and configure the image view
        let imageView = UIImageView(image: UIImage(named: "logoNoBC"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the image view to the view hierarchy
        view.addSubview(imageView)
        
        // Center the image view
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
        ])
    }
}
