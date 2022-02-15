//
//  PlacementSettings.swift
//  Deez_Metaverse
//
//  Created by Sufian Shaban on 2/15/22.
//

import SwiftUI
import RealityKit
import Combine

class PlacementSettings : ObservableObject {
    
    // When the uses selects a model in BrowseView, this property is set.
    @Published var selectedModel: Model? {
        willSet(newValue) {
            print("Setting selectedModel to \(String(describing: newValue?.name))")
        }
    }
    
    // When the user taps confirm in PlacementView, the value of selectedModel is assigned to confirmedModel
    @Published var confirmededModel: Model? {
        willSet(newValue) {
            guard let model = newValue else {
                print("Clearing confirmedModel")
                return
            }
            print("Setting confirmedModel to \(model.name)")
            }
        }
    
    // This property retains the cancellable object for our SceneEvents.Update subscriber
    var sceneObserver: Cancellable?
}
