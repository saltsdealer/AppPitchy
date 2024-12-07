//
//  PreviewViewController.swift
//  finalMobile
//
//  Created by firesalts on 11/14/24.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage



class PreviewViewController: UIViewController,  UIScrollViewDelegate {
    
    // MARK: - Properties
    private let previewView = PreviewView()
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private var carouselTexts: [String] = []
    private var carouselImages: [UIImage] = []
    private var currentPage = 0
    

    // MARK: - Custom Initializer
    init(preloadCompletion: (() -> Void)? = nil) {
        super.init(nibName: nil, bundle: nil)
        preloadContent {
            preloadCompletion?()
        }
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    

    
    // MARK: - Lifecycle
    override func loadView() {
        view = previewView
        
    }
    
    override func viewDidLoad() {
        // add login status check here
        super.viewDidLoad()
        checkIfUserIsLoggedIn()
        setupActions()
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.orientationLock = .portrait
        }
        //fetchCarouselContent()
        //self.updateCarousel()
        view.backgroundColor = UIColor(named: "BackgroundColor")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.updateCarousel()
        
    }
    
    // MARK: - Preloading Logic
    func preloadContent(completion: @escaping () -> Void) {
        let dispatchGroup = DispatchGroup()
        
        // Preload texts
        dispatchGroup.enter()
        fetchTextsFromFirestore { [weak self] in
            self?.carouselTexts = $0
            dispatchGroup.leave()
        }
        
        // Preload images
        dispatchGroup.enter()
        fetchImagesFromStorage { [weak self] in
            self?.carouselImages = $0
            print("loaded images: ", self?.carouselImages)
            dispatchGroup.leave()
        }
        
        // Notify when all preloading tasks are done
        dispatchGroup.notify(queue: .main) {
            print("Preloading complete")
            completion()
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Reset the orientation lock to allow other orientations
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.orientationLock = .all // Allow all orientations
        }
    }
    
    // MARK: - Login Status Check
    private func checkIfUserIsLoggedIn() {
        // Check if there is a current Firebase user
        if let currentUser = Auth.auth().currentUser {
            // User is logged in, navigate to HomeViewController
            DispatchQueue.main.async {
                let mainVC = MainContainerViewController()
                let navigationController = UINavigationController(rootViewController: mainVC)
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
    
    // MARK: - Setup Actions
    private func setupActions() {
        previewView.registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        previewView.loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        previewView.pageControl.addTarget(self, action: #selector(pageControlChanged), for: .valueChanged)
        previewView.carouselScrollView.delegate = self
        
    }
    
    // MARK: - Actions
    @objc func registerTapped() {
        // Check if RegisterViewController is already in the navigation stack
        if let existingRegisterVC = navigationController?.viewControllers.first(where: { $0 is RegisterViewController }) {
            // Navigate to the existing instance
            navigationController?.popToViewController(existingRegisterVC, animated: true)
        } else {
            // Otherwise, push a new instance of RegisterViewController
            let registerVC = RegisterViewController()
            navigationController?.pushViewController(registerVC, animated: true)
        }
    }
    
    @objc func loginTapped() {
        // Check if LoginViewController is already in the navigation stack
        if let existingLoginVC = navigationController?.viewControllers.first(where: { $0 is LoginViewController }) {
            // Navigate to the existing instance
            navigationController?.popToViewController(existingLoginVC, animated: true)
        } else {
            // Otherwise, push a new instance of LoginViewController
            let loginVC = LoginViewController()
            navigationController?.pushViewController(loginVC, animated: true)
        }
    }
    
    // MARK: - Firebase Fetching
    private func fetchTextsFromFirestore(completion: @escaping ([String]) -> Void) {
        db.collection("previews").document("11_30_previews_text").getDocument { document, error in
            if let error = error {
                print("Error fetching texts: \(error)")
                completion(["Default Text 1", "Default Text 2", "Default Text 3"])
                return
            }
            
            guard let document = document, document.exists else {
                completion(["Default Text 1", "Default Text 2", "Default Text 3"])
                return
            }
            
            let fields = document.data() ?? [:]
            let sortedTextFields = fields
                .filter { $0.key.hasPrefix("text") && $0.value is String }
                .sorted { key1, key2 in
                    let num1 = Int(key1.key.replacingOccurrences(of: "text", with: "")) ?? 0
                    let num2 = Int(key2.key.replacingOccurrences(of: "text", with: "")) ?? 0
                    return num1 < num2
                }
                .map { ($0.value as! String).replacingOccurrences(of: "\\n", with: "\n") }
            
            completion(Array(sortedTextFields.prefix(3)))
        }
    }
    
    private func fetchImagesFromStorage(completion: @escaping ([UIImage]) -> Void) {
        print("Starting fetchImagesFromStorage...")
        let storageRef = storage.reference().child("preview_pics")
        print("Storage reference created: \(storageRef)")
        
        storageRef.listAll { result, error in
            if let error = error {
                print("Error listing storage files: \(error)")
                completion([UIImage(systemName: "person.fill")!, UIImage(systemName: "person.fill")!, UIImage(systemName: "person.fill")!])
                return
            }
            
            let items = result?.items
            
            var fetchedImages: [UIImage] = []
            let dispatchGroup = DispatchGroup()
            
            for ref in items!.prefix(3) {
                dispatchGroup.enter()
                ref.getData(maxSize: 10 * 1024 * 1024) { data, error in
                    if let data = data, let image = UIImage(data: data) {
                        fetchedImages.append(image)
                    }
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                while fetchedImages.count < 3 {
                    fetchedImages.append(UIImage(systemName: "logoNoBC")!)
                }
                completion(fetchedImages)
            }
        }
    }
//    // MARK: - Firebase Fetching
//    func fetchCarouselContent() {
//        fetchTextsFromFirestore()
//        fetchImagesFromStorage()
//    }
//    
//    private func fetchTextsFromFirestore() {
//        db.collection("previews").document("11_30_previews_text").getDocument { [weak self] document, error in
//            guard let self = self else { return }
//            if let error = error {
//                print("Error fetching texts: \(error)")
//                return
//            }
//            
//            guard let document = document, document.exists else {
//                print("Document does not exist.")
//                return
//            }
//            
//            // Get all fields in the document
//            let fields = document.data() ?? [:]
//            
//            // Filter keys that start with "text" and extract the number for sorting
//            let sortedTextFields = fields
//                .filter { $0.key.hasPrefix("text") && $0.value is String } // Only include text fields
//                .sorted { key1, key2 in
//                    let num1 = Int(key1.key.replacingOccurrences(of: "text", with: "")) ?? 0
//                    let num2 = Int(key2.key.replacingOccurrences(of: "text", with: "")) ?? 0
//                    return num1 < num2
//                }
//            
//            // Map the sorted fields to strings and take the latest 3
//            self.carouselTexts = sortedTextFields
//                .map { ($0.value as! String).replacingOccurrences(of: "\\n", with: "\n") }
//                .prefix(3) // Take the first three sorted values
//                .map { $0 }
//            // Update the carousel
//            self.updateCarousel()
//        }
//    }
//    
//    private func fetchImagesFromStorage() {
//        let storageRef = storage.reference().child("preview_pics")
//        storageRef.listAll { [weak self] result, error in
//            guard let self = self else { return }
//            if let error = error {
//                print("Error listing storage files: \(error)")
//                return
//            }
//            
//            guard let items = result?.items else {
//                print("No images found.")
//                return
//            }
//            
//            // Sort image references based on numbers in their names (e.g., "pic1", "pic2")
//            let sortedImageRefs = items.sorted { ref1, ref2 in
//                let num1 = Int(ref1.name.replacingOccurrences(of: "pic", with: "").replacingOccurrences(of: ".jpg", with: "").replacingOccurrences(of: ".png", with: "")) ?? 0
//                let num2 = Int(ref2.name.replacingOccurrences(of: "pic", with: "").replacingOccurrences(of: ".jpg", with: "").replacingOccurrences(of: ".png", with: "")) ?? 0
//                return num1 < num2
//            }.prefix(3) // Take the first 3 sorted references
//            
//            let dispatchGroup = DispatchGroup()
//             var fetchedImages: [UIImage] = []
//             
//             for ref in sortedImageRefs.prefix(3) { // Fetch up to 3 images
//                 dispatchGroup.enter()
//                 ref.getData(maxSize: 10 * 1024 * 1024) { data, error in
//                     if let data = data, let image = UIImage(data: data) {
//                         fetchedImages.append(image)
//                     }
//                     if let error = error {
//                         print("Error fetching image: \(error)")
//                     }
//                     dispatchGroup.leave()
//                 }
//             }
//             
//             dispatchGroup.notify(queue: .main) {
//                 // Use the fetched images, or fill with placeholders if fewer than 3 images were fetched
//                 while fetchedImages.count < 3 {
//                     fetchedImages.append(UIImage(systemName: "person.fill")!)
//                 }
//
//                 self.carouselImages = fetchedImages
//                 self.updateCarousel()
//             }
//         }
//    }
    
    // MARK: - Carousel Update
    @objc func pageControlChanged() {
        let page = CGFloat(previewView.pageControl.currentPage)
        let offset = CGPoint(x: page * previewView.carouselScrollView.frame.width, y: 0)
        
        previewView.carouselScrollView.setContentOffset(offset, animated: true)
    }
    
    private func updateCarousel() {
        print("updateCarousel called") 
        previewView.populateCarousel(with: carouselImages)
        previewView.pageControl.numberOfPages = carouselImages.count
        
        let currentPage = previewView.pageControl.currentPage
        if carouselTexts.indices.contains(currentPage) {
            previewView.carouselTextLabel.text = carouselTexts[currentPage]
        }
        

    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
        previewView.pageControl.currentPage = page
        
        if carouselTexts.indices.contains(page) {
            previewView.carouselTextLabel.text = carouselTexts[page]
        }
        
    }
    
}
