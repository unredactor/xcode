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
    func clearText()
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
    @IBOutlet weak var clearTextButton: UIButton!
    
    
    var state: EditMode = .editable
    
    weak var delegate: SwitchViewControllerDelegate?
    private var instructionLabelViewController: InstructionLabelViewController!
    
    private let animationDuration: TimeInterval = 2.0
    private let shadowRadius: CGFloat = 5
    private let editModeText = "Enter Redaction Mode"
    private let redactModeText = "Enter Edit Mode"
    
    /*
    private let pulseAnimationKey: String = "pulseAnimation"
    private var pulseAnimation: CABasicAnimation {
        let pulseAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        pulseAnimation.duration = 0.8
        pulseAnimation.fromValue = instructionLabel.alpha
        pulseAnimation.toValue = 0.4
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .greatestFiniteMagnitude
        
        return pulseAnimation
    }
 */
    
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateViews(isAnimated: true)
                
        giveFadeAnimation(toLabel: editLabel)
        giveFadeAnimation(toLabel: redactLabel)
        
        instructionLabelViewController.setInstructionText(to: "Tap words to redact them")
        
        clearTextButton.titleLabel?.numberOfLines = 0 // Infinite lines so that it stacks
        clearTextButton.titleLabel?.textAlignment = .center
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateSwitchDirection()
        updateViews(isAnimated: false)
    }
    
    func showInstructionLabel() {
        instructionLabelViewController.show()
    }
    
    func hideInstructionLabel() {
        instructionLabelViewController.hide()
    }
    
    func setSwitch(to state: EditMode) {
        switch state {
        case .editable: setSwitchEditable()
        case .redactable: setSwitchRedactable()
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func editButtonPressed(_ sender: Any) {
        guard state != .editable else { return }
        
        setSwitchEditable()
    }
    
    @IBAction func redactButtonPressed(_ sender: Any) {
        guard state != .redactable else { return }
        
        setSwitchRedactable()
    }
    
    @IBAction func clearTextButtonPressed(_ sender: Any) {
        delegate?.clearText()
    }
    
    @IBAction func toggle(_ sender: UISwitch) {
        state = state.toggled()
        updateViews(isAnimated: false)
        
        delegate?.switchWasToggled(to: state)
        (state == .editable) ? hideInstructionLabel() : showInstructionLabel()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let instructionLabelViewController as InstructionLabelViewController:
            self.instructionLabelViewController = instructionLabelViewController
        default: break
        }
    }
}

// MARK: - Helper Functions
fileprivate extension SwitchViewController {
    func updateViews(isAnimated animated: Bool) { // Changes the appearance of the views to reflect
        
        if state == .editable {
            removeGlowEffect(from: stateSwitch, isAnimated: animated)
            addGlowEffect(to: editLabel, isAnimated: animated)
            removeGlowEffect(from: redactLabel, isAnimated: animated)
            instructionLabelViewController.setInstructionText(to: "Switch to redact mode to redact words")
        } else {
            addGlowEffect(to: stateSwitch, isAnimated: animated)
            addGlowEffect(to: redactLabel, isAnimated: animated)
            removeGlowEffect(from: editLabel, isAnimated: animated)
            instructionLabelViewController.setInstructionText(to: "Tap words to redact them")
        }
    }
    
    func setSwitchEditable() {
        state = .editable
        updateSwitchDirection()
        updateViews(isAnimated: false)
        delegate?.switchWasToggled(to: .editable)
        //hideInstructionLabel()
    }
    
    func setSwitchRedactable() {
        state = .redactable
        updateSwitchDirection()
        updateViews(isAnimated: false)
        delegate?.switchWasToggled(to: .redactable)
        //showInstructionLabel()
    }
    
    
    func updateSwitchDirection() { // Change the direction of the switch according to the state
        let isOn = state == .editable ? false : true
        stateSwitch.setOn(isOn, animated: true)
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

