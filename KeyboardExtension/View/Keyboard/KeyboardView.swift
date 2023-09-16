//
//  KeyboardView.swift
//  SwiftKeyboard
//
//  Created by Jinsu Gu on 2023/04/25.
//

import SwiftUI
import Combine

struct KeyboardView: View {
    @StateObject private var viewModel = KeyboardViewModel()
    
    public func update(_ size: CGSize, isLandscape: Bool) {
        viewModel.update(size, isLandscape: isLandscape)
    }
    
    var body: some View {
        VStack(spacing: viewModel.spaceUnit) {
            HStack(spacing: viewModel.spaceUnit) {
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
            
            HStack(spacing: viewModel.spaceUnit) {
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
            
            HStack(spacing: viewModel.spaceUnit) {
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
            
            HStack(spacing: viewModel.spaceUnit) {
                SpecialButton("123", width: sizeState.width * 2) {
                    keyStatus.toggleNumber()
                }
                SpecialButton("스페이스") {
                    InputController.shared.input(" ")
                }
                KeyButton(".")
                SpecialButton("이동", width: sizeState.width * 2) {
                    
                }
                viewModel.keyButton.draw()
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
