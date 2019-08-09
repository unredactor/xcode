//
//  SwitchViewController.swift
//  Unredactor
//
//  Created by Tyler Gee on 8/6/19.
//  Copyright © 2019 tyler. All rights reserved.
//

import UIKit

protocol SwitchViewControllerDelegate {
    func switchWasToggled(to state: EditMode)
}

class SwitchViewController: UIViewController {
    
    var state: EditMode = .edit
    @IBOutlet weak var stateSwitch: UISwitch!
    
    @IBOutlet weak var editLabel: UILabel!
    @IBOutlet weak var redactLabel: UILabel!
    
    private var animationDuration: TimeInterval = 0.3
    var delegate: SwitchViewControllerDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Do any additional setup after loading the view.
        
        updateSwitchDirection()
        updateViews(animated: false)
    }
    
    private func updateViews(animated: Bool) { // Changes the appearance of the views to reflect
        if state == .edit {
            //stateSwitch.isOn = false
            removeGlowEffect(from: stateSwitch, animated: animated)
            giveGlowEffect(toLabel: editLabel, animated: animated)
            removeGlowEffect(fromLabel: redactLabel, animated: animated)
        } else {
            //stateSwitch.isOn = true
            giveGlowEffect(to: stateSwitch, animated: animated)
            giveGlowEffect(toLabel: redactLabel, animated: animated)
            removeGlowEffect(fromLabel: editLabel, animated: animated)
        }
    }
    
    private func updateSwitchDirection() { // Change the direction of the switch according to the state
        stateSwitch.isOn = state == .edit ? false : true
    }
    
    private func giveGlowEffect(toLabel label: UILabel, animated: Bool) { // Give a label a transparent white shadow, simulating a glow
        let duration: TimeInterval = animated ? animationDuration : 0.0
        
        /*
        UIView.animate(withDuration: duration) {
            label.textColor = .white
            self.giveGlowEffect(to: label)
        }
 */
        UIView.transition(with: label, duration: duration, options: .transitionCrossDissolve, animations: {
            label.textColor = .white
            self.giveGlowEffect(to: label, animated: false)
        }, completion: nil)
    }
    
    private func giveGlowEffect(to view: UIView, animated: Bool) {
        let duration: TimeInterval = animated ? animationDuration : 0.0
        
        UIView.transition(with: view, duration: duration, options: .transitionCrossDissolve, animations: {
            view.layer.shadowColor = UIColor.white.cgColor
            view.layer.shadowOpacity = 0.9
            view.layer.shadowOffset = .zero
            view.layer.shadowRadius = 8
            view.layer.shouldRasterize = true
            view.layer.rasterizationScale = UIScreen.main.scale
        }, completion: nil)
    }
    
    private func removeGlowEffect(fromLabel label: UILabel, animated: Bool) { // Make the shadow completely transparent
        let duration: TimeInterval = animated ? animationDuration : 0.0
        
        UIView.transition(with: label, duration: duration, options: .transitionCrossDissolve, animations: {
            if label == self.editLabel {
                label.textColor = EditMode.edit.textColor
            } else {
                label.textColor = EditMode.redact.textColor
            }
            self.removeGlowEffect(from: label, animated: false)
        }, completion: nil)
    }
    
    private func removeGlowEffect(from view: UIView, animated: Bool) {
        let duration: TimeInterval = animated ? animationDuration : 0.0
        
        UIView.transition(with: view, duration: duration, options: .transitionCrossDissolve, animations: {
            view.layer.shadowColor = UIColor.clear.cgColor
            view.layer.shadowOpacity = 0
            view.layer.shadowOffset = .zero
            view.layer.shadowRadius = 0
        }, completion: nil)
    }
    
    @IBAction func toggleSwitch(_ sender: UISwitch) {
        state = state.toggled()
        updateViews(animated: true)
        
        delegate?.switchWasToggled(to: state)
    }
}

