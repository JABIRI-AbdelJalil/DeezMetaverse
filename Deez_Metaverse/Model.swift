//
//  Model.swift
//  Deez_Metaverse
//
//  Created by Sufian Shaban on 2/14/22.
//

import SwiftUI
import RealityKit
import Combine

enum ModelCategory: CaseIterable {
    case table
    case chair
    case toy
    case robot
    
    var label: String {
        get {
            switch self {
            case .table:
                return "Tables"
            case .chair:
                return "Chairs"
            case .toy:
                return "Toys"
            case .robot:
                return "Robot"
            }
        }
    }
    
}


class Model {
    var name: String
    var category: ModelCategory
    var thumbnail: UIImage
    var modelEntity: ModelEntity?
    var scaleCompensation: Float
    
    private var cancellable: AnyCancellable?
    
    init(name: String, category: ModelCategory, scaleCompensation: Float = 1.0) {
        self.name = name
        self.category = category
        self.thumbnail = UIImage(named: name) ?? UIImage(systemName: "photo")!
        self.scaleCompensation = scaleCompensation
    }
    
    //async method to  load modelEntity
    func asyncLoadModelEntity() {
        let filename = self.name + ".usdz"
        
        self.cancellable = ModelEntity.loadModelAsync(named: filename)
            .sink(receiveCompletion: { loadCompletion in
                
                switch loadCompletion {
                case.failure(let error) : print("Unable to load modelEntity for \(filename). Error: \(error.localizedDescription)")
                case.finished:
                    break
                }
                
            }, receiveValue: { modelEntity in
                
                self.modelEntity = modelEntity
                self.modelEntity?.scale *= self.scaleCompensation
                
                print("modelEntity for \(self.name) has been loaded.")
                
            })
    }
}

struct Models {
    var all: [Model] = []
    
    init() {
        // Adding objects
        let chair = Model(name: "chair_swan", category: .chair, scaleCompensation: 5.0/100)
        let biplane = Model(name: "toy_biplane", category: .toy, scaleCompensation: 5.0/100)
        let robot = Model(name: "toy_robot_vintage", category: .robot, scaleCompensation: 5.0/100)
        let tv = Model(name: "tv_retro", category: .table, scaleCompensation: 5.0/100)


        
        self.all += [chair, biplane, robot, tv]
    }
    
    func get(category: ModelCategory) -> [Model] {
        return all.filter( {$0.category == category})
    }
}
