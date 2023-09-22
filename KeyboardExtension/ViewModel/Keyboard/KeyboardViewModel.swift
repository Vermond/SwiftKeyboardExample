//
//  KeyboardViewModel.swift
//  KeyboardExample
//
//  Created by Jinsu Gu on 2023/09/15.
//

import SwiftUI
import Foundation

fileprivate let defaultSpace = CGFloat(2)
fileprivate let defaultBackColor = Color.gray

class KeyboardViewModel: ObservableObject {
    @Published var spaceUnit: CGFloat
    @Published var entireBackgroundColor: Color
    @Published var currentStatus: KeyStatus = .Normal
    @Published var sizeState: SizeState
    
    private var keyButtonList: [KeyButtonList] = []
    
    
    init(spaceUnit: CGFloat = defaultSpace, backColor: Color = defaultBackColor) {
        self.spaceUnit = spaceUnit
        self.entireBackgroundColor = backColor
        
        let size = UIScreen.main.bounds.size
        let sizeState = SizeState(screenWidth: size.width,
                                  screenHeight: size.height,
                                  unit: 10,
                                  landscapeRatio: 0.5,
                                  interval: spaceUnit)
        self.sizeState = sizeState
        
        keyButtonList = KeyButton.createKeyButtonList(keyValue: keyValueKoreanPreset,
                                                      functionKeyInfoList: functionKeyPositionKorean,
                                                      functionKeyActionList: functionKeyActionKorean,
                                                      viewModel: self)
    }
    
    func update(_ size: CGSize, isLandscape: Bool) {
        sizeState.update(width: size.width, isLandscape: isLandscape, interval: spaceUnit)
        objectWillChange.send()
    }
    
    func toggleNumber() {
        self.currentStatus = currentStatus.toggleNumber()
    }
    
    func toggleShift() {
        self.currentStatus = currentStatus.toggleShift()
    }
    
    @ViewBuilder
    var keyButtonView: some View {
        VStack(spacing: spaceUnit) {
            ForEach(keyButtonList, id: \.id) { list in
                HStack(spacing: self.spaceUnit) {
                    ForEach(list.items, id: \.id) { keyButton in
                        keyButton
                    }
                }
            }
        }
        .padding()
        .background(self.entireBackgroundColor)
    }
}

class SizeState: Hashable, ObservableObject {
    @Published private var _width: CGFloat
    @Published private var _height: CGFloat
    
    @Published private var unit: CGFloat
    @Published private var landscapeRatio: CGFloat
    @Published private var interval: CGFloat
    
    var width: CGFloat { self._width > 0 ? self._width : 0 }
    var height: CGFloat {  self._height > 0 ? self._height : 0 }
    
    init(screenWidth: CGFloat,
         screenHeight: CGFloat,
         unit: CGFloat,
         landscapeRatio: CGFloat,
         interval: CGFloat)
    {
        _width = 0
        _height = 0
        
        self.unit = unit
        self.landscapeRatio = landscapeRatio
        self.interval = interval
        
        self.update(width: screenWidth,
                    isLandscape: UIDevice.current.orientation == .landscapeLeft ||
                    UIDevice.current.orientation == .landscapeRight,
                    interval: interval)
    }
    
    func update(width: CGFloat, isLandscape: Bool, interval: CGFloat) {
        self._width = width / unit - interval
        
        if isLandscape {
            _height = self._width * landscapeRatio
        } else {
            _height = self._width
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(_width)
        hasher.combine(_height)
        hasher.combine(unit)
        hasher.combine(landscapeRatio)
        hasher.combine(interval)
    }
    
    static func == (lhs: SizeState, rhs: SizeState) -> Bool {
        return lhs._width == rhs._width &&
        lhs._height == rhs._height &&
        lhs.unit == rhs.unit &&
        lhs.landscapeRatio == rhs.landscapeRatio &&
        lhs.interval == rhs.interval
    }
}
