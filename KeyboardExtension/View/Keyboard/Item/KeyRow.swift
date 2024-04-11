//
//  KeyRow.swift
//  KeysembleBoard
//
//  Created by Jinsu Gu on 2/19/24.
//

import Foundation
import Combine
import SwiftUI

typealias KeyRowIdInfo = (id: UUID, list: [UUID])

struct KeyRow {
    @ObservedObject private(set) var model: ViewModel
    
    let id = UUID()
    private var items: [KeyButton]
    
    public var uuidInfo: KeyRowIdInfo {
        var list = [UUID]()
        
        for item in items {
            list.append(item.id)
        }
        
        return (id, list)
    }
    
    init(items: [KeyButton], model: ViewModel) {
        self.items = items
        self.model = model
        self.model.setUUID(id: id)
        self.model.setCancellable(mediator: KeyboardUIEventMediator.shared)
    }
}

extension KeyRow {
    class ViewModel: ObservableObject {
        @Published private(set) var backColor: Color?
                
        @Published private(set) var height: CGFloat
        @Published private(set) var space: CGFloat?
        
        private var cancellables = Set<AnyCancellable>()
        private var id: UUID?
                
        init(backColor: Color? = nil,
             height: CGFloat? = 1,
             space: CGFloat? = nil)
        {
            self.backColor = backColor
            self.height = height ?? 1
            self.space = space
        }
        
        fileprivate func setUUID(id: UUID) {
            self.id = id
        }
        
        fileprivate func setCancellable(mediator: KeyboardUIEventMediator) {
            mediator.publisher
                .sink { [weak self] event in
                    switch event {
                    case .rowSizeChanged(let sizeInfo):
                        if let id = self?.id, let data = sizeInfo[id] {
                            self?.update(data.height)
                            
                            for info in data.width {
                                KeyboardUIEventMediator.shared.sendEvent(.keySizeChanged(sizeInfo: info))
                            }
                        }
                        break
                    case .spaceChanged(let space):
                        self?.update(space: space)
                        break
                    default:
                        break
                    }
                }
                .store(in: &cancellables)
        }
        
        fileprivate func update(_ height: CGFloat) {
            self.height = height
            self.objectWillChange.send()
        }
        
        fileprivate func update(backColor: Color, isOverwrite: Bool) {
            if self.backColor == nil || isOverwrite {
                self.backColor = backColor
                self.objectWillChange.send()
            }
        }
        
        fileprivate func update(space: CGFloat) {
            self.space = space
            self.objectWillChange.send()
        }
    }
}

extension KeyRow: View {
    @ViewBuilder
    var body: some View {
        HStack(alignment: .center, spacing: model.space ?? 0, content: {
            ForEach(items) { keyButton in
                keyButton
            }
        })
        .frame(height: model.height)
        .background(model.backColor ?? .clear)
    }
}

extension KeyRow: Identifiable {
    
}
