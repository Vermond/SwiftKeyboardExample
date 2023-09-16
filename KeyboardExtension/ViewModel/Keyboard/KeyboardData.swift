//
//  KeyboardData.swift
//  KeyboardExample
//
//  Created by Jinsu Gu on 2023/09/15.
//

import Foundation
import SwiftUI


typealias SpecialKeyInfo = (array: Int, pos: Int, widthMultiMag: CGFloat)

enum KeyStatus: Hashable {
    case Normal, Shifted, Number, Special
    
    func toggleShift() -> KeyStatus {
        switch self {
        case .Normal:
            return .Shifted
        case .Shifted:
            return .Normal
        case .Number:
            return .Special
        case .Special:
            return .Number
        }
    }
    
    func toggleNumber() -> KeyStatus {
        switch self {
        case .Normal, .Shifted:
            return .Number
        case .Number, .Special:
            return .Normal
        }
    }
}

class SizeState {
    var width: CGFloat = 0
    var height: CGFloat = 0
    
    func update(width: CGFloat, isLandscape: Bool, interval: CGFloat) {
        self.width = width / 10 - interval
        
        if isLandscape {
            height = self.width * 0.5
        } else {
            height = self.width
        }
    }
}

class KeyButton {
    private var keyDic: [KeyStatus: String] = [:]
    
    var width: CGFloat
    var height: CGFloat
    var foreColor: Color
    var backColor: Color
    var radius: CGFloat
    
    private var isFunctional = false
    
    var status: KeyStatus { return InputController.shared.status }
    
    private lazy var action: () -> Void = {
        if let key = self.keyDic[self.status] {
            InputController.shared.input(key)
        }
    }
    
    /**
        Use this for function key
     */
    init(value: String,
         action: @escaping () -> Void,
         width: CGFloat,
         height: CGFloat,
         foreColor: Color = .white,
         backColor: Color = .black,
         radius: CGFloat = 7.5)
    {
        keyDic[.Normal] = value
        
        self.width = width
        self.height = height
        self.foreColor = foreColor
        self.backColor = backColor
        self.radius = radius
        
        self.isFunctional = true
        
        self.action = action
    }
    
    /**
        Use this for basic character key
     */
    init(normal: String,
         shifted: String,
         number: String,
         special: String,
         width: CGFloat,
         height: CGFloat,
         foreColor: Color = .white,
         backColor: Color = .black,
         radius: CGFloat = 7.5)
    {
        keyDic[.Normal] = normal
        keyDic[.Shifted] = shifted
        keyDic[.Number] = number
        keyDic[.Special] = special
        
        self.width = width
        self.height = height
        self.foreColor = foreColor
        self.backColor = backColor
        self.radius = radius
    }
    
    /**
        Use this for basic character key
     */    
    init(values: [String],
         width: CGFloat,
         height: CGFloat,
         foreColor: Color = .white,
         backColor: Color = .black,
         radius: CGFloat = 7.5)
    {
        assert(values.count >= 4, "Input value element should more then 4.")
                    
        keyDic[.Normal] = values[0]
        keyDic[.Shifted] = values[1]
        keyDic[.Number] = values[2]
        keyDic[.Special] = values[3]
            
        self.width = width
        self.height = height
        self.foreColor = foreColor
        self.backColor = backColor
        self.radius = radius
    }
    
    func createKeyButtonList(
        keyValue: [[String]],
        specialKeyInfoList: [SpecialKeyInfo],
        specialKeyActionList: [() -> ()],
        width: CGFloat,
        height: CGFloat,
        foreColor: Color = .white,
        backColor: Color = .black,
        radius: CGFloat = 7.5) -> [KeyButton]
    {
        assert(specialKeyInfoList.count == specialKeyActionList.count, "Length of all array related with special key should be same.")
        
        var keyButtonList = [KeyButton]()
        
        for array in 0..<keyValue.count {
            for pos in 0..<keyValue[array].count {
                let index = specialKeyInfoList.firstIndex { value in
                    value.array == array && value.pos == pos
                }
                
                if let index {
                    let keyWidth = specialKeyInfoList[index].widthMultiMag == .infinity ? CGFloat.infinity : width * specialKeyInfoList[index].widthMultiMag
                    
                    keyButtonList.append(KeyButton(value: keyValue[array][pos],
                                                   action: specialKeyActionList[index],
                                                   width: keyWidth,
                                                   height: height,
                                                   foreColor: foreColor,
                                                   backColor: backColor,
                                                   radius: radius))
                } else {
                    var splittedKeyInfo = [String]()
                    
                    for char in keyValue[array][pos] {
                        splittedKeyInfo.append(String(char))
                    }
                    
                    keyButtonList.append(KeyButton(values: splittedKeyInfo,
                                                   width: width,
                                                   height: height,
                                                   foreColor: foreColor,
                                                   backColor: backColor,
                                                   radius: radius))
                }
            }
        }
        
        
        return keyButtonList
    }
    
    private var curKey: String {
        return keyDic[status] ?? ""
    }
    
    func draw() -> any View {        
        if isFunctional {
            let button = Button(action: self.action,
                                label: {
                Text(curKey)
                    .foregroundColor(foreColor)
                    .frame(maxWidth: .infinity)
                })
                .frame(height: height)
                .background(backColor)
                .cornerRadius(radius)
            
            return button.modifier(SpecialButtonWidthModifier(width: width))
        } else {
            return Button(action: self.action,
                          label: {
                Text(curKey)
                    .foregroundColor(foreColor)
            })
            .frame(width: width, height: height)
            .background(backColor)
            .cornerRadius(radius)
        }
    }
}

private struct SpecialButtonWidthModifier: ViewModifier {
    let width: CGFloat

    func body(content: Content) -> some View {
        if width.isNaN {
            return AnyView(content.frame(maxWidth: .infinity))
        } else {
            return AnyView(content.frame(width: width))
        }
    }
}

// MARK: Pre-defined values

let keyValueKoreanPreset = [
    [
        "ㅂㅃ1!",
        "ㅈㅉ2@",
        "ㄷㄸ3#",
        "ㄱㄲ4$",
        "ㅅㅆ5%",
        "ㅛㅛ6^",
        "ㅕㅕ7&",
        "ㅑㅑ8*",
        "ㅐㅒ9(",
        "ㅔㅖ0)",
    ],
    [
        "ㅁㅁ-{",
        "ㄴㄴ_}",
        "ㅇㅇ=[",
        "ㄹㄹ+]",
        "ㅎㅎ\\'",
        "ㅗㅗ|\"",
        "ㅓㅓ₩<",
        "ㅏㅏ~>",
        "ㅣㅣ;:",
    ],
    [
        "⇧", //space
        "ㅋㅋ,,",
        "ㅌㅌ..",
        "ㅊㅊ//",
        "ㅍㅍ??",
        "ㅠㅠ\\\\",
        "ㅜㅜ[<",
        "ㅡㅡ]>",
        "⌫", //backspace
    ],
    [
        "123", //toggle number
        "스페이스", //space
        "....",
        "이동", // enter
    ]
]

let specialKeyPositionKorean = [
    //special key position of keyValueKoreanPreset
    SpecialKeyInfo(array: 2, pos: 0, widthMultiMag: 1),
    SpecialKeyInfo(array: 2, pos: 8, widthMultiMag: 1),
    SpecialKeyInfo(array: 3, pos: 0, widthMultiMag: 2),
    SpecialKeyInfo(array: 3, pos: 1, widthMultiMag: CGFloat.infinity),
    SpecialKeyInfo(array: 3, pos: 3, widthMultiMag: 2),
]

let specialKeyActionKorean = [
    { InputController.shared.toggleShift() },
    { InputController.shared.removeBackward() },
    { InputController.shared.toggleNumber() },
    { InputController.shared.input("") },
    { } //do nothing
]

