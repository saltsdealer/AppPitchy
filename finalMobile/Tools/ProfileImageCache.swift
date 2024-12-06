//
//  ProfileImageCache.swift
//  finalMobile
//
//  Created by firesalts on 11/20/24.
//

import Foundation
import UIKit
import FirebaseAuth

class ProfileImageCache {
    static let shared = ProfileImageCache()
    private let cache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    
    // Directory for cached images
    var cacheDirectory: URL {
        return fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("ProfileImages")
    }
    
    private init() {
        // Create directory if it doesn't exist
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    // Get image from cache or local file system
    func getImage(for userId: String) -> UIImage? {
        // Check NSCache first
        if let cachedImage = cache.object(forKey: userId as NSString) {
            return cachedImage
        }
        
        // Check local storage
        let filePath = cacheDirectory.appendingPathComponent("\(userId).jpg")
        if let image = UIImage(contentsOfFile: filePath.path) {
            cache.setObject(image, forKey: userId as NSString) // Cache it for faster future access
            return image
        }
        
        return nil
    }
    
    // Save image to cache and local storage
    func saveImage(_ image: UIImage, for userId: String) {
        // Save to NSCache
        cache.setObject(image, forKey: userId as NSString)
        
        // Save to file system
        let filePath = cacheDirectory.appendingPathComponent("\(userId).jpg")
        if let imageData = image.jpegData(compressionQuality: 0.75) {
            try? imageData.write(to: filePath)
        }
    }
    
    // Get file path for a cached image
    func getFilePath(for userId: String) -> String {
        return cacheDirectory.appendingPathComponent("\(userId).jpg").path
    }
    
    // Save image to cache and local storage with a specified filename
    func saveImage(_ image: UIImage, as filename: String) {
        // Save to NSCache
        cache.setObject(image, forKey: filename as NSString)
        
        // Save to file system
        let filePath = cacheDirectory.appendingPathComponent(filename)
        if let imageData = image.jpegData(compressionQuality: 0.75) {
            try? imageData.write(to: filePath)
        }
    }
    
    func getLatestImage() -> UIImage? {
        do {
            // Get all files in the cache directory
            let files: [URL] = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.creationDateKey], options: [])
            
            let userUID = Auth.auth().currentUser?.uid
            
            // Filter files that start with "pitchy-res-"
            let filteredFiles = files.filter { $0.lastPathComponent.hasPrefix("pitchy-res-\(String(describing: userUID))-") }
            
            // Sort files by creation date in descending order
            let sortedFiles = filteredFiles.sorted {
                let firstDate = try? $0.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date.distantPast
                let secondDate = try? $1.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date.distantPast
                return firstDate! > secondDate!
            }
            
            // Get the latest file if it exists
            if let latestFile = sortedFiles.first {
                return UIImage(contentsOfFile: latestFile.path)
            }
        } catch {
            print("Error fetching latest image: \(error.localizedDescription)")
        }
        return nil
    }
    
    // Clean all cached images with the specified prefix
     func cleanCache() {
         do {
             // Get all files in the cache directory
             let files: [URL] = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil, options: [])
             
             let userUID = Auth.auth().currentUser?.uid
             
             // Filter files that start with "pitchy-res-"
             let filesToDelete = files.filter { $0.lastPathComponent.hasPrefix("pitchy-res-\(String(describing: userUID))-") }
             
             // Remove each file
             for file in filesToDelete {
                 try fileManager.removeItem(at: file)
                 print("Deleted: \(file.lastPathComponent)")
             }
             
             // Optionally, clear them from the in-memory cache
             filesToDelete.forEach { file in
                 let key = file.lastPathComponent as NSString
                 cache.removeObject(forKey: key)
             }
             
             print("Cache cleaned successfully.")
         } catch {
             print("Error cleaning cache: \(error.localizedDescription)")
         }
     }
}
