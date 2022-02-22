//
//  ContentView.swift
//  Deez_Metaverse
//
//  Created by Sufian Shaban on 2/14/22.
//

import SwiftUI
import ReplayKit
import RealityKit

struct ContentView: View {
    @EnvironmentObject var placementSettings : PlacementSettings
    @State private var isControlVisible: Bool = true
    @State private var showBrowse: Bool = false

    
    var body: some View {
        ZStack(alignment : .bottom) {
            
        ARViewContainer()
            
            if self.placementSettings.selectedModel == nil {
                ControlView(isControlVisible: $isControlVisible, showBrowse: $showBrowse)
            } else {
                PlacementView()
            }
            
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    @EnvironmentObject var placementSettings: PlacementSettings
    
    func makeUIView(context: Context) -> CustomARView {
        
        let arView = CustomARView(frame: .zero)
        
        //Subscribe to SceneEvents.Update
        self.placementSettings.sceneObserver = arView.scene.subscribe(to: SceneEvents.Update.self, { (event) in
            
            //Call updateScene method
            self.updateScene(for: arView)
            
        })
        
        return arView
    }
    
    func updateUIView(_ uiView: CustomARView, context: Context) {}
    
    private func updateScene( for arView: CustomARView) {
        
        // Only display focusEntity when the user has selected a model for placement
        arView.focusEntity?.isEnabled = self.placementSettings.selectedModel != nil
        
        // Add model to scene if confirmed for placement
        if let confirmedModel = self.placementSettings.confirmededModel, let modelEntity = confirmedModel.modelEntity {
            
            self.place(modelEntity, in: arView)
            
            self.placementSettings.confirmededModel = nil
            
        }
        
    }
    
    private func place(_ modelEntity: ModelEntity, in arView: ARView) {
        
        // 1. Clone modelEntity. This creates an identical copy of modelEntity references the same model. This also allows us to have multiple models of the same asset in our scene.
        let clonedEntity = modelEntity.clone(recursive: true)
        
        // 2.  Enable translation and rotation gestures.
        clonedEntity.generateCollisionShapes(recursive: true)
        arView.installGestures([.translation, .rotation , .scale], for: clonedEntity)
        
        // 3. Create an anchorEntity and add clonedEntity to the anchorEntity.
        let anchorEntity = AnchorEntity(plane: .any)
        anchorEntity.addChild(clonedEntity)
        
        // 4. Add the anchorEntity to the arView.scene
        arView.scene.addAnchor(anchorEntity)
        
        print("Added modelEntity to scene.")
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(PlacementSettings())
    }
}
