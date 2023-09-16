//
//  PickerTextField.swift
//  KeyboardExampleApp
//
//  Created by Jinsu Gu on 2023/09/04.
//
// from https://diamantidis.github.io/2020/06/21/keyboard-options-for-swiftui-fields

import SwiftUI

class PickerTextField: UITextField {
    var data: [String]
    @Binding var selectedIndex: Int?
    
    init(data: [String], selectedIndex: Binding<Int?>) {
        self.data = data
        self._selectedIndex = selectedIndex
        
        super.init(frame: .zero)
        
        self.inputView = pickerView
        self.inputAccessoryView = toolbar
        self.tintColor = .clear
        self.frame.size.height = 10
        
        guard let selectedIndex = selectedIndex.wrappedValue else {
            return
        }
        
        self.pickerView.selectRow(selectedIndex, inComponent: 0, animated: true)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var pickerView: UIPickerView = {
        let pv = UIPickerView()
        pv.delegate = self
        pv.dataSource = self
        return pv
    }()
    
    private lazy var toolbar: UIToolbar = {
        let tb = UIToolbar()
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done",
                                         style: .done,
                                         target: self,
                                         action: #selector(donePressed))
        
        tb.setItems([space, doneButton], animated: false)
        tb.sizeToFit()
        
        return tb
    }()
    
    @objc
    private func donePressed() {
        self.selectedIndex = self.pickerView.selectedRow(inComponent: 0)
        self.endEditing(true)
    }
}

extension PickerTextField: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.data.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.data[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedIndex = row
    }
}
