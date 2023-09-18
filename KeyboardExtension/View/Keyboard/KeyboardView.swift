//
//  KeyboardView.swift
//  SwiftKeyboard
//
//  Created by Jinsu Gu on 2023/04/25.
//

import SwiftUI
import Combine

struct KeyboardView: View {
    @StateObject private var viewModel: KeyboardViewModel = KeyboardViewModel()
    
    let deviceInfoSubject = CurrentValueSubject<(size: CGSize, isLandscape: Bool), Never>((.zero, false))
        
    var body: some View {
        viewModel.keyButtonView
            .onReceive(deviceInfoSubject) { info in
                viewModel.update(info.size, isLandscape: info.isLandscape)
            }
    }
}

struct KeyboardView_Previews: PreviewProvider {
    static var previews: some View {
        let size = CGSize(width: 414, height: 612) //portrait preview size
//        let size = CGSize(width: 612, height: 612) // landscape preview size
        let view = KeyboardView()
        view.deviceInfoSubject.send((size, false))
        return view
    }
}
