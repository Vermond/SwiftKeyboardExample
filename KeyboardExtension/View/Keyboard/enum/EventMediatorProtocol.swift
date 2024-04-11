//
//  EventMediator.swift
//  Keysemble
//
//  Created by Jinsu Gu on 4/9/24.
//

import Foundation
import Combine

protocol EventMediator {
    associatedtype T
    
    var publisher: AnyPublisher<T, Never> { get }
    
    func sendEvent(_ event: T)
}
