//
//  ContentView.swift
//  Deez_Metaverse
//
//  Created by Sufian Shaban on 2/14/22.
//

import SwiftUI
import ReplayKit
import RealityKit
import ARKit
import Combine


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
    let characterAnchor = AnchorEntity()
    func makeCoordinator() -> Coordinator {
        Coordinator(self, anchor: characterAnchor)
    }
    
    
    @EnvironmentObject var placementSettings: PlacementSettings

    func makeUIView(context: Context) -> CustomARView {
               
        let arView = CustomARView(frame: .zero)
        
        arView.session.delegate = context.coordinator
        context.coordinator.setCoolGuy()
        
        //Subscribe to SceneEvents.Update
        self.placementSettings.sceneObserver = arView.scene.subscribe(to: SceneEvents.Update.self, { (event) in
            
            //Call updateScene method
            self.updateScene(for: arView)
            
        })
        
        return arView
    }
    
    func updateUIView(_ uiView: CustomARView, context: Context) {
    }
   
    
    private func updateScene( for arView: CustomARView) {
        
        // Only display focusEntity when the user has selected a model for placement
        arView.focusEntity?.isEnabled = self.placementSettings.selectedModel != nil
        
        // Add model to scene if confirmed for placement
        if let confirmedModel = self.placementSettings.confirmededModel, let modelEntity = confirmedModel.modelEntity {
            
            self.place(modelEntity, in: arView)
            
            self.placementSettings.confirmededModel = nil
            
        }
      
    }

    private func place(_ modelEntity: ModelEntity, in arView: CustomARView) {
        let configuration = ARBodyTrackingConfiguration()
        arView.session.run(configuration)
        arView.scene.addAnchor(characterAnchor)



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
    class Coordinator: NSObject, ARSessionDelegate {
        var character: BodyTrackedEntity?
        let characterAnchor: AnchorEntity
        let characterOffset: SIMD3<Float>
        
        init(_ control:ARViewContainer, anchor: AnchorEntity) {
            self.characterAnchor = anchor
            self.characterOffset = [-1.0, 0, 0]
            super.init()
        }
        
        func setCoolGuy() {
            var cancellable: AnyCancellable? = nil
            cancellable = Entity.loadBodyTrackedAsync(named: "character/robot").sink(
                receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        print("Error: Unable to load model: \(error.localizedDescription)")
                    }
                    cancellable?.cancel()
            }, receiveValue: { (character: Entity) in
                if let character = character as? BodyTrackedEntity {
                    character.scale = [1.0, 1.0, 1.0]
                    self.character = character
                    cancellable?.cancel()
                } else {
                    print("Error: Unable to load model as BodyTrackedEntity")
                }
            })
        }
        
        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {

            for anchor in anchors {
                guard let bodyAnchor = anchor as? ARBodyAnchor else { continue }
                
                // Update the position of the character anchor's position.
                let bodyPosition = simd_make_float3(bodyAnchor.transform.columns.3)
                characterAnchor.position = bodyPosition + characterOffset
                // Also copy over the rotation of the body anchor, because the skeleton's pose
                // in the world is relative to the body anchor's rotation.
                characterAnchor.orientation = Transform(matrix: bodyAnchor.transform).rotation
       
                if let character = character, character.parent == nil {
                    // Attach the character to its anchor as soon as
                    // 1. the body anchor was detected and
                    // 2. the character was loaded.
                    characterAnchor.addChild(character)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(PlacementSettings())
    }
}
