//
//  FirebaseStorageHelper.swift
//  Deez_Metaverse
//
//  Created by abdel jalil jabiri on 24/2/2022.
//

import Foundation
import Firebase

class FirebaseStorageHelper {
    static private let cloudStoraqge = Storage.storage()
    
    class func asyncDownloadtoFilesystem(relativePath: String, handler: @escaping (_ fileUrl: URL) -> Void) {
        // Create local filesystem URL
        let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileUrl = docsUrl.appendingPathComponent(relativePath)
        
        // Check if asset is already in the local filesystem
        // if it is, load that asset and return
        if FileManager.default.fileExists(atPath: fileUrl.path) {
            handler(fileUrl)
            return
        }
        
        // Create a reference to the asset
        let storageRef = cloudStoraqge.reference(withPath: relativePath)
        
        // Download to the local filesystem
        storageRef.write(toFile: fileUrl) { url, error in
            guard let localUrl = url else {
                print("Firebase storage: Error downloading file with relativePath: \(relativePath)")
                return
            }
            
            handler(localUrl)
        }.resume()
    }
}
