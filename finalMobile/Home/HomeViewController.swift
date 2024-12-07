//
//  HomeViewController.swift
//  finalMobile
//
//  Created by firesalts on 11/14/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    private let homeView = HomeView()
    var onNavigateToDetails: (() -> Void)?
    private var posts: [Post] = []
    private var postsListener: ListenerRegistration?
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .gray
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLoadingIndicator() {
        view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Lifecycle
    override func loadView() {
        view = homeView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateImageViewWithLatestImage()
        setupTableView()
        setupLoadingIndicator()
        observePosts()
        homeView.logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        homeView.onNavigateToDetails = { [weak self] in
            self?.onNavigateToDetails?()
        }
        
    }
    
    // MARK: - Actions
    @objc private func logoutTapped() {
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
    
    private func updateImageViewWithLatestImage() {
        if let latestImage = ProfileImageCache.shared.getLatestImage() {
            homeView.imageView.image = latestImage
            homeView.imageTitleLabel.isHidden = false
            homeView.imageView.layer.borderWidth = 4
            homeView.imageView.layer.cornerRadius = 10
            homeView.imageView.layer.borderColor = UIColor.bottomNavi.cgColor
        }

    }
    
    private func setupTableView() {
        homeView.tableView.register(PostTableViewCell.self, forCellReuseIdentifier: "PostCell")
        homeView.tableView.delegate = self
        homeView.tableView.dataSource = self
    }
    
    // MARK: - Observe Posts with Real-Time Updates
    private func observePosts() {
        print("Observing posts...")
        loadingIndicator.startAnimating()
        // Query to fetch the latest two posts based on their timestamps
        postsListener = db.collection("posts")
            .order(by: "timestamp", descending: true) // Order posts by timestamp in descending order
            .limit(to: 2) // Limit to the latest two posts
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
            
                if let error = error {
                    print("Error observing posts: \(error)")
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("No documents found in posts collection.")
                    return
                }
                
                self.posts = documents.compactMap { doc in
                    guard
                        let creatorID = doc.data()["creatorID"] as? String,
                        let postsPicsURL = doc.data()["imageURLs"] as? [String],
                        let messages = doc.data()["messages"] as? String
                    else {
                        print("Skipping document with invalid fields: \(doc.data())")
                        return nil
                    }

                    let profileImageURL = "" // Placeholder for profile image URL
                    print("Post fetched: \(doc.documentID)")
                    return Post(
                        postID: doc.documentID,
                        creatorID: creatorID,
                        postsPicsURL: postsPicsURL,
                        messages: messages,
                        profileImageURL: profileImageURL
                    )
                }
                self.fetchAdditionalPostData() // Fetch additional data like profile images
            }
    }
    
    private func fetchAdditionalPostData() {
        let group = DispatchGroup()

        for (index, post) in posts.enumerated() {
            // Fetch profile image URL from the "users" collection
            group.enter()
            db.collection("users").document(post.creatorID).getDocument { [weak self] snapshot, error in
                defer { group.leave() }
                guard let self = self else { return }
                if let data = snapshot?.data(),
                   let profileImageURLString = data["profileImageUrl"] as? String {
                    // Directly assign the profileImageURL as a string
                    self.posts[index].profileImageURL = profileImageURLString
                    group.enter()
                    self.fetchProfileImage(for: self.posts[index], at: index, in: group)
                } else {
                    print("Failed to fetch profile image URL for creatorID: \(post.creatorID)")
                }
            }

            // Fetch initial message from the "posts_msg" collection
            group.enter()
            
            db.collection("posts_msg").document(post.postID).getDocument { [weak self] snapshot, error in
                defer { group.leave() }
                guard let self = self else { return }
                if let data = snapshot?.data(),
                   let initialMessage = data["message"] as? String {
                    // Assign the initial message to the post
                    self.posts[index].messages = initialMessage
                } else {
                    print("Failed to fetch initial message for postID: \(post.postID)")
                }
            }

            // Placeholder for fetching the latest message (if required later)
            // self.posts[index].messages = "Latest message placeholder"
        }

        // Notify completion of all async tasks and reload the table view
        group.notify(queue: .main) {
            self.loadingIndicator.stopAnimating()
            self.homeView.tableView.reloadData()
            self.homeView.tableView.alpha = 0
            self.homeView.tableView.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.homeView.tableView.alpha = 1
            }
        }
    }
    
    private func fetchProfileImage(for post: Post, at index: Int, in group: DispatchGroup) {
        guard !post.profileImageURL.isEmpty else {
            print("Invalid or empty profile image URL for creatorID \(post.creatorID)")
            group.leave()
            return
        }
        let storageRef = storage.reference(forURL: post.profileImageURL)
        storageRef.getData(maxSize: 5 * 1024 * 1024) { [weak self] data, error in
            defer { group.leave() }
            guard let self = self else { return }
            
            if let error = error {
                print("Failed to fetch profile image for creatorID \(post.creatorID): \(error.localizedDescription)")
            } else if let data = data, let image = UIImage(data: data) {
                self.posts[index].profileImage = image
        
            } else {
                print("Failed to decode profile image data for creatorID \(post.creatorID)")
            }
        }
    }
    
    func fetchDisplayName(for uid: String, completion: @escaping (String?) -> Void) {
        let db = Firestore.firestore()
        let userDocument = db.collection("users").document(uid)
        
        userDocument.getDocument { document, error in
            if let document = document, document.exists, let data = document.data() {
                // Retrieve the displayName field
                let displayName = data["displayName"] as? String
                completion(displayName) // Pass the display name via the completion handler
            } else {
                print("Error fetching document: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil) // Return nil in case of an error
            }
        }
    }
    
    func fetchLatestCommentMessage(for postID: String, completion: @escaping (String?) -> Void) {
        db.collection("comments").document(postID).collection("messages")
            .order(by: "timestamp", descending: true)
            .limit(to: 1)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching latest comment: \(error.localizedDescription)")
                    completion(nil)
                    return
                }

                // Retrieve the latest comment
                if let document = snapshot?.documents.first,
                   let message = document.data()["message"] as? String {
                    completion(message)
                } else {
                    completion(nil)
                }
            }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPost = posts[indexPath.row]
        let postDetailVC = PostDetailViewController(post: selectedPost)
        navigationController?.pushViewController(postDetailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostTableViewCell else {
            return UITableViewCell()
        }

        let post = posts[indexPath.row]
        
        if post.creatorID == Auth.auth().currentUser?.uid {
            // Current user: display "ME"
            cell.postingContentLabel.text = "ME: \(post.messages)"
        } else {
            // Not the current user: fetch the display name
            fetchDisplayName(for: post.creatorID) { displayName in
                DispatchQueue.main.async {
                    if let displayName = displayName {
                        cell.postingContentLabel.text = "\(displayName): \(post.messages)"
                    } else {
                        cell.postingContentLabel.text = "Unknown User: \(post.messages)"
                    }
                }
            }
        }
        fetchLatestCommentMessage(for: post.postID) { latestMessage in
            if let latestMessage = latestMessage {
                cell.latestMessageLabel.text = latestMessage
            } else {
                cell.latestMessageLabel.text = "No message Yet"
            }
        }
        
        cell.postingContentLabel.numberOfLines = 1
        cell.postingContentLabel.lineBreakMode = .byTruncatingTail
        
        // cell.latestMessageLabel.text = "Latest message placeholder"
        cell.latestMessageLabel.numberOfLines = 1
        cell.latestMessageLabel.lineBreakMode = .byTruncatingTail

        cell.profileImageView.image = post.profileImage ?? UIImage(named: "person.fit")

        return cell
    }
}

