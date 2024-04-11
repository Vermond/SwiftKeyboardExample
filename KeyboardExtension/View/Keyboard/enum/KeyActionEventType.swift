//
//  KeyActionEventType.swift
//  Keysemble
//
//  Created by Jinsu Gu on 4/11/24.
//

import Foundation
import Combine

enum KeyActionEventType {
    case keyInput
}

class KeyActionEventMediator: EventMediator {
    public static var shared = KeyActionEventMediator()
    
    private var subject = PassthroughSubject<KeyActionEventType, Never>()
    
    var publisher: AnyPublisher<KeyActionEventType, Never> {
        return subject.eraseToAnyPublisher()
    }
    
    func sendEvent(_ event: KeyActionEventType) {
        subject.send(event)
    }
}
