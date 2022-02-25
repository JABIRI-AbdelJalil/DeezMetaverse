//
//  View+Extensions.swift
//  Deez_Metaverse
//
//  Created by abdel jalil jabiri on 23/2/2022.
//

import SwiftUI

extension View {
    @ViewBuilder func hidden(_ shouldHide: Bool) -> some View {
        switch shouldHide {
        case true: self.hidden()
        case false: self
        }
    }
}
