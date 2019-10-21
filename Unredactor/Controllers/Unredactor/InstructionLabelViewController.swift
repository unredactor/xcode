//
//  InstructionLabelViewController.swift
//  Unredactor
//
//  Created by Tyler Gee on 10/20/19.
//  Copyright © 2019 tyler. All rights reserved.
//

import UIKit

class InstructionLabelViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak private var instructionLabel: UILabel!
    
    // MARK: - Private properties
    private var isShown: Bool = false
    
    private let pulseAnimationKey: String = "pulseAnimation"
    private var pulseAnimation: CABasicAnimation {
        let pulseAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        pulseAnimation.duration = 0.8
        pulseAnimation.fromValue = 0.6
        pulseAnimation.toValue = 1.0
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .greatestFiniteMagnitude
        
        return pulseAnimation
    }
    private let fadeInAnimationKey: String = "fadeInAnimation"
    private var fadeInAnimation: CABasicAnimation {
        let fadeInAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity), toValue: 1.0, fromValue: 0.0, duration: 0.8)
        
        return fadeInAnimation
    }
    private let fadeOutAnimationKey: String = "fadeOutAnimation"
    private var fadeOutAnimation: CABasicAnimation {
        let fadeOutAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity), toValue: 0.0, fromValue: instructionLabel.alpha, duration: 0.8)
        
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
        
        // Add pulse animation to the background view
        view.layer.add(pulseAnimation, forKey: pulseAnimationKey)
        
        // Fade in the label
        instructionLabel.layer.add(fadeInAnimation, forKey: fadeInAnimationKey)
        
        isShown = true
    }
    
    func hide() {
        guard isShown else { return }
        
        // Remove pulse animation
        view.layer.removeAnimation(forKey: pulseAnimationKey)
        
        // Fade out the label
        view.layer.add(fadeOutAnimation, forKey: fadeOutAnimationKey)
        
        isShown = false
    }
    
    func setInstructionText(to text: String) {
        instructionLabel.text = text
    }

}

fileprivate extension InstructionLabelViewController {
    func setupViews() {
        // Make view have rounded corners
        view.layer.cornerRadius = 6
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.8)
        view.alpha = 0.0
        
        // Make instruction label white
        instructionLabel.textColor = .white
        instructionLabel.alpha = 0.0
    }
    
    
}
