//
//  SwitchViewController.swift
//  Unredactor
//
//  Created by Tyler Gee on 8/6/19.
//  Copyright © 2019 tyler. All rights reserved.
//

import UIKit

// MARK: - Delegate
protocol SwitchViewControllerDelegate: class {
    func switchWasToggled(to state: EditMode)
}

// MARK: - Class Definition
/**
 SwitchViewController manages a switch view: a simple view that allows you to switch between the editing and redacting modes
 by using either a switch or by tapping on the respective labels.
*/
class SwitchViewController: UIViewController, CAAnimationDelegate {
    
    // MARK: - Properties
    @IBOutlet weak var stateSwitch: UISwitch!
    
    @IBOutlet weak var editLabel: UILabel!
    @IBOutlet weak var redactLabel: UILabel!
    /// A label to indicate to the user how to redact text. Shows up once the user is able to redact (when there is any text)
    @IBOutlet weak var instructionLabel: UILabel!
    
    var state: EditMode = .editable
    
    weak var delegate: SwitchViewControllerDelegate?
    
    private let animationDuration: TimeInterval = 2.0
    private let shadowRadius: CGFloat = 5
    
    private let pulseAnimationKey: String = "pulseAnimation"
    private var pulseAnimation: CABasicAnimation {
        let pulseAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        pulseAnimation.duration = 0.8
        pulseAnimation.fromValue = instructionLabel.alpha
        pulseAnimation.toValue = 0
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .greatestFiniteMagnitude
        
        return pulseAnimation
    }
    
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch state {
        case .editable:
            editLabel.textColor = .white
        case .redactable:
            redactLabel.textColor = .white
        }
                
        giveFadeAnimation(toLabel: editLabel)
        giveFadeAnimation(toLabel: redactLabel)
        
        instructionLabel.alpha = 0.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateSwitchDirection()
        updateViews(isAnimated: false)
    }
    
    func showInstructionLabel() {
        UIView.animate(withDuration: 0.5, animations: { [unowned self] in
            self.instructionLabel.alpha = 1.0
            }, completion: { [unowned self] (bool) in
                self.instructionLabel.layer.add(self.pulseAnimation, forKey: self.pulseAnimationKey)
        })
    }
    
    func hideInstructionLabel() {
        instructionLabel.layer.removeAllAnimations()
        
        UIView.animate(withDuration: 0.5) { [unowned self] in
            self.instructionLabel.alpha = 0.0
        }
    }
    
    // MARK: - IBActions
    @IBAction func editButtonPressed(_ sender: Any) {
        state = .redactable
        updateSwitchDirection()
        updateViews(isAnimated: false)
        delegate?.switchWasToggled(to: .editable)
        hideInstructionLabel()
    }
    
    @IBAction func redactButtonPressed(_ sender: Any) {
        state = .editable
        updateSwitchDirection()
        updateViews(isAnimated: false)
        delegate?.switchWasToggled(to: .redactable)
        showInstructionLabel()
    }
    
    @IBAction func toggleSwitch(_ sender: UISwitch) {
        state = state.toggled()
        updateViews(isAnimated: false)
        
        delegate?.switchWasToggled(to: state)
        (state == .editable) ? hideInstructionLabel() : showInstructionLabel()
    }
}

// MARK: - Helper Functions
fileprivate extension SwitchViewController {
    func updateViews(isAnimated animated: Bool) { // Changes the appearance of the views to reflect
        
        if state == .editable {
            removeGlowEffect(from: stateSwitch, isAnimated: animated)
            addGlowEffect(to: editLabel, isAnimated: animated)
            removeGlowEffect(from: redactLabel, isAnimated: animated)
        } else {
            addGlowEffect(to: stateSwitch, isAnimated: animated)
            addGlowEffect(to: redactLabel, isAnimated: animated)
            removeGlowEffect(from: editLabel, isAnimated: animated)
        }
    }
    
    func updateSwitchDirection() { // Change the direction of the switch according to the state
        stateSwitch.isOn = state == .editable ? false : true
    }
    
    func addGlowEffect(to view: UIView, isAnimated animated: Bool) { // Give a label a transparent white shadow, simulating a glow
        let duration: TimeInterval = animated ? animationDuration : 0.0
        
        view.layer.shadowColor = UIColor.white.cgColor
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = shadowRadius
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.scale
        
        let opacityAnimation = CABasicAnimation(keyPath: "shadowOpacity")
        opacityAnimation.fromValue = view.layer.shadowOpacity
        opacityAnimation.toValue = 0.95
        opacityAnimation.duration = duration
        opacityAnimation.fillMode = CAMediaTimingFillMode.forwards
        opacityAnimation.isRemovedOnCompletion = false
        view.layer.add(opacityAnimation, forKey: "opacityAnimationGlow")
        
        if let label = view as? UILabel {
            label.textColor = .white
        }
    }
    
    func giveFadeAnimation(toLabel label: UILabel) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.fade
        animation.duration = animationDuration
        animation.delegate = self
        label.layer.add(animation, forKey: "kCATransitionFade")
    }
    
    func removeGlowEffect(from view: UIView, isAnimated animated: Bool) { // Make the shadow completely transparent
        let duration: TimeInterval = animated ? animationDuration : 0.0
        
        view.layer.shadowColor = UIColor.white.cgColor
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = shadowRadius
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.scale
        
        let opacityAnimation = CABasicAnimation(keyPath: "shadowOpacity")
        opacityAnimation.fromValue = view.layer.shadowOpacity
        opacityAnimation.toValue = 0.0
        opacityAnimation.duration = duration
        opacityAnimation.fillMode = CAMediaTimingFillMode.forwards
        opacityAnimation.isRemovedOnCompletion = false
        view.layer.add(opacityAnimation, forKey: "opacityAnimationFade")
        
        if let label = view as? UILabel {
            if label == editLabel { label.textColor = EditMode.editable.textColor }
            else if label == redactLabel { label.textColor = EditMode.redactable.textColor }
        }
    }
}

