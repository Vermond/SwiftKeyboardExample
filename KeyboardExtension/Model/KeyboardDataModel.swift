//
//  KeyboardDataModel.swift
//  Keyboard
//
//  Created by Jinsu Gu on 3/11/24.
//

import Foundation
import SwiftUI
import Combine

fileprivate let topKey = "top"
fileprivate let bottomKey = "bottom"
fileprivate let leftKey = "left"
fileprivate let rightKey = "right"

//MARK: - Separate key data

struct KeyButtonData: Codable {
    var mainText: String
    var subText: [String: String]
    var keyAction: String
    var subAction: [String: String]
    
    var width: CGFloat
    var foreColor: String?
    var backColor: String?
    var round: CGFloat
    
    enum CodingKeys: String, CodingKey {
        case mainText, topText, bottomText, leftText, rightText
        case keyAction, topAction, bottomAction, leftAction, rightAction
        case width, foreColor, backColor, round
    }
    
    init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        mainText = try values.decode(String.self, forKey: .mainText)
        
        subText = [:]
        if values.contains(.topText) { subText[topKey] = try values.decode(String.self, forKey: .topText)}
        if values.contains(.bottomText) { subText[bottomKey] = try values.decode(String.self, forKey: .bottomText)}
        if values.contains(.leftText) { subText[leftKey] = try values.decode(String.self, forKey: .leftText)}
        if values.contains(.rightText) { subText[rightKey] = try values.decode(String.self, forKey: .rightText)}
        
        if values.contains(.keyAction) {
            keyAction = try values.decode(String.self, forKey: .keyAction)
        } else {
            keyAction = "input:self"
        }
        
        subAction = [:]
        if values.contains(.topAction) { subAction[topKey] = try values.decode(String.self, forKey: .topAction)}
        if values.contains(.bottomAction) { subAction[bottomKey] = try values.decode(String.self, forKey: .bottomAction)}
        if values.contains(.leftAction) { subAction[leftKey] = try values.decode(String.self, forKey: .leftAction)}
        if values.contains(.rightAction) { subAction[rightKey] = try values.decode(String.self, forKey: .rightAction)}
        
        width = try values.decodeIfPresent(CGFloat.self, forKey: .width) ?? 1
        foreColor = try values.decodeIfPresent(String.self, forKey: .foreColor)
        backColor = try values.decodeIfPresent(String.self, forKey: .backColor)
        round = try values.decodeIfPresent(CGFloat.self, forKey: .round) ?? 0
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if mainText != "input" {
            try container.encode(mainText, forKey: .mainText)
        }
        
        try container.encodeIfPresent(subText[topKey], forKey: .topText)
        try container.encodeIfPresent(subText[bottomKey], forKey: .bottomText)
        try container.encodeIfPresent(subText[leftKey], forKey: .leftText)
        try container.encodeIfPresent(subText[rightKey], forKey: .leftText)
        
        try container.encode(keyAction, forKey: .keyAction)
        try container.encodeIfPresent(subAction[topKey], forKey: .topAction)
        try container.encodeIfPresent(subAction[bottomKey], forKey: .bottomAction)
        try container.encodeIfPresent(subAction[leftKey], forKey: .leftAction)
        try container.encodeIfPresent(subAction[rightKey], forKey: .rightAction)
        
        try container.encodeIfPresent(width, forKey: .width)
        try container.encodeIfPresent(foreColor, forKey: .foreColor)
        try container.encodeIfPresent(backColor, forKey: .backColor)
        try container.encodeIfPresent(round, forKey: .round)
    }
}

extension KeyButtonData {
    func toView() -> KeyButton {
        var action: () -> Void
        
        if keyAction.contains(":") {
            let splitted = keyAction.split(separator: ":")
            let a = KeyActionController.shared.getAction(key: String(splitted[0]))
            var b = String(splitted[1])
            b = b == "self" ? mainText : b
            
            if splitted.count > 2 {
                let c = String(splitted[2])
                action = { a(b, ["limit": c]) }
            } else {
                action = { a(b, [:]) }
            }
        } else {
            let a = KeyActionController.shared.getAction(key: keyAction)
            action = { a(nil, [:]) }
        }
                
        var actionList: [String: () -> Void] = [:]
        for action in subAction {
            actionList[action.key] = action.value.toAction(mainText: mainText)
        }
        
        let viewModel = KeyButton.ViewModel(width: width,
                                            charColor: foreColor?.toColor(),
                                            backColor: backColor?.toColor(),
                                            round: round,
                                            mainText: mainText,
                                            subText: subText,
                                            keyAction: action,
                                            subAction: actionList)
        
        let keyButton = KeyButton(model: viewModel)
        return keyButton
    }
}

//MARK: - Key row data

struct KeyRowData: Codable {
    var keyButtonData: [KeyButtonData]
    
    var backColor: String?
    var height: CGFloat
    
    enum CodingKeys: String, CodingKey {
        case keyButtonData = "keys"
        case backColor
        case height
    }
    
    init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        keyButtonData = try values.decode([KeyButtonData].self, forKey: .keyButtonData)
        backColor = try values.decodeIfPresent(String.self, forKey: .backColor)
        height = try values.decodeIfPresent(CGFloat.self, forKey: .height) ?? 1
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.keyButtonData, forKey: .keyButtonData)
        try container.encodeIfPresent(self.backColor, forKey: .backColor)
    }
}

extension KeyRowData {
    func toView() -> KeyRow {
        var buttonList: [KeyButton] = []
                
        for data in keyButtonData {
            let view = data.toView()
            buttonList.append(view)
        }
        
        let viewModel = KeyRow.ViewModel(backColor: backColor?.toColor())
        
        
        let row = KeyRow(items: buttonList, model: viewModel)
        return row
    }
}

//MARK: - Entire keyboard data

struct KeyboardData: Codable {
    var name: String
    var reservedName: String?
    
    var keyRowData: [KeyRowData]
    
    var space: CGFloat
    var backColor: String
    var buttonColor: String
    var textColor: String
    
    var round: CGFloat
    
    enum CodingKeys: String, CodingKey {
        case name, reservedName
        case keyRowData = "rows"
        case space
        case backColor, buttonColor, textColor
        case round
    }
    
    init() {
        name = ""
        keyRowData = []
        space = 1
        backColor = "#00000000"
        buttonColor = "#00000000"
        textColor = "#00000000"
        round = 0
    }
    
    init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try values.decode(String.self, forKey: .name)
        reservedName = try values.decodeIfPresent(String.self, forKey: .reservedName)
        
        keyRowData = try values.decode([KeyRowData].self, forKey: .keyRowData)
        
        space = try values.decode(CGFloat.self, forKey: .space)
        backColor = try values.decode(String.self, forKey: .backColor)
        buttonColor = try values.decode(String.self, forKey: .buttonColor)
        textColor = try values.decode(String.self, forKey: .textColor)
        
        round = try values.decode(CGFloat.self, forKey: .round)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(reservedName, forKey: .reservedName)
        
        try container.encode(keyRowData, forKey: .keyRowData)
        
        try container.encode(space, forKey: .space)
        try container.encode(backColor, forKey: .backColor)
        try container.encode(buttonColor, forKey: .buttonColor)
        try container.encode(textColor, forKey: .textColor)
        
        try container.encode(round, forKey: .round)
    }
}

extension KeyboardData {
    func toView() -> Keyboard {
        var rowList: [KeyRow] = []
        
        for data in keyRowData {
            let view = data.toView()
            rowList.append(view)
        }
        
        let viewModel = Keyboard.ViewModel(space: space,
                                           backColor: backColor.toColor())
        
        let keyboard = Keyboard(rows: rowList, model: viewModel)
        
        
        return keyboard
    }
}

extension KeyboardData {
    static func from(fileName: String) -> KeyboardData {
        do {
            if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
                let url = NSURL.fileURL(withPath: path)
                let data = try Data(contentsOf: url)
                let keydata = try JSONDecoder().decode(KeyboardData.self, from: data)
                
                return keydata
            } else {
                return KeyboardData()
            }
        } catch {
            return KeyboardData()
        }
    }
}

