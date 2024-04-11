//
//  KeyboardUIController.swift
//  Keysemble
//
//  Created by Jinsu Gu on 3/18/24.
//

import Foundation
import SwiftUI
import Combine

fileprivate let maxMag: CGFloat = 10
fileprivate let dataKey = "CurrentKeyboardData"
fileprivate let reservedKey = "ReservedKeyboardData"
fileprivate let defaultDataName = "ENGample"

fileprivate var landRatio = CGFloat(0.25)
fileprivate var portRatio = CGFloat(0.4)

typealias KeySizeInfo = (id: UUID, width: CGFloat, height: CGFloat)
typealias SizeInfo = [UUID : (height: CGFloat, width: [KeySizeInfo])]

class KeyboardUIController {
    public static let shared = KeyboardUIController()
    
    private var previousData: KeyboardData?
    private(set) var currentData: KeyboardData {
        willSet { previousData = currentData }
        didSet {
            if let name = previousData?.reservedName {
                UserDefaults.standard.set(name, forKey: reservedKey)
            }
            UserDefaults.standard.set(currentData.name, forKey: dataKey)
            KeyboardLayoutEventMediator.shared.sendEvent(.loaded(data: currentData))
        }
    }
    private var inputLimit: Int = -1
    
    private(set) var uuidList: [KeyRowIdInfo] = []
    private(set) var sizeInfo: SizeInfo = [:]
    
    private var screenSize: CGSize = .zero
    private var areaSize: CGSize = .zero
    
    private var space: CGFloat = .nan
    private var cancellables = Set<AnyCancellable>()
    
    var reservedName: String { UserDefaults.standard.string(forKey: reservedKey) ?? defaultDataName }
    
    fileprivate init() {
        if let fileName = UserDefaults.standard.value(forKey: dataKey) as? String, fileName != "" {
            self.currentData = KeyboardData.from(fileName: fileName)
        } else {
            self.currentData = KeyboardData.from(fileName: defaultDataName)
            UserDefaults.standard.set(defaultDataName, forKey: dataKey)
        }
        
        self.setCancellable(mediator: KeyboardLayoutEventMediator.shared)
        self.setCancellable(mediator: KeyActionEventMediator.shared)
    }
    
    deinit {
        unsetCancellable()
    }
    
    fileprivate func setCancellable(mediator: KeyboardLayoutEventMediator) {
        mediator.publisher
            .sink { [weak self] event in
                switch event {
                case .willAppear(let size):
                    self?.update(screenSize: size)
                    break
                case .didAppear(let size):
                    self?.updateOrientation(size: size)
                    break
                case .willTransition(let size):
                    self?.updateOrientation(size: size)
                    break
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    fileprivate func setCancellable(mediator: KeyActionEventMediator) {
        mediator.publisher
            .sink { [weak self] event in
                switch event {
                case .keyInput:
                    self?.reduceCount()
                    break
//                default:
//                    break
                }
            }
            .store(in: &cancellables)
    }
    
    fileprivate func unsetCancellable() {
        cancellables.removeAll()
    }
    
    func update(uuidList: [KeyRowIdInfo]) {
        self.uuidList = uuidList
        
        if space != .nan && self.areaSize != .zero && !uuidList.isEmpty {
            calculateSize()
        }
    }
    
    func update(data: KeyboardData, limit: Int = -1) {
        self.space = .nan
        self.uuidList.removeAll()
        
        self.currentData = data
        self.inputLimit = limit
    }
    
    func update(space: CGFloat) {
        self.space = space
        
        if space != .nan && self.areaSize != .zero && !uuidList.isEmpty {
            calculateSize()
        }
    }
    
    private func update(screenSize: CGSize) {
        self.screenSize = screenSize
    }
    
    private func updateOrientation(size: CGSize) {
        areaSize = getKeyboardSize(size: size)
        
        if space != .nan && self.areaSize != .zero && !uuidList.isEmpty {
            calculateSize()
        }
    }
    
    
    private func getKeyboardSize(size: CGSize) -> CGSize {
        guard size != .zero else { return .zero }
        
        let shorter = screenSize.width > screenSize.height ? screenSize.height : screenSize.width
        let isLandscape = shorter == size.width
                
        if isLandscape {
            let base = screenSize.width > screenSize.height ? screenSize.width : screenSize.height
            return CGSize(width: size.width, height: base * landRatio)
        } else {
            let base = screenSize.width < screenSize.height ? screenSize.width : screenSize.height
            return CGSize(width: size.width, height: base * portRatio)
        }
    }
    
    private func calculateSize() {
        sizeInfo.removeAll()
        
        var heightSum = CGFloat.zero
        var heightRemain = areaSize.height - space
        
        for row in currentData.keyRowData {
            if row.height > maxMag {
                heightRemain -= row.height
            } else {
                heightSum += row.height
            }
            
            heightRemain -= space
        }
        
        for i in 0..<currentData.keyRowData.count {
            let rowId = uuidList[i].id
            var height: CGFloat = currentData.keyRowData[i].height
            
            if height <= maxMag {
                height = heightRemain * height / heightSum
            }
            
            var sum = CGFloat.zero
            var remain = areaSize.width - space
            var keySizeInfoList = [KeySizeInfo]()
            
            for j in 0..<currentData.keyRowData[i].keyButtonData.count {
                let width = currentData.keyRowData[i].keyButtonData[j].width
                
                if width > maxMag {
                    remain -= width
                } else {
                    sum += width
                }
                
                remain -= space
            }
            
            for j in 0..<currentData.keyRowData[i].keyButtonData.count {
                let width = currentData.keyRowData[i].keyButtonData[j].width
                let id = uuidList[i].list[j]
                
                if width > maxMag {
                    keySizeInfoList.append((id, width, height))
                } else {
                    keySizeInfoList.append((id, remain * width / sum, height))
                }
            }
            
            sizeInfo[rowId] = (height, keySizeInfoList)
        }
        
        KeyboardUIEventMediator.shared.sendEvent(.areaSizeChanged(size: areaSize))
    }
    
    private func reduceCount() {
        if inputLimit > -1 {
            inputLimit -= 1
        }
        
        if inputLimit == 0 {
            if let data = self.previousData {
                self.update(data: data, limit: -1)
            }
        }
    }
}
