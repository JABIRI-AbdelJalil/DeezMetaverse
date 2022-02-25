//
//  Model.swift
//  Deez_Metaverse
//
//  Created by Sufian Shaban on 2/14/22.
//

import SwiftUI
import RealityKit
import Combine

enum ModelCategory: String, CaseIterable {
    
    case shoes
    case table
    case chair
    case toy
    case robot
    
    var label: String {
        get {
            switch self {
            case .shoes:
                return "Shoes"
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


class Model: ObservableObject, Identifiable {
    var id: String = UUID().uuidString
    var name: String
    var category: ModelCategory
    @Published var thumbnail: UIImage
    var modelEntity: ModelEntity?
    var scaleCompensation: Float
    
    private var cancellable: AnyCancellable?
    
    init(name: String, category: ModelCategory, scaleCompensation: Float = 1.0) {
        self.name = name
        self.category = category
        self.thumbnail = UIImage(systemName: "photo")!
        self.scaleCompensation = scaleCompensation
        
        FirebaseStorageHelper.asyncDownloadtoFilesystem(relativePath: "thumbnails/\(self.name).png") { localUrl in
            do {
                let imageData = try Data(contentsOf: localUrl)
                self.thumbnail = UIImage(data: imageData) ?? self.thumbnail
            } catch {
                print("Error loading image: \(error.localizedDescription)")
            }
        }
    }
    
    //async method to  load modelEntity
    func asyncLoadModelEntity() {
        FirebaseStorageHelper.asyncDownloadtoFilesystem(relativePath: "models/\(self.name).usdz") { localUrl in
            self.cancellable = ModelEntity.loadModelAsync(contentsOf: localUrl)
                .sink(receiveCompletion: { loadCompletion in
                    
                    switch loadCompletion {
                    case.failure(let error) : print("Unable to load modelEntity for \(self.name). Error: \(error.localizedDescription)")
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
}

