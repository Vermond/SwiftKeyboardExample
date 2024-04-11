//
//  Keyboard.swift
//  Keysemble
//
//  Created by Jinsu Gu on 2/19/24.
//

import Foundation
import SwiftUI
import Combine

struct Keyboard {
    @ObservedObject private(set) var model: ViewModel
    private var rows: [KeyRow]
    
    var uuidList: [KeyRowIdInfo] {
        var list: [KeyRowIdInfo] = []
        
        for row in rows {
            list.append(row.uuidInfo)
        }
        
        return list
    }
    
    init() {
        model = ViewModel(space: 0, backColor: .clear)
        rows = []
    }
    
    init(rows: [KeyRow], model: ViewModel) {
        self.rows = rows
        self.model = model
        
        self.model.update(uuidList: uuidList)
    }
    
    func unlink() {
        self.model.unsetCancellable()
    }
}

extension Keyboard {
    class ViewModel: ObservableObject {
        @Published private(set) var space: CGFloat
        @Published private(set) var backColor: Color
        
        @Published var keyboardSize: CGSize = .zero
        
        private var cancellables = Set<AnyCancellable>()
        
        init(space: CGFloat,
             backColor: Color)
        {
            self.space = space
            self.backColor = backColor
            
            self.setCancellable(mediator: KeyboardUIEventMediator.shared)
            KeyboardUIController.shared.update(space: space)
        }
        
        deinit {
            unsetCancellable()
        }
        
        fileprivate func setCancellable(mediator: KeyboardUIEventMediator) {
            mediator.publisher
                .sink { [weak self] event in
                    switch event {
                    case .backColorChanged(let newValue, _):
                        self?.update(backColor: newValue)
                        break
                    case .spaceChanged(let space):
                        self?.update(space: space)
                        break
                    case .areaSizeChanged(let size):
                        self?.update(size: size)
                        break
                    default:
                        break
                    }
                }
                .store(in: &cancellables)
        }
        
        fileprivate func unsetCancellable() {
            cancellables.removeAll()
        }
        
        fileprivate func update(space: CGFloat) {
            self.space = space
            KeyboardUIController.shared.update(space: space)
            
            self.objectWillChange.send()
        }
        
        fileprivate func update(backColor: Color) {
            self.backColor = backColor
            
            self.objectWillChange.send()
        }
        
        func update(uuidList: [KeyRowIdInfo]) {
            KeyboardUIController.shared.update(uuidList: uuidList)
        }
        
        fileprivate func update(size: CGSize) {
            self.keyboardSize = size
            sendEvent(event: .rowSizeChanged(sizeInfo: KeyboardUIController.shared.sizeInfo))
        }
        
        fileprivate func sendEvent(event: KeyboardUIEventType) {
            KeyboardUIEventMediator.shared.sendEvent(event)
        }
    }
}

extension Keyboard: View {
    @ViewBuilder
    var body: some View {
        VStack(alignment: .center, spacing: model.space, content: {
            ForEach(rows, id: \.id) { keyRow in
                keyRow
            }
        })
        .frame(width: model.keyboardSize.width, height: model.keyboardSize.height)
        .background(model.backColor)
    }
}
//
//struct Keyboard_Previews: PreviewProvider {
//    static var previews: some View {
//        let size = CGSize(width: 380, height: 612) //portrait preview size
////        let size = CGSize(width: 612, height: 612) // landscape preview size
//        let view = Keyboard()
//        view.deviceInfoSubject.send((size, false))
//        return view
//    }
//}
