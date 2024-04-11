//
//  KeyActionController.swift
//  KeysembleBoard
//
//  Created by Jinsu Gu on 2/19/24.
//

import Foundation
import SwiftUI

typealias KeyAction = (Any?, [String: Any]) -> Void

class KeyActionController {
    public static let shared = KeyActionController()
    
    private lazy var actions: [String: KeyAction] = [
        "input": inputChar,
        "removeChar": removeChar,
        "changeKeyboard": changeKeyboard,
        "blank": blank,
    ]
    
    public func getInputAction() -> KeyAction {
        return inputChar
    }
    
    public func getAction(key: String) -> KeyAction {
        return actions[key] ?? inputChar
    }
}

extension KeyActionController {
    private var inputChar: KeyAction {
        { char, _ in
            if let char = char as? String {
                InputController.shared.input(char)
                KeyActionEventMediator.shared.sendEvent(.keyInput)
            }
        }
    }
    
    private var removeChar: KeyAction {
        { _, _ in
            InputController.shared.removeBackward()
        }
    }
    
    private var changeKeyboard: KeyAction {
        { keyboardDataName, params in
            if let keyboardName = keyboardDataName as? String {
                do {
                    if keyboardName == "reserved" {
                        let reserved = KeyboardUIController.shared.reservedName
                        self.changeKeyboard(reserved, [:])
                    } else if let path = Bundle.main.path(forResource: keyboardName, ofType: "json") {
                        let url = NSURL.fileURL(withPath: path)
                        let data = try Data(contentsOf: url)
                        let keyData = try JSONDecoder().decode(KeyboardData.self, from: data)
                        
                        if let limitStr = params["limit"] as? String, let limit = Int(limitStr) {
                            KeyboardUIController.shared.update(data: keyData, limit: limit)
                        } else {
                            KeyboardUIController.shared.update(data: keyData, limit: -1)
                        }
                    }
                } catch {
                    // do nothing
                }
                
                
            }
        }
    }
    
    private var blank: KeyAction {
        { _, _ in
            //do nothing
        }
    }
}
