//
//  UndoButtonViewController.swift
//  Unredactor
//
//  Created by Tyler Gee on 2/24/20.
//  Copyright © 2020 tyler. All rights reserved.
//

import UIKit

class UndoButtonViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak private var undoButton: UIButton!
    
    // MARK: - Private properties
    private var isShown: Bool = false
    
    private let fadeInAnimationKey: String = "fadeInAnimation"
    private var fadeInAnimation: CABasicAnimation {
        let fadeInAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity), toValue: 1.0, fromValue: 0.0, duration: 0.8)
        
        return fadeInAnimation
    }
    private let fadeOutAnimationKey: String = "fadeOutAnimation"
    private var fadeOutAnimation: CABasicAnimation {
        let fadeOutAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity), toValue: 0.0, fromValue: view.alpha, duration: 0.8)
        return fadeOutAnimation
    }

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }
    
    // MARK: - Interface (public methods)
    func show() {
        guard !isShown else { return }
        
        // Fade in the button
        //undoView.layer.add(fadeInAnimation, forKey: fadeInAnimationKey)
        view.layer.add(fadeInAnimation, forKey: fadeInAnimationKey)
        
        isShown = true
    }
    
    func hide() {
        guard isShown else { return }
        
        // Fade out the label
        view.layer.add(fadeOutAnimation, forKey: fadeOutAnimationKey)
        
        isShown = false
    }

}

fileprivate extension UndoButtonViewController {
    func setupViews() {
        // Make view have rounded corners
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor.darkGray
        view.alpha = 0.0
        
        // Make undo button label white
        undoButton.titleLabel?.textColor = .white
    }
}
