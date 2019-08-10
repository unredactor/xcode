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
    
    private var animationDuration: TimeInterval = 2.0
    var delegate: SwitchViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //updateSwitchDirection()
        //updateViews(isAnimated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Do any additional setup after loading the view.
        
        updateSwitchDirection()
        updateViews(isAnimated: false)
    }
    
    /*
    func enableSwitch() {
        stateSwitch.isEnabled = true
    }
    
    func disableSwitch() {
        stateSwitch.isEnabled = false
    }
 */
    
    @IBAction func editButtonPressed(_ sender: Any) {
        state = .edit
        updateSwitchDirection()
        updateViews(isAnimated: true)
        delegate?.switchWasToggled(to: .edit)
    }
    
    @IBAction func redactButtonPressed(_ sender: Any) {
        state = .redact
        updateSwitchDirection()
        updateViews(isAnimated: true)
        delegate?.switchWasToggled(to: .edit)
    }
    
    private func updateViews(isAnimated animated: Bool) { // Changes the appearance of the views to reflect
        if state == .edit {
            //stateSwitch.isOn = false
            removeGlowEffect(from: stateSwitch, isAnimated: animated)
            giveGlowEffect(to: editLabel, isAnimated: animated)
            removeGlowEffect(from: redactLabel, isAnimated: animated)
        } else {
            //stateSwitch.isOn = true
            giveGlowEffect(to: stateSwitch, isAnimated: animated)
            giveGlowEffect(to: redactLabel, isAnimated: animated)
            removeGlowEffect(from: editLabel, isAnimated: animated)
        }
    }
    
    private func updateSwitchDirection() { // Change the direction of the switch according to the state
        stateSwitch.isOn = state == .edit ? false : true
    }
    
    private func giveGlowEffect(to view: UIView, isAnimated animated: Bool) { // Give a label a transparent white shadow, simulating a glow
        let duration: TimeInterval = animated ? animationDuration : 0.0
        print("GlowLabelDuration: \(duration)")
        
        /*
        UIView.animate(withDuration: duration) {
            label.textColor = .white
            self.giveGlowEffect(to: label)
        }
 */
        UIView.transition(with: view, duration: duration, options: .transitionCrossDissolve, animations: {
            if let label = view as? UILabel {
                label.textColor = .white
            }
            self.giveGlowEffect(to: view)
        }, completion: nil)
    }
    
    private func giveGlowEffect(to view: UIView) {
        view.layer.shadowColor = UIColor.white.cgColor
        view.layer.shadowOpacity = 0.9
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 8
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.scale
    }
    
    private func removeGlowEffect(from view: UIView, isAnimated animated: Bool) { // Make the shadow completely transparent
        let duration: TimeInterval = animated ? animationDuration : 0.0
        print("GlowLabelDuration: \(duration)")
        
        UIView.transition(with: view, duration: duration, options: .transitionCrossDissolve, animations: {
            if let label = view as? UILabel {
                if label == self.editLabel {
                    label.textColor = EditMode.edit.textColor
                } else {
                    label.textColor = EditMode.redact.textColor
                }
            }
            
            self.removeGlowEffect(from: view)
        }, completion: nil)
    }
    
    private func removeGlowEffect(from view: UIView) {
        view.layer.shadowColor = UIColor.clear.cgColor
        view.layer.shadowOpacity = 0
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 0
    }
    
    @IBAction func toggleSwitch(_ sender: UISwitch) {
        state = state.toggled()
        updateViews(isAnimated: true)
        
        delegate?.switchWasToggled(to: state)
    }
}

