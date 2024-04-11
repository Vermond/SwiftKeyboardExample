//
//  KeyButton.swift
//  KeysembleBoard
//
//  Created by Jinsu Gu on 2/19/24.
//

import Foundation
import Combine
import SwiftUI

struct KeyButton {
    @ObservedObject private(set) var model: ViewModel
    
    let id = UUID()    
        
    init(model: ViewModel) {
        self.model = model
        model.setUUID(id: id)
        model.setCancellable(mediator: KeyboardUIEventMediator.shared)
    }
}

extension KeyButton {
    class ViewModel: ObservableObject {
        @Published var width: CGFloat
        @Published var height: CGFloat
        
        @Published private(set) var charColor: Color?
        @Published private(set) var backColor: Color?
        @Published private(set) var round: CGFloat
        
        @Published private(set) var mainText: String
        @Published private(set) var subText: [String: String]
        @Published private(set) var keyAction: () -> Void
        @Published private(set) var subAction: [String: () -> Void]
        
        private var cancellables = Set<AnyCancellable>()
        private var id: UUID?
        
        init(width: CGFloat? = 1,
             charColor: Color? = nil,
             backColor: Color? = nil,
             round: CGFloat? = 0,
             mainText: String = "",
             subText: [String: String] = [:],
             keyAction: @escaping () -> Void = { },
             subAction: [String: () -> Void] = [:] )
        {
            self.width = width ?? 1
            self.height = 1
            
            self.charColor = charColor
            self.backColor = backColor
            self.round = round ?? 0
            
            self.mainText = mainText
            self.subText = subText
            
            self.keyAction = keyAction
            self.subAction = subAction
        }
        
        fileprivate func setUUID(id: UUID) {
            self.id = id
        }
        
        fileprivate func setCancellable(mediator: KeyboardUIEventMediator) {
            mediator.publisher
                .sink { [weak self] event in
                    switch event {
                    case .buttonColorChanged(let newValue, let isOverwrite):
                        self?.update(backColor: newValue, isOverwrite: isOverwrite)
                        break
                    case .textColorChanged(let newValue, let isOverwrite):
                        self?.update(charColor: newValue, isOverwrite: isOverwrite)
                        break
                    case .keySizeChanged(let sizeInfo):
                        if let id = self?.id, sizeInfo.id == id {
                            self?.update(width: sizeInfo.width, height: sizeInfo.height)
                        }
                        break
                    case .roundChanged(let round):
                        self?.update(round: round)
                    default:
                        break
                    }
                }
                .store(in: &cancellables)
        }
        
        fileprivate func update(charColor: Color, isOverwrite: Bool) {
            if self.charColor == nil || isOverwrite {
                self.charColor = charColor
                
                self.objectWillChange.send()
            }
        }
        
        fileprivate func update(backColor: Color, isOverwrite: Bool) {
            if self.backColor == nil || isOverwrite {
                self.backColor = backColor
                
                self.objectWillChange.send()
            }
        }
        
        fileprivate func update(width: CGFloat, height: CGFloat) {
            self.width = width
            self.height = height
            
            self.objectWillChange.send()
        }
        
        fileprivate func update(round: CGFloat) {
            self.round = round
            
            self.objectWillChange.send()
        }
    }
}

extension KeyButton: View {
    @ViewBuilder
    var body: some View {
        Button(action: {
            model.keyAction()
        } , label: {
            VStack(alignment: .center) {
                Text(model.subText["top"] ?? "")
                    .foregroundStyle(Color.gray)
                    .font(.caption)
                Spacer(minLength: 0.001)
                HStack(alignment: .center) {
                    Text(model.subText["left"] ?? "")
                        .foregroundStyle(Color.gray)
                        .font(.caption)
                    Spacer(minLength: 0.001)
                    Text(model.mainText)
                        .foregroundStyle(model.charColor ?? .black) //TODO: need to be fixed
                        .font(.body)
                        .foregroundStyle(Color.black)
                    Spacer(minLength: 0.001)
                    Text(model.subText["right"] ?? "")
                        .foregroundStyle(Color.gray)
                        .font(.caption)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 1)
                Spacer(minLength: 0.001)
                Text(model.subText["bottom"] ?? "")
                    .foregroundStyle(Color.gray)
                    .font(.caption)
            }
            .frame(maxHeight: .infinity)
            .padding(.vertical, 1)
        })
        .frame(width: model.width, height: model.height)
        .contentShape(Rectangle())
        .background(model.backColor ?? .clear)
        .clipShape(RoundedRectangle(cornerRadius: model.round))
    }
}

extension KeyButton: Identifiable {
}
