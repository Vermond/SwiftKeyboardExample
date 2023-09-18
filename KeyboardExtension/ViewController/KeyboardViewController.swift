//
//  KeyboardViewController.swift
//
//  Created by Jinsu Gu on 2023/04/24.
//

import UIKit
import SwiftUI

class KeyboardViewController: UIInputViewController {
    private var customView: KeyboardView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a SwiftUI view and wrap it in a UIHostingController
        customView = KeyboardView()
        let hostingController = UIHostingController(rootView: customView)
        
        // Add the hosting controller's view to the input view controller's view hierarchy
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        // Configure constraints for the hosting controller's view
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        InputController.shared.setInputVC(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        InputController.shared.clearInputVC()
    }
    
    override func viewLayoutMarginsDidChange() {
        super.viewLayoutMarginsDidChange()
        
        if let size = self.inputView?.layoutMarginsGuide.layoutFrame.size {
            customView.deviceInfoSubject.send((size, isLandscape))
        }
    }
    
    private var isLandscape: Bool {
        return UIScreen.main.bounds.width > UIScreen.main.bounds.height
    }
}
