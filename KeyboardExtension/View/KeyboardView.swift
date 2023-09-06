//
//  KeyboardView.swift
//  SwiftKeyboard
//
//  Created by Jinsu Gu on 2023/04/25.
//

import SwiftUI
import Combine

struct KeyboardView: View {
    @ObservedObject private var sizeState = SizeState()
    @State private var keyStatus = KeyStatus.Normal
    
    private var spaceUnit: CGFloat = 2
    
    public func update(_ size: CGSize, isLandscape: Bool) {
        sizeState.update(width: size.width, isLandscape: isLandscape, interval: spaceUnit)
    }
    
    private func KeyButton(_ text: String) -> some View {
        Button(action: {
            InputController.shared.input(text)
        }, label: {
            Text(text)
                .foregroundColor(.white)
        })
        .frame(width: sizeState.width, height: sizeState.height)
        .background(Color.black)
        .cornerRadius(7.5)
    }
    
    private func KeyButton(_ text1: String, _ text2: String, _ text3: String, _ text4: String) -> some View {
        let text: String
        
        switch keyStatus {
        case .Normal:
            text = text1
        case .Shifted:
            text = text2
        case .Number:
            text = text3
        case .Special:
            text = text4
        }
        
        return Button(action: {
            InputController.shared.input(text)
        }, label: {
            Text(text)
                .foregroundColor(.white)
        })
        .frame(width: sizeState.width, height: sizeState.height)
        .background(Color.black)
        .cornerRadius(7.5)
    }
    
    private func SpecialButton(_ text: String, width: CGFloat = .nan, action: @escaping () -> Void) -> some View {
        let button = Button(
            action: action,
            label: {
                Text(text)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
            })
            .frame(height: sizeState.height)
            .background(Color.black)
            .cornerRadius(7.5)
        
        return button.modifier(SpecialButtonWidthModifier(width: width))
    }
    
    var body: some View {
        VStack(spacing: spaceUnit) {
            HStack(spacing: spaceUnit) {
                KeyButton("ㅂ", "ㅃ", "1", "!")
                KeyButton("ㅈ", "ㅉ", "2", "@")
                KeyButton("ㄷ", "ㅉ", "3", "#")
                KeyButton("ㄱ", "ㅉ", "4", "$")
                KeyButton("ㅅ", "ㅉ", "5", "%")
                KeyButton("ㅛ", "ㅛ", "6", "^")
                KeyButton("ㅕ", "ㅓ", "7", "&")
                KeyButton("ㅑ", "ㅑ", "8", "*")
                KeyButton("ㅐ", "ㅒ", "9", "(")
                KeyButton("ㅔ", "ㅉ", "2", "@")
            }
            
            HStack(spacing: spaceUnit) {
                KeyButton("ㅁ", "ㅁ", "-", "{")
                KeyButton("ㄴ", "ㄴ", "_", "}")
                KeyButton("ㅇ", "ㅇ", "=", "[")
                KeyButton("ㄹ", "ㄹ", "+", "]")
                KeyButton("ㅎ", "ㅎ", "\\", "'")
                KeyButton("ㅗ", "ㅗ", "|", "\"")
                KeyButton("ㅓ", "ㅓ", "₩", "<")
                KeyButton("ㅏ", "ㅏ", "~", ">")
                KeyButton("ㅣ", "ㅣ", ";", ":")
            }
            
            HStack(spacing: spaceUnit) {
                SpecialButton("⇧") {
                    keyStatus.toggleShift()
                }
                KeyButton("ㅋ", "ㅋ", ",", ",")
                KeyButton("ㅌ", "ㅌ", ".", ".")
                KeyButton("ㅊ", "ㅊ", "/", "/")
                KeyButton("ㅍ", "ㅍ", "?", "?")
                KeyButton("ㅠ", "ㅠ", "\\", "\\")
                KeyButton("ㅜ", "ㅜ", "[", "<")
                KeyButton("ㅡ", "ㅡ", "]", ">")
                SpecialButton("⌫") {
                    InputController.shared.removeBackward()
                }
            }
            
            HStack(spacing: spaceUnit) {
                SpecialButton("123", width: sizeState.width * 2) {
                    keyStatus.toggleNumber()
                }
                SpecialButton("스페이스") {
                    InputController.shared.input(" ")
                }
                KeyButton(".")
                SpecialButton("이동", width: sizeState.width * 2) {
                    
                }
            }
            
        }
        .padding()
        .background(Color.gray)
    }
}

struct KeyboardView_Previews: PreviewProvider {
    static var previews: some View {
        let size = CGSize(width: 414, height: 612) //portrait preview size
//        let size = CGSize(width: 612, height: 612) // landscape preview size
        let view = KeyboardView()
        view.update(size, isLandscape: false)
        return view
    }
}

class SizeState: ObservableObject {
    @Published var width: CGFloat = 0
    @Published var height: CGFloat = 0
    
    func update(width: CGFloat, isLandscape: Bool, interval: CGFloat) {
        self.width = width / 10 - interval
        
        if isLandscape {
            height = self.width * 0.5
        } else {
            height = self.width
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

private enum KeyStatus {
    case Normal, Shifted, Number, Special
    
    mutating func toggleShift() {
        switch self {
        case .Normal:
            self = .Shifted
        case .Shifted:
            self = .Normal
        case .Number:
            self = .Special
        case .Special:
            self = .Number
        }
    }
    
    mutating func toggleNumber() {
        switch self {
        case .Normal, .Shifted:
            self = .Number
        case .Number, .Special:
            self = .Normal
        }
    }
}
