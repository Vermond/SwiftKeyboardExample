//
//  KeyboardData.swift
//  KeyboardExample
//
//  Created by Jinsu Gu on 2023/09/15.
//

import Foundation
import SwiftUI

typealias FunctionKeyInfo = (array: Int, pos: Int, widthMultiMag: CGFloat)
typealias ViewModelFunction = (KeyboardViewModel) -> Void

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

class KeyButtonList: Hashable {
    let id = UUID()
    
    let items: [KeyButton]
    
    init(items: [KeyButton]) {
        self.items = items
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(items)
    }
    
    static func == (lhs: KeyButtonList, rhs: KeyButtonList) -> Bool {
        return lhs.id == rhs.id &&
        lhs.items == rhs.items
    }
}

struct KeyButton: View, Hashable {
    let id = UUID()
    private var keyDic: [KeyStatus: String] = [:]
    
    @ObservedObject var viewModel: KeyboardViewModel
    
    var widthMag: CGFloat
    var foreColor: Color
    var backColor: Color
    var radius: CGFloat
    
    private var isFunctional = false
    private var action: ViewModelFunction?
    
    private var status: KeyStatus { viewModel.currentStatus }
    
    private static let defaultForeColor = Color.white
    private static let defaultBackColor = Color.black
    private static let defaultMag = CGFloat(1)
    private static let defaultRadius = CGFloat(7.5)
    
    private lazy var defaultAction: ViewModelFunction = { [self] _ in
        if let key = keyDic[status] {
            InputController.shared.input(key)
        }
    }
    
    /**
        Use this for function key
     */
    init(value: String,
         action: @escaping ViewModelFunction,
         viewModel: KeyboardViewModel,
         foreColor: Color = defaultForeColor,
         backColor: Color = defaultBackColor,
         widthMag: CGFloat = defaultMag,
         radius: CGFloat = defaultRadius)
    {
        keyDic[.Normal] = value
        
        self.viewModel = viewModel
        self.widthMag = widthMag
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
         action: ViewModelFunction? = nil,
         viewModel: KeyboardViewModel,
         foreColor: Color = defaultForeColor,
         backColor: Color = defaultBackColor,
         widthMag: CGFloat = defaultMag,
         radius: CGFloat = defaultRadius)
    {
        keyDic[.Normal] = normal
        keyDic[.Shifted] = shifted
        keyDic[.Number] = number
        keyDic[.Special] = special
        
        self.viewModel = viewModel
        self.widthMag = widthMag
        self.foreColor = foreColor
        self.backColor = backColor
        self.radius = radius
        
        self.action = action ?? defaultAction
    }
    
    /**
        Use this for basic character key
     */    
    init(values: [String],
         action: ViewModelFunction? = nil,
         viewModel: KeyboardViewModel,
         foreColor: Color = defaultForeColor,
         backColor: Color = defaultBackColor,
         widthMag: CGFloat = defaultMag,
         radius: CGFloat = defaultRadius)
    {
        assert(values.count >= 4, "Input value element should more then 4.")
                    
        keyDic[.Normal] = values[0]
        keyDic[.Shifted] = values[1]
        keyDic[.Number] = values[2]
        keyDic[.Special] = values[3]
        
        self.viewModel = viewModel
        self.widthMag = widthMag
        self.foreColor = foreColor
        self.backColor = backColor
        self.radius = radius
        
        self.action = action ?? defaultAction
    }
    
    static func createKeyButtonList(
        keyValue: [[String]],
        functionKeyInfoList: [FunctionKeyInfo],
        functionKeyActionList: [ViewModelFunction],
        viewModel: KeyboardViewModel,
        foreColor: Color = defaultForeColor,
        backColor: Color = defaultBackColor,
        radius: CGFloat = defaultRadius) -> [KeyButtonList]
    {
        assert(functionKeyInfoList.count == functionKeyActionList.count, "Length of all array related with function key should be same.")
        
        var keyButtonList = [KeyButtonList]()
        
        for array in 0..<keyValue.count {
            var list = [KeyButton]();
            
            for pos in 0..<keyValue[array].count {
                let index = functionKeyInfoList.firstIndex { value in
                    value.array == array && value.pos == pos
                }
                
                if let index {
                    list.append(KeyButton(value: keyValue[array][pos],
                                          action: functionKeyActionList[index],
                                          viewModel: viewModel,
                                          foreColor: foreColor,
                                          backColor: backColor,
                                          widthMag: functionKeyInfoList[index].widthMultiMag,
                                          radius: radius))
                } else {
                    var splittedKeyInfo = [String]()
                    
                    for char in keyValue[array][pos] {
                        splittedKeyInfo.append(String(char))
                    }
                    
                    list.append(KeyButton(values: splittedKeyInfo,
                                          viewModel: viewModel,
                                          foreColor: foreColor,
                                          backColor: backColor,
                                          radius: radius))
                }
            }
            keyButtonList.append(KeyButtonList(items: list))
        }
        
        
        return keyButtonList
    }
    
    private var curKey: String {
        if isFunctional {
            return keyDic[.Normal] ?? ""
        } else {
            return keyDic[status] ?? ""
        }
    }
    
    @ViewBuilder
    var body: some View {
        if isFunctional {
            let keyWidth = widthMag == .infinity ? CGFloat.infinity : viewModel.sizeState.width * widthMag
            
            Button(action: { self.action?(viewModel) },
                   label: {
                Text(curKey)
                    .foregroundColor(foreColor)
                    .frame(maxWidth: .infinity)
                })
                .frame(height: viewModel.sizeState.height)
                .background(backColor)
                .cornerRadius(radius)
                .modifier(FunctionButtonWidthModifier(width: keyWidth))
        } else {
            Button(action: { self.action?(viewModel) },
                   label: {
                Text(curKey)
                    .foregroundColor(foreColor)
            })
            .frame(width: viewModel.sizeState.width, height: viewModel.sizeState.height)
            .background(backColor)
            .cornerRadius(radius)
        }
    }
    
    mutating func update(foregroundColor foreColor: Color) {
        self.foreColor = foreColor
    }
    
    mutating func update(backgroundColor backColor: Color) {
        self.backColor = backColor
    }
    
    mutating func update(radius: CGFloat) {
        self.radius = radius
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(widthMag)
        hasher.combine(foreColor)
        hasher.combine(backColor)
        hasher.combine(radius)
        hasher.combine(keyDic)
        hasher.combine(isFunctional)
    }
    
    static func == (lhs: KeyButton, rhs: KeyButton) -> Bool {
        return lhs.id == rhs.id &&
        lhs.foreColor == rhs.foreColor &&
        lhs.backColor == rhs.backColor &&
        lhs.radius == rhs.radius &&
        lhs.keyDic == rhs.keyDic &&
        lhs.isFunctional == rhs.isFunctional
    }
}

private struct FunctionButtonWidthModifier: ViewModifier {
    let width: CGFloat

    func body(content: Content) -> some View {
        if width.isInfinite {
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

let functionKeyPositionKorean = [
    //special key position of keyValueKoreanPreset
    FunctionKeyInfo(array: 2, pos: 0, widthMultiMag: 1),
    FunctionKeyInfo(array: 2, pos: 8, widthMultiMag: 1),
    FunctionKeyInfo(array: 3, pos: 0, widthMultiMag: 2),
    FunctionKeyInfo(array: 3, pos: 1, widthMultiMag: CGFloat.infinity),
    FunctionKeyInfo(array: 3, pos: 3, widthMultiMag: 2),
]

let functionKeyActionKorean: [ViewModelFunction] = [
    toggleShift,
    removeBackward,
    toggleNumber,
    inputSpace,
    inputEnter,
]

func toggleShift(viewModel: KeyboardViewModel) {
    viewModel.toggleShift()
}

func removeBackward(viewModel: KeyboardViewModel) {
    InputController.shared.removeBackward()
}

func toggleNumber(viewModel: KeyboardViewModel) {
    viewModel.toggleNumber()
}

func inputSpace(viewModel: KeyboardViewModel) {
    InputController.shared.input(" ")
}

func inputEnter(viewModel: KeyboardViewModel) {
    InputController.shared.input("\n")
}
