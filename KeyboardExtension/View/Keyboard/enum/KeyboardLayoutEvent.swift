//
//  KeyboardLayoutEvent.swift
//  Keyboard
//
//  Created by Jinsu Gu on 4/3/24.
//

import Foundation
import Combine

enum KeyboardLayoutEventType {
    case loaded(data: KeyboardData)
    case willAppear(size: CGSize)
    case didAppear(size: CGSize)
    case willTransition(size: CGSize)
}

class KeyboardLayoutEventMediator: EventMediator {
    public static var shared = KeyboardLayoutEventMediator()
    
    private let subject = PassthroughSubject<KeyboardLayoutEventType, Never>()
    
    var publisher: AnyPublisher<KeyboardLayoutEventType, Never> {
        return subject.eraseToAnyPublisher()
    }
    
    func sendEvent(_ event: KeyboardLayoutEventType) {
        subject.send(event)
    }
}
