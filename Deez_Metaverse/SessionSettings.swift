//
//  SessionSettings.swift
//  Deez_Metaverse
//
//  Created by abdel jalil jabiri on 23/2/2022.
//

import SwiftUI

class SessionSettings: ObservableObject {
    @Published var isPeopleOcclusionEnabled: Bool = false
    @Published var isObjectOcclusionEnabled: Bool = false
    @Published var isLidarDebugEnabled: Bool = false
    @Published var isMultiUserEnabled: Bool = false
    
    
}
