//
//  ContentView.swift
//  SwiftKeyboard
//
//  Created by Jinsu Gu on 2023/04/24.
//

import SwiftUI

struct ContentView: View {
    @State private var text: String = ""
    @State var selectedIndex: Int? = nil
    
    let options = ["1st", "2nd", "3rd"]
    
    var body: some View {
        VStack {
            Text("일반 텍스트 입력 테스트")
            TextField("일반 텍스트 입력", text: $text)
                .multilineTextAlignment(.center)
                .padding()
                .toolbar {
                    ToolbarItem(placement: .keyboard) {
                        Button("Do something") {
                            print("something")
                        }
                    }
                }
                .border(.black, width: 1)
            Text("PickerView 사용 테스트")
            PickerField("선택하세요", data: self.options, selectedIndex: self.$selectedIndex)
                .padding()
                .border(.black, width: 1)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
