//
//  RegisterViewFirebaseManager.swift
//  assignment8
//
//  Created by firesalts on 11/5/24.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore


import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

// MARK: - RegisterFirebaseManager Without IMAGE
//extension RegisterViewController {
//
//    func registerUser(email: String, password: String, displayName: String, completion: @escaping (Result<String, Error>) -> Void) {
//        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//            
//            guard let user = authResult?.user else {
//                completion(.failure(NSError(domain: "RegisterFirebaseManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "User creation failed."])))
//                return
//            }
//
//            // Update the profile's display name
//            let changeRequest = user.createProfileChangeRequest()
//            changeRequest.displayName = displayName
//            changeRequest.commitChanges { error in
//                if let error = error {
//                    completion(.failure(error))
//                    return
//                }
//
//                // Add user data to Firestore
//                let db = Firestore.firestore()
//                db.collection("users").document(user.uid).setData([
//                    "uid": user.uid,
//                    "email": email,
//                    "displayName": displayName,
//                    "chats": []
//                ]) { error in
//                    if let error = error {
//                        completion(.failure(error))
//                        return
//                    }
//                    
//                    // Success
//                    completion(.success("User registered successfully with display name \(displayName)"))
//                }
//            }
//        }
//    }
//}

//MARK: - RegisterFirebaseManager With IMAGE
extension RegisterViewController {
    func registerUser(email: String, password: String, displayName: String, profileImage: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = authResult?.user else {
                completion(.failure(NSError(domain: "RegisterFirebaseManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "User creation failed."])))
                return
            }
            
            // Update the profile's display name
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = displayName
            changeRequest.commitChanges { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                // Add user data to Firestore
                let db = Firestore.firestore()
                db.collection("users").document(user.uid).setData([
                    "uid": user.uid,
                    "email": email,
                    "displayName": displayName,
                    "chats": []
                ]) { error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    
                    // Upload profile image to Firebase Storage
                    let storageRef = Storage.storage().reference().child("profile_images").child("\(user.uid).jpg")
                    guard let imageData = profileImage.jpegData(compressionQuality: 0.75) else {
                        completion(.failure(NSError(domain: "RegisterFirebaseManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Image data conversion failed."])))
                        return
                    }
                    
                    storageRef.putData(imageData, metadata: nil) { metadata, error in
                        if let error = error {
                            completion(.failure(error))
                            return
                        }
                        
                        // Get download URL and update Firestore with profile image URL
                        storageRef.downloadURL { url, error in
                            if let error = error {
                                completion(.failure(error))
                                return
                            }
                            
                            guard let profileImageUrl = url else {
                                completion(.failure(NSError(domain: "RegisterFirebaseManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get profile image URL."])))
                                return
                            }
                            
                            // Update Firestore document with profile image URL
                            db.collection("users").document(user.uid).updateData([
                                "profileImageUrl": profileImageUrl.absoluteString
                            ]) { error in
                                if let error = error {
                                    completion(.failure(error))
                                } else {
                                    // Success
                                    ProfileImageCache.shared.saveImage(profileImage, for: user.uid)
                                    completion(.success("User registered successfully with display name \(displayName) and profile image."))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
