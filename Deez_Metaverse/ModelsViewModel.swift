//
//  ModelsViewModel.swift
//  Deez_Metaverse
//
//  Created by abdel jalil jabiri on 24/2/2022.
//

import Foundation
import FirebaseFirestore

class ModelsViewModel: ObservableObject {
    @Published var models: [Model] = []
    
    private let db = Firestore.firestore()
    
    func fetchData() {
        db.collection("models").addSnapshotListener{ (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("Firestore: No documents.")
                return
            }
            
            self.models = documents.map { (queryDocumentSnapshot) -> Model in
                let data = queryDocumentSnapshot.data()
                let categoryText = data["category"] as? String ?? ""
                let name = data["name"] as? String ?? ""
                let category = ModelCategory(rawValue: categoryText) ?? .chair
                let scaleCompensation = data["scaleCompensation"] as? Double ?? 1.0
                
                return Model(name: name, category: category, scaleCompensation: Float(scaleCompensation))
                
            }
    }
}
}
