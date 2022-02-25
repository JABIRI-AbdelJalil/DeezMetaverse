//
//  Deez_MetaverseApp.swift
//  Deez_Metaverse
//
//  Created by Sufian Shaban on 2/14/22.
//

import SwiftUI
import Firebase

@main
struct Deez_MetaverseApp: App {
    @StateObject var placementSettings = PlacementSettings()
    @StateObject var sessionSettings = SessionSettings()
    
    init() {
        FirebaseApp.configure()
        
        // Anonymous authentication with Firebase
        Auth.auth().signInAnonymously { authResult, error in
            guard let user = authResult?.user else {
                print("FAILED: Anonymous Authentication with Firebase.")
                return
            }
            
            let uid = user.uid
            print("Firebase: Anonymous user authentication  with uid: \(uid)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(placementSettings)
                .environmentObject(sessionSettings)
        }
    }
}
