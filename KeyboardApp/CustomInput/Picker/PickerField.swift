//
//  PickerField.swift
//  KeyboardExampleApp
//
//  Created by Jinsu Gu on 2023/09/04.
//
// from https://diamantidis.github.io/2020/06/21/keyboard-options-for-swiftui-fields

import SwiftUI

struct PickerField: UIViewRepresentable {
    @Binding var selectedIndex: Int?
    
    private var placeholder: String
    private var data: [String]
    private let textField: PickerTextField
    
    init<S>(_ title: S, data: [String], selectedIndex: Binding<Int?>) where S: StringProtocol {
        self.placeholder = String(title)
        self.data = data
        self._selectedIndex = selectedIndex
        
        textField = PickerTextField(data: data, selectedIndex: selectedIndex)
    }
    
    func makeUIView(context: UIViewRepresentableContext<PickerField>) -> UITextField {
        textField.placeholder = placeholder
        textField.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<PickerField>) {
        if let selectedIndex {
            uiView.text = data[selectedIndex]
        } else {
            uiView.text = ""
        }
    }
}

