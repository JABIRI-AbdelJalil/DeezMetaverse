//
//  ViewController.swift
//  Deez_Metaverse
//
//  Created by Sufian Shaban on 2/18/22.
//


import UIKit
import RealityKit
import ARKit
import Combine

class ViewController: UIViewController, ARSessionDelegate {

    @IBOutlet var arView: ARView!
    
    // The 3D character to display.
    var character: BodyTrackedEntity?
    let characterOffset: SIMD3<Float> = [-1.0, 0, 0] // Offset the character by one meter to the left
    let characterAnchor = AnchorEntity()
    var timer = Timer()
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        arView.session.delegate = self
        
        // If the iOS device doesn't support body tracking, raise a developer error for
        // this unhandled case.
        guard ARBodyTrackingConfiguration.isSupported else {
            fatalError("This feature is only supported on devices with an A12 chip")
        }

        // Run a body tracking configration.
        let configuration = ARBodyTrackingConfiguration()
        arView.session.run(configuration)
        
        arView.scene.addAnchor(characterAnchor)
        
        // Asynchronously load the 3D character.
        var cancellable: AnyCancellable? = nil
        cancellable = Entity.loadBodyTrackedAsync(named: "character/robot").sink(
            receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error: Unable to load model: \(error.localizedDescription)")
                }
                cancellable?.cancel()
        }, receiveValue: { (character: Entity) in
            if let character = character as? BodyTrackedEntity {
                // Scale the character to human size
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
                
                print("character position \(bodyPosition)")
                let right_hand_joint = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: "right_hand_joint"))
                let left_hand_joint = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: "left_hand_joint"))
                let right_foot_joint = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: "right_foot_joint"))
                let left_foot_joint = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: "left_foot_joint"))
                let right_shoulder_joint = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: "rightshoulder_joint"))
                let left_shoulder_joint = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: "leftshoulder_joint"))
                print("right_hand_joint position \(right_hand_joint)")
                print("left_hand_joint position \(left_hand_joint)")
                print("right_foot_joint position \(right_foot_joint)")
                print("left_foot_joint position \(left_foot_joint)")
                print("right_shoulder_joint position \(right_shoulder_joint)")
                print("left_shoulder_joint position \(left_shoulder_joint)")
            }
        }
    }
}
