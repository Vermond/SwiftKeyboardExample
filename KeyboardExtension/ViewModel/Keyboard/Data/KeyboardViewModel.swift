//
//  KeyboardViewModel.swift
//  KeyboardExample
//
//  Created by Jinsu Gu on 2023/09/15.
//

import SwiftUI
import Foundation

class KeyboardViewModel: ObservableObject {
    var sizeState = SizeState()
    var keyStatus = KeyStatus.Normal
    
    var keyButton = KeyButton(normal: "1", shifted: "2", number: "3", special: "4", width: 100, height: 100)
    
    @Published var spaceUnit: CGFloat = 2
    
    public func update(_ size: CGSize, isLandscape: Bool) {
        sizeState.update(width: size.width, isLandscape: isLandscape, interval: spaceUnit)
    }
    
}
