//
//  KeyboardViewController.swift
//
//  Created by Jinsu Gu on 2023/04/24.
//

import UIKit
import SwiftUI
import Foundation
import Combine

class KeyboardInputViewController: UIInputViewController {
    private var hostingController: UIHostingController<Keyboard?>!
    private var cancellables = Set<AnyCancellable>()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        setCancellable(mediator: KeyboardLayoutEventMediator.shared)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setHostingController(data: KeyboardUIController.shared.currentData)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        InputController.shared.setInputVC(self)
        
        if let guide = self.inputView?.layoutMarginsGuide {
            KeyboardLayoutEventMediator.shared.sendEvent(.willAppear(size: guide.layoutFrame.size))
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let inputView {
            let width = inputView.layoutMargins.left + inputView.layoutMargins.right + inputView.layoutMarginsGuide.layoutFrame.width
            let height = inputView.layoutMargins.bottom + inputView.layoutMargins.top + inputView.layoutMarginsGuide.layoutFrame.height
            KeyboardLayoutEventMediator.shared.sendEvent(.didAppear(size: .init(width: width, height: height)))
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        InputController.shared.setInputVC(nil)
        unsetCancellable()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        KeyboardLayoutEventMediator.shared.sendEvent(.willTransition(size: size))
    }
    
    fileprivate func setCancellable(mediator: KeyboardLayoutEventMediator) {
        mediator.publisher
            .sink { [weak self] event in
                switch event {
                case .loaded(let data):
                    self?.setHostingController(data: data)
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    fileprivate func unsetCancellable() {
        self.hostingController?.rootView?.unlink()
        cancellables.removeAll()
    }
    
    fileprivate func setHostingController(data: KeyboardData) {
        let customView = data.toView()
        
        KeyboardUIEventMediator.shared.sendEvent(.backColorChanged(newValue: data.backColor.toColor(), isOverwrite: false))
        KeyboardUIEventMediator.shared.sendEvent(.buttonColorChanged(newValue: data.buttonColor.toColor(), isOverwrite: false))
        KeyboardUIEventMediator.shared.sendEvent(.textColorChanged(newValue: data.textColor.toColor(), isOverwrite: false))
        KeyboardUIEventMediator.shared.sendEvent(.roundChanged(round: data.round))
        KeyboardUIEventMediator.shared.sendEvent(.spaceChanged(space: data.space))
        
        hostingController?.rootView?.unlink()
        hostingController?.view.removeFromSuperview()
        hostingController?.removeFromParent()        
        
        hostingController = UIHostingController(rootView: customView)
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
