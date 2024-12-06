//
//  PostViewController.swift
//  finalMobile
//
//  Created by firesalts on 11/24/24.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class PostViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let postView = PostView()
    private let user: User
    private var posts: [Post] = [] // Store fetched posts
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private var postsListener: ListenerRegistration?
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let refreshControl = UIRefreshControl()
    private var messageInputBottomConstraint: NSLayoutConstraint?
    private var initialMsg : [Post] = []
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = postView
        setupActivityIndicator()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        observePosts()
        postView.addPostButton.addTarget(self, action: #selector(handleAddPost), for: .touchUpInside)

        // Set up keyboard observers
    }
    
    @objc private func handleAddPost() {
        let addPostVC = AddPostViewController(user: user)
        addPostVC.modalPresentationStyle = .pageSheet
        if let sheet = addPostVC.sheetPresentationController {
            sheet.detents = [.large()] // Pop-up style
            sheet.prefersGrabberVisible = true // Optional grabber at the top
        }
        present(addPostVC, animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Detach Firestore listener to prevent memory leaks
        postsListener?.remove()
    }
    
    
    
    // MARK: - Setup
    private func setupView() {
        postView.tableView.delegate = self
        postView.tableView.dataSource = self
        postView.tableView.separatorStyle = .none
        postView.tableView.register(PostTableViewCell.self, forCellReuseIdentifier: "PostTableViewCell")
        postView.tableView.isHidden = true
        postView.addPostButton.addTarget(self, action: #selector(handleAddPost), for: .touchUpInside)
        // Configure pull-to-refresh
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        postView.tableView.refreshControl = refreshControl
        
    }
    
    private func setupActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func handleRefresh() {
        print("Pull-to-refresh triggered")
        
        // Simulate data refresh (replace with actual data reload logic)
        observePosts() // Fetch data again
        refreshControl.endRefreshing() // End the refreshing animation after data is loaded
    }
    

    
    // MARK: - Observe Posts with Real-Time Updates
    private func observePosts() {
        print("Observing posts...")
        
        activityIndicator.startAnimating()
        
        postsListener = db.collection("posts").addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            self.postView.loadingIndicator.stopAnimating()
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
                    return nil // Skip documents that don't have the required fields
                }

                // Use a default value or placeholder for `profileImageURL` if it's unavailable initially
                let profileImageURL = "" // Placeholder; actual URL will be fetched later
                print("Post fetched: \(doc.documentID)")
                return Post(
                    postID: doc.documentID,
                    creatorID: creatorID,
                    postsPicsURL: postsPicsURL,
                    messages: messages,
                    profileImageURL: profileImageURL
                )
            }
            self.fetchAdditionalPostData() // Fetch additional data, including profile image URLs
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
            self.postView.tableView.reloadData()
            self.activityIndicator.stopAnimating()
            self.postView.tableView.alpha = 0
            self.postView.tableView.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.postView.tableView.alpha = 1
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell", for: indexPath) as? PostTableViewCell else {
            return UITableViewCell()
        }

        let post = posts[indexPath.row]
        
        if post.creatorID == self.user.uid {
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


