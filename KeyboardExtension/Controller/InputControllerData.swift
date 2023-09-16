//
//  InputControllerData.swift
//  KeyboardExample
//
//  Created by Jinsu Gu on 2023/09/16.
//

import Foundation

extension InputController {
    internal var choseongDic : [UInt32: UInt32] {
        return [
            0x3131: 0x1100, //ㄱ
            0x3132: 0x1101, //ㄲ
            0x3134: 0x1102, //ㄴ
            0x3137: 0x1103, //ㄷ
            0x3138: 0x1104, //ㄸ
            0x3139: 0x1105, //ㄹ
            0x3141: 0x1106, //ㅁ
            0x3142: 0x1107, //ㅂ
            0x3143: 0x1108, //ㅃ
            0x3145: 0x1109, //ㅅ
            0x3146: 0x110A, //ㅆ
            0x3147: 0x110B, //ㅇ
            0x3148: 0x110C, //ㅈ
            0x3149: 0x110D, //ㅉ
            0x314A: 0x110E, //ㅊ
            0x314B: 0x110F, //ㅋ
            0x314C: 0x1110, //ㅌ
            0x314D: 0x1111, //ㅍ
            0x314E: 0x1112, //ㅎ
        ]
    }
    
    internal var jongseongDic : [UInt32: UInt32] {
        return [
            0x3131: 0x11A8, //ㄱ
            0x3132: 0x11A9, //ㄲ
            0x3133: 0x11AA, //ㄱㅅ
            0x3134: 0x11AB, //ㄴ
            0x3135: 0x11AC, //ㄴㅈ
            0x3136: 0x11AD, //ㄴㅎ
            0x3137: 0x11AE, //ㄷ
            0x3139: 0x11AF, //ㄹ
            0x313A: 0x11B0, //ㄹㄱ
            0x313B: 0x11B1, //ㄹㅁ
            0x313C: 0x11B2, //ㄹㅂ
            0x313D: 0x11B3, //ㄹㅅ
            0x313E: 0x11B4, //ㄹㅌ
            0x313F: 0x11B5, //ㄹㅍ
            0x3140: 0x11B6, //ㄹㅎ
            0x3141: 0x11B7, //ㅁ
            0x3142: 0x11B8, //ㅂ
            0x3144: 0x11B9, //ㅂㅅ
            0x3145: 0x11BA, //ㅅ
            0x3146: 0x11BB, //ㅆ
            0x3147: 0x11BC, //ㅇ
            0x3148: 0x11BD, //ㅈ
            0x314A: 0x11BE, //ㅊ
            0x314B: 0x11BF, //ㅋ
            0x314C: 0x11C0, //ㅌ
            0x314D: 0x11C1, //ㅍ
            0x314E: 0x11C2, //ㅎ
        ]
    }
    
    internal var combineDic : [(base: UInt32, add: UInt32, result: UInt32)] {
        return [
            //중성 + 글자 = 중성
            codeToStr(0x1169, 0x314F, 0x116A), // ㅗ + ㅏ -> ㅘ
            codeToStr(0x1169, 0x3150, 0x116B), // ㅗ + ㅐ -> ㅙ
            codeToStr(0x1169, 0x3163, 0x116C), // ㅗ + ㅣ -> ㅚ
            codeToStr(0x116E, 0x3153, 0x116F), // ㅜ + ㅓ -> ㅝ
            codeToStr(0x116E, 0x3154, 0x1170), // ㅜ + ㅔ -> ㅞ
            codeToStr(0x116E, 0x3163, 0x1171), // ㅜ + ㅣ -> ㅟ
            codeToStr(0x1173, 0x3163, 0x1174), // ㅡ + ㅣ -> ㅢ
            
            //종성 + 글자 = 종성
            codeToStr(0x11A8, 0x3145, 0x11AA), // ㄱ + ㅅ = ㄱㅅ
            codeToStr(0x11AB, 0x3148, 0x11AC), // ㄴ + ㅈ = ㄴㅈ
            codeToStr(0x11AB, 0x314E, 0x11AD), // ㄴ + ㅎ = ㄴㅎ
            codeToStr(0x11AF, 0x3131, 0x11B0), // ㄹ + ㄱ = ㄹㄱ
            codeToStr(0x11AF, 0x3141, 0x11B1), // ㄹ + ㅁ = ㄹㅁ
            codeToStr(0x11AF, 0x3142, 0x11B2), // ㄹ + ㅂ = ㄹㅂ
            codeToStr(0x11AF, 0x3145, 0x11B3), // ㄹ + ㅅ = ㄹㅅ
            codeToStr(0x11AF, 0x314C, 0x11B4), // ㄹ + ㅌ = ㄹㅌ
            codeToStr(0x11AF, 0x314D, 0x11B5), // ㄹ + ㅍ = ㄹㅍ
            codeToStr(0x11AF, 0x314E, 0x11B6), // ㄹ + ㅎ = ㄹㅎ
            codeToStr(0x11B8, 0x3145, 0x11B9), // ㅂ + ㅅ = ㅂㅅ
        ]
    }
    
    internal func codeToStr(_ code1: UInt32, _ code2: UInt32, _ combined: UInt32) -> (base: UInt32, add: UInt32, result: UInt32) {
        return (code1, code2, combined)
    }
    
    internal func combineJamo(_ code1: UInt32, _ code2: UInt32) -> UInt32 {
        return combineDic.first(where: { $0.base == code1 && $0.add == code2 })?.result ?? 0
    }
    
    internal func isInRange(_ target: UInt32, from: UInt32, to: UInt32) -> Bool {
        return target >= from && target <= to
    }

    internal func isJa(_ target: UInt32) -> Bool {
        return isInRange(target, from: letterJaStart, to: letterJaEnd)
    }

    internal func isMo(_ target: UInt32) -> Bool {
        return isInRange(target, from: letterMoStart, to: letterMoEnd)
    }
}
