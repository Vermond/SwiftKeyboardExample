//
//  KeyboardEvent.swift
//  Keysemble
//
//  Created by Jinsu Gu on 3/18/24.
//

import Foundation
import SwiftUI
import Combine

enum KeyboardUIEventType {
    case backColorChanged(newValue: Color, isOverwrite: Bool)
    case buttonColorChanged(newValue: Color, isOverwrite: Bool)
    case textColorChanged(newValue: Color, isOverwrite: Bool)
    
    case areaSizeChanged(size: CGSize)
    case rowSizeChanged(sizeInfo: SizeInfo)
    case keySizeChanged(sizeInfo: KeySizeInfo)
    
    case roundChanged(round: CGFloat)
    case spaceChanged(space: CGFloat)
}

class KeyboardUIEventMediator: EventMediator {
    public static var shared = KeyboardUIEventMediator()
    
    private let subject = PassthroughSubject<KeyboardUIEventType, Never>()
    
    var publisher: AnyPublisher<KeyboardUIEventType, Never> {
        return subject.eraseToAnyPublisher()
    }
    
    func sendEvent(_ event: KeyboardUIEventType) {
        subject.send(event)
    }
}
