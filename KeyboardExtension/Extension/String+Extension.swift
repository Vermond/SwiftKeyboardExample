//
//  String+Extension.swift
//  Keysemble
//
//  Created by Jinsu Gu on 4/1/24.
//

import Foundation
import SwiftUI

extension String {
    func toColor() -> Color {
        guard let ss = self.lastIndex(of: "#") else { return .clear }
                
        let rs = self.index(ss, offsetBy: 1)
        let gs = self.index(rs, offsetBy: 2)
        let bs = self.index(gs, offsetBy: 2)
        let aps = self.index(bs, offsetBy: 2)
            
        guard let r = UInt8(self[rs..<gs], radix: 16),
              let g = UInt8(self[gs..<bs], radix: 16),
              let b = UInt8(self[bs..<aps], radix: 16)
        else { return .clear }
        
        if self.count >= 9, let a = UInt8(self[aps..<self.index(aps, offsetBy: 2)], radix: 16) {
            return Color(red: CGFloat(r) / 255,
                         green: CGFloat(g) / 255,
                         blue: CGFloat(b) / 255,
                         opacity: CGFloat(a) / 255)
        } else {
            return  Color(red: CGFloat(r) / 255,
                          green: CGFloat(g) / 255,
                          blue: CGFloat(b) / 255)
        }
    }
    
    func toAction(mainText: String) -> () -> Void {
        if self.contains(":") {
            let splitted = self.split(separator: ":")
            let a = KeyActionController.shared.getAction(key: String(splitted[0]))
            var b = String(splitted[1])
            b = b == "self" ? mainText : b
            
            if splitted.count > 2 {
                let c = String(splitted[2])
                return { a(b, ["limit" : c]) }
            } else {
                return { a(b, [:]) }
            }
        } else {
            let a = KeyActionController.shared.getAction(key: self)
            
            return { a(nil, [:]) }
        }
    }
}
