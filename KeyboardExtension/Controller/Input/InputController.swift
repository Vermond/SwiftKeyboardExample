//
//  InputController.swift
//  SwiftKeyboard
//
//  Created by Jinsu Gu on 2023/04/25.
//

import Foundation
import SwiftUI

class InputController {
    public static let shared = InputController()
    
    internal let LBase: UInt32 = 0x1100, VBase: UInt32 = 0x1161, TBase: UInt32 = 0x11A7
    internal let LCount: UInt32 = 19, VCount: UInt32 = 21, TCount: UInt32 = 28
    internal let NCount: UInt32 = 19 * 21, SCount: UInt32 = 19 * 21 * 28
    internal let SBase: UInt32 = 0xAC00

    internal let letterJaStart: UInt32 = 0x3131 //ㄱ
    internal let letterJaEnd: UInt32 = 0x314E //ㅎ
    internal let letterMoStart: UInt32 = 0x314F //ㅏ
    internal let letterMoEnd: UInt32 = 0x3163 //ㅣ
    
    private var currentInputVC: UIInputViewController?
    
    public func setInputVC(_ vc: UIInputViewController?) {
        self.currentInputVC = vc
    }
    public func clearInputVC() {
        self.currentInputVC = nil
    }
    
    private var proxy: UITextDocumentProxy? {
        currentInputVC?.textDocumentProxy
    }
    
    public func input(_ text: String) {
        guard let proxy else { return }
        
        var edited = false
                
        let beforeText = proxy.documentContextBeforeInput ?? ""
//        let afterText = proxy.documentContextAfterInput ?? ""
        
        guard let lastText = beforeText.last else {
            proxy.insertText(text)
            return
        }
        
        let decomposed = String(lastText).decomposedStringWithCanonicalMapping
        var scalarList = Array(decomposed.unicodeScalars)
        
        let lastCode = scalarList.last?.value ?? 0
        let newCode = text.unicodeScalars.first?.value ?? 0
        
        switch scalarList.count {
        case 1:
            if isJa(lastCode) && isMo(newCode) {
                scalarList[0] = UnicodeScalar(choseongDic[lastCode] ?? lastCode)!
                scalarList.append(UnicodeScalar(newCode - letterMoStart + VBase)!)
                edited = true
            }
        case 2:
            if isJa(newCode) {
                scalarList.append(UnicodeScalar(jongseongDic[newCode] ?? newCode)!)
                edited = true
            }
        case 3:
            if isMo(newCode) {
                let index = scalarList.endIndex - 1
                
                if let jongseong = combineDic.first(where: { $0.result == lastCode }) {
                    let choseong = choseongDic[jongseong.add] ?? jongseong.add
                    scalarList[index] = UnicodeScalar(jongseong.base)!
                    scalarList.append(UnicodeScalar(choseong)!)
                } else {
                    let letter = jongseongDic.first(where: { $0.value == lastCode })?.key ?? lastCode
                    let choseong = choseongDic[letter] ?? letter
                    scalarList[index] = UnicodeScalar(choseong)!
                }
                
                scalarList.append(UnicodeScalar(newCode - letterMoStart + VBase)!)
                edited = true
            }
        default:
            break
        }
                
        let combine = combineJamo(lastCode, newCode)
        if combine != 0 {
            let index = scalarList.endIndex - 1
            scalarList[index] = UnicodeScalar(combine)!
            edited = true
        }
        
        if edited {
            proxy.deleteBackward()
            proxy.insertText(String(scalarList.map { String($0) }.joined()))
        } else {
            proxy.insertText(text)
        }
    }
    
    public func removeBackward() {
        guard let proxy else { return }
        
        proxy.deleteBackward()
    }
}
