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
    
    var state: EditMode = .edit
    
    weak var delegate: SwitchViewControllerDelegate?
    
    private let animationDuration: TimeInterval = 2.0
    private let shadowRadius: CGFloat = 5
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch state {
        case .edit:
            editLabel.textColor = .white
        case .redact:
            redactLabel.textColor = .white
        }
        
        giveFadeAnimation(toLabel: editLabel)
        giveFadeAnimation(toLabel: redactLabel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateSwitchDirection()
        updateViews(isAnimated: false)
    }
    
    // MARK: - IBActions
    @IBAction func editButtonPressed(_ sender: Any) {
        state = .edit
        updateSwitchDirection()
        updateViews(isAnimated: false)
        delegate?.switchWasToggled(to: .edit)
    }
    
    @IBAction func redactButtonPressed(_ sender: Any) {
        state = .redact
        updateSwitchDirection()
        updateViews(isAnimated: false)
        delegate?.switchWasToggled(to: .edit)
    }
    
    @IBAction func toggleSwitch(_ sender: UISwitch) {
        state = state.toggled()
        updateViews(isAnimated: false)
        
        delegate?.switchWasToggled(to: state)
    }
}

// MARK: - Helper Functions
fileprivate extension SwitchViewController {
    func updateViews(isAnimated animated: Bool) { // Changes the appearance of the views to reflect
        print("isAnimated: \(animated)")
        
        if state == .edit {
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
        stateSwitch.isOn = state == .edit ? false : true
    }
    
    func addGlowEffect(to view: UIView, isAnimated animated: Bool) { // Give a label a transparent white shadow, simulating a glow
        let duration: TimeInterval = animated ? animationDuration : 0.0
        print("GlowLabelDuration: \(duration)")
        
        view.layer.shadowColor = UIColor.white.cgColor
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = shadowRadius
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.scale
        
        let opacityAnimation = CABasicAnimation(keyPath: "shadowOpacity")
        opacityAnimation.fromValue = view.layer.shadowOpacity
        opacityAnimation.toValue = 0.95
        opacityAnimation.duration = duration
        opacityAnimation.fillMode = kCAFillModeForwards
        opacityAnimation.isRemovedOnCompletion = false
        view.layer.add(opacityAnimation, forKey: "opacityAnimationGlow")
        
        if let label = view as? UILabel {
            label.textColor = .white
        }
    }
    
    func giveFadeAnimation(toLabel label: UILabel) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.type = kCATransitionFade
        animation.duration = animationDuration
        animation.delegate = self
        label.layer.add(animation, forKey: "kCATransitionFade")
    }
    
    func removeGlowEffect(from view: UIView, isAnimated animated: Bool) { // Make the shadow completely transparent
        let duration: TimeInterval = animated ? animationDuration : 0.0
        print("GlowLabelDuration: \(duration)")
        
        view.layer.shadowColor = UIColor.white.cgColor
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = shadowRadius
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.scale
        
        let opacityAnimation = CABasicAnimation(keyPath: "shadowOpacity")
        print("Opacity: \(view.layer.shadowOpacity)")
        opacityAnimation.fromValue = view.layer.shadowOpacity
        opacityAnimation.toValue = 0.0
        opacityAnimation.duration = duration
        opacityAnimation.fillMode = kCAFillModeForwards
        opacityAnimation.isRemovedOnCompletion = false
        view.layer.add(opacityAnimation, forKey: "opacityAnimationFade")
        
        if let label = view as? UILabel {
            if label == editLabel { label.textColor = EditMode.edit.textColor }
            else if label == redactLabel { label.textColor = EditMode.redact.textColor }
        }
    }
}

