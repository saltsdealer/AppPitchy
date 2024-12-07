//
//  MainContainerViewController.swift
//  finalMobile
//
//  Created by firesalts on 11/20/24.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore
import AVFoundation

class MainContainerViewController: UIViewController {
    
    // MARK: - Properties
    private let toolbar = UIToolbar()
    private var currentViewController: UIViewController?
    private var currentUser: User?
    private var isUserLoaded = false
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .black
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupToolbar()
        setupLoadingIndicator()
        setupDropdownMenuButton()
        fetchUserIfNeeded()
    }
    
    // MARK: - Setup Toolbar
    private func setupToolbar() {
        // Set toolbar items
        let homeButton = UIBarButtonItem(
            image: UIImage(systemName: "house.fill"),
            style: .plain,
            target: self,
            action: #selector(homeTapped)
        )
        let profileButton = UIBarButtonItem(
            image: UIImage(systemName: "person.circle.fill"),
            style: .plain,
            target: self,
            action: #selector(profileTapped)
        )
        let postButton = UIBarButtonItem(
            image: UIImage(systemName: "square.and.pencil"),
            style: .plain,
            target: self,
            action: #selector(postTapped)
        )
        
                // Fixed width spacers to push buttons toward the middle
        let fixedSpacerLeft = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpacerLeft.width = 30 // Adjust this value to move buttons inward
        
        let fixedSpacerRight = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpacerRight.width = 30 // Adjust this value to move buttons inward
        
        let flexibleSpacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
                // Set toolbar items
        toolbar.items = [
            fixedSpacerLeft, homeButton, flexibleSpacer, postButton, flexibleSpacer, profileButton, fixedSpacerRight
        ]
        
        // Configure toolbar appearance
        toolbar.barTintColor = UIColor(named: "BottomNavi") 
        toolbar.tintColor = .white   // White buttons
        
        // Add toolbar to the view
        view.addSubview(toolbar)
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Setup Dropdown Menu Button
    private func setupDropdownMenuButton() {
        let dropdownButton = UIButton(type: .system)
        dropdownButton.setImage(UIImage(systemName: "ellipsis.circle"), for: .normal)
        dropdownButton.tintColor = UIColor.bottomNavi // Customize button color
        dropdownButton.showsMenuAsPrimaryAction = true // Attach menu for iOS 14+
        dropdownButton.menu = createDropdownMenu()
        
        // Add the button to the view
        view.addSubview(dropdownButton)
        
        // Set constraints for top-right position
        dropdownButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dropdownButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            dropdownButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            dropdownButton.heightAnchor.constraint(equalToConstant: 30),
            dropdownButton.widthAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    //MARK: - Setup indicator
    private func setupLoadingIndicator() {
        view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func showLoadingIndicator() {
        loadingIndicator.startAnimating()
    }

    private func hideLoadingIndicator() {
        loadingIndicator.stopAnimating()
    }

    // MARK: - Create Dropdown Menu
    private func createDropdownMenu() -> UIMenu {
        // Define menu actions
        let settingsAction = UIAction(title: "Appearence Switch", image: UIImage(systemName: "gearshape.fill")) { _ in
            self.openSettings()
        }
        let logoutAction = UIAction(title: "Logout", image: UIImage(systemName: "arrow.right.square")) { _ in
            self.logout()
        }
        let cleantAction = UIAction(title: "Clear Cache", image: UIImage(systemName: "eraser.fill")) { _ in
            self.clean()
        }
        // Create and return the menu
        return UIMenu(title: "Options", children: [settingsAction, logoutAction, cleantAction])
    }

    // MARK: - Menu Actions
    private func openSettings() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            print("No active window scene found")
            return
        }

        let currentStyle = windowScene.windows.first?.overrideUserInterfaceStyle
        let newStyle: UIUserInterfaceStyle = (currentStyle == .dark) ? .light : .dark

        // Apply the new style to all windows in the scene
        windowScene.windows.forEach { window in
            window.overrideUserInterfaceStyle = newStyle
        }
        print("Switched to \(newStyle == .dark ? "Dark Mode" : "Light Mode")")
    }

    private func logout() {
        print("Logout tapped")
        let alertController = UIAlertController(title: "Sign Out", message: "Are you sure you want to sign out?", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Sign Out", style: .destructive) { _ in
            do {
                self.loadingIndicator.startAnimating()
                try Auth.auth().signOut()
                DispatchQueue.main.async {
                    let previewVC = PreviewViewController()
                    // Preload content before navigating
                    previewVC.preloadContent {
                        let navigationController = UINavigationController(rootViewController: previewVC)
                        self.loadingIndicator.stopAnimating()
                        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
                           let window = sceneDelegate.window {
                            window.rootViewController = navigationController
                            window.makeKeyAndVisible()
                        }
                    }
                }
            } catch let error {
                print("Failed to log out: \(error.localizedDescription)")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func clean() {
        showLoadingIndicator() // Start loading indicator

        DispatchQueue.global(qos: .background).async { [weak self] in
            // Clean the cache in the background
            ProfileImageCache.shared.cleanCache()
            
            DispatchQueue.main.async {
                // Reload the current view after cleaning
                self?.fetchUserIfNeeded(forceRefresh: true)
                self?.hideLoadingIndicator() // Stop loading indicator
            }
        }
    }
    
    // MARK: - View Controller Management
    private func transitionToViewController(_ viewController: UIViewController) {
        if let currentVC = currentViewController {
            currentVC.willMove(toParent: nil)
            currentVC.view.removeFromSuperview()
            currentVC.removeFromParent()
        }
        
        addChild(viewController)
        view.insertSubview(viewController.view, belowSubview: toolbar)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            viewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            viewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            viewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: toolbar.topAnchor)
        ])
        viewController.didMove(toParent: self)
        
        currentViewController = viewController
        

        self.navigationController?.navigationBar.backgroundColor = UIColor(named: "BackgroundColor")
        self.navigationController?.navigationBar.barTintColor = UIColor(named: "BackgroundColor")
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    // MARK: - Show Views
    private func showHomeView() {
        let homeVC = HomeViewController()
        homeVC.onNavigateToDetails = { [weak self] in
            self?.showDetailsView()
        }
        transitionToViewController(homeVC)
    }
    
    private func showProfileView() {
        guard let user = currentUser else {
            print("User not loaded yet.")
            return
        }
        let profileVC = ProfileViewController(user: user)
        profileVC.onEditTriggered = { [weak self] in
            // Refresh user data when notified by ProfileViewController
            self?.fetchUserIfNeeded(forceRefresh: true)
        }
        transitionToViewController(profileVC)
    }
    
    private func showPostView() {
        guard let user = currentUser else {
            print("User not loaded yet.")
            return
        }
        let postVC = PostViewController(user: user)
        postVC.view.backgroundColor = UIColor(named: "BackgroundColor")
        transitionToViewController(postVC)
    }
    
    private func showDetailsView() {
        let alertController = UIAlertController(
            title: "Choose Audio Source",
            message: "Would you like to record using the system microphone or select an audio file?",
            preferredStyle: .actionSheet
        )

        // Option 1: Use the system microphone
        alertController.addAction(UIAlertAction(title: "Record Audio", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            self.presentAudioRecordingScreen()
        }))

        // Option 2: Select an audio file
        alertController.addAction(UIAlertAction(title: "Select Audio File", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            self.presentAudioFilePicker()
        }))

        // Cancel option
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        // Present the alert
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Actions
    @objc private func homeTapped() {
        showHomeView()
    }
    
    @objc private func profileTapped() {
        showProfileView()
    }
    
    @objc private func postTapped() {
        showPostView()
    }
    
    private func presentAudioFilePicker() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.audio]) // Restrict to audio files
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)
    }
    
    private func presentAudioRecordingScreen() {
        // Check if microphone input is available
        let audioSession = AVAudioSession.sharedInstance()
        guard let inputs = audioSession.availableInputs, !inputs.isEmpty else {
            showMicrophoneUnavailableAlert()
            return
        }

        // Create and present the audio recorder as a pop-up sheet
        let audioRecorderVC = AudioRecorderViewController()
        audioRecorderVC.onRecordingFinished = { [weak self] fileURL in
            guard let fileURL = fileURL else { return }
            // Check if the file exists
            if !FileManager.default.fileExists(atPath: fileURL.path) {
                self!.showAlert(title: "Error", message: "Recording file not found. Please try again.")
                return
            }
            
            do {
                let fileAttributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
                if let fileSize = fileAttributes[.size] as? UInt64, fileSize < 1024 { // Minimum 1 KB
                    self!.showAlert(title: "Error", message: "Recording file is too short. Please try again.")
                    return
                }
            } catch {
                self!.showAlert(title: "Error", message: "Unable to check file attributes. Please try again.")
                return
            }
            
            let detailsVC = DetailViewController(
                fileURL: fileURL, user: (self?.currentUser!)!
            )
            detailsVC.pitchDetector = PitchDetector()
            detailsVC.frequencyData = FrequencyData()
            self?.transitionToViewController(detailsVC)
        }

        // Set presentation style to sheet
        if #available(iOS 15.0, *) {
            audioRecorderVC.modalPresentationStyle = .pageSheet
            if let sheet = audioRecorderVC.sheetPresentationController {
                sheet.detents = [.medium(), .large()] // Customizes the pop-up size
                sheet.prefersGrabberVisible = true
            }
        } else {
            audioRecorderVC.modalPresentationStyle = .formSheet // Fallback for older iOS versions
        }

        present(audioRecorderVC, animated: true, completion: nil)
    }
    
    // MARK: - Fetch Current User
    private func fetchUserIfNeeded(forceRefresh: Bool = false) {
        if isUserLoaded && !forceRefresh { return } // Skip fetching if already loaded
        
        guard let currentUser = Auth.auth().currentUser else {
            print("No authenticated user.")
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users").document(currentUser.uid).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Failed to fetch user data: \(error.localizedDescription)")
                return
            }
            
            guard let data = snapshot?.data(),
                  let displayName = data["displayName"] as? String,
                  let email = data["email"] as? String,
                  let profileImageUrlString = data["profileImageUrl"] as? String,
                  let profileImageUrl = URL(string: profileImageUrlString) else {
                print("Failed to parse user data or invalid profile image URL.")
                return
            }
            
            // Fetch and cache the profile image
            self.loadProfileImage(for: currentUser.uid, from: profileImageUrl) { imagePath in
                // Construct User object with local image file path
                let user = User(
                    uid: currentUser.uid,
                    displayName: displayName,
                    email: email,
                    profileImageUrl: imagePath
                )
                self.currentUser = user
                self.isUserLoaded = true // Mark user as loaded
                
                // Show Home View as the default screen
                self.showHomeView()
            }
        }
    }
    
    // MARK: - Load Profile Image
    private func loadProfileImage(for userId: String, from url: URL, completion: @escaping (String) -> Void) {
        // Get the local file path for the cached image
        let localPath = ProfileImageCache.shared.getFilePath(for: userId)
        let localURL = URL(fileURLWithPath: localPath)

        // Check if the image exists locally
        if FileManager.default.fileExists(atPath: localPath) {
            // If the image is cached locally, return the local file path
            print("Loaded image from local cache: \(localPath)")
            completion(localPath)
            return
        }

        // If not cached locally, download the image from the remote URL
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                print("Failed to load profile image from remote URL: \(error?.localizedDescription ?? "No error info")")
                return
            }

            // Save the downloaded image to the local cache
            ProfileImageCache.shared.saveImage(image, for: userId)

            // Return the local file path
            print("Downloaded and cached image at: \(localPath)")
            completion(localPath)
        }.resume()
    }
    
    // MARK: - HELPER
    private func showMicrophoneUnavailableAlert() {
        let alert = UIAlertController(
            title: "Microphone Unavailable",
            message: "Your device does not have a microphone or it is currently unavailable.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

}

extension MainContainerViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else { return }
        print(selectedFileURL)
        let detailsVC = DetailViewController(
            fileName: selectedFileURL.deletingPathExtension().lastPathComponent,
            fileExtension: selectedFileURL.pathExtension,
            user: currentUser!
        )
        detailsVC.pitchDetector = PitchDetector()
        detailsVC.frequencyData = FrequencyData()
        transitionToViewController(detailsVC)
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Document picker was cancelled.")
    }
}
