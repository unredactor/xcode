//
//  ScrollDocumentViewController.swift
//  Unredactor
//
//  Created by Tyler Gee on 8/5/19.
//  Copyright © 2019 tyler. All rights reserved.
//

import UIKit

class ScrollDocumentViewController: DocumentViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var switchView: UIView!
    
    var switchViewController: SwitchViewController!
    var keyboardIsShown = false // Make sure nothing weird happens
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardDidShow, object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: self.view.window)
        
        setupScrollView() // for now, just add a shadow to the document so it looks nice
        setupSwitchView() // also add a shadow to the switch view
    }
    
    private func setupScrollView() {
        guard let backgroundView = scrollView.subviews.first else {
            print("Setup scroll view unsuccessful; backgroundView not found in subviews as first view")
            return
        }
        
        // Add a drop shadow to it
        addShadow(to: backgroundView)
    }
    
    private func setupSwitchView() {
        addShadow(to: switchView)
    }
    
    private func addShadow(to view: UIView) {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 10
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.scale
    }
    
    private func dismissSwitchView() {
        guard switchView.center.y < self.view.frame.maxY else {
            print("Didn't dismiss switch view because view was already dismissed")
            return
        }
        
        // Animate switch view down (back to normal position)
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
            let centerMovedDown = CGPoint(x: self.switchView.center.x, y: self.switchView.center.y + self.switchView.frame.height)
            self.switchView.center = centerMovedDown
        }, completion: { (bool) in
            
        })
    }
    
    private func showSwitchView() {
        guard switchView.center.y > self.view.frame.maxY else {
            print("Didn't show switch view because view was already shown")
            return
        }
        
        // Animate switch view up
        //let moveUpTransform: CGAffineTransform = CGAffineTransform(translationX: 0, y: 60)
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
            self.switchView.topAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -1 * self.switchView.frame.height).isActive = true
        }, completion: { (bool) in
            
        })
    }
    
    
    // We can do this function and have it work because the parent class is a UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        let text: String = textView.text
        
        if text.isEmpty {
            dismissSwitchView()
        } else {
            showSwitchView()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) { // TODO: Abstract into two helper functions
        // Make sure the keyboard isn't shown first
        guard !keyboardIsShown, let userInfo = notification.userInfo else { return }
        
        // get the size of the keboard
        let keyboardRect = userInfo[UIKeyboardFrameEndUserInfoKey] as! CGRect
        let keyboardSize = keyboardRect.size
        
        // resize the scrollView
        var viewFrame: CGRect = self.scrollView.frame
        viewFrame.size.height -= keyboardSize.height // subtract the height of the keyboard (when the keyboard is shown, we have less space to display stuff)
        
        // Animate the change
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        self.scrollView.frame = viewFrame
        UIView.commitAnimations()
        
        // Scroll the scrollView so the selected content is visible
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        keyboardIsShown = true
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        // Make sure the keyboard is already shown
        guard keyboardIsShown, let userInfo = notification.userInfo else { return }
        
        // get the size of the keyboard
        let keyboardRect = userInfo[UIKeyboardFrameBeginUserInfoKey] as! CGRect
        let keyboardSize = keyboardRect.size
        
        // resize the scrollView
        var viewFrame: CGRect = self.scrollView.frame
        // Account for the height of the keyboard
        viewFrame.size.height += keyboardSize.height
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        self.scrollView.frame = viewFrame
        UIView.commitAnimations()
        
        // Scroll back to what it was previously
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
        
        keyboardIsShown = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "embedSwitchView" else { return }
        
        switchViewController = segue.destination as? SwitchViewController
        
        switchViewController.delegate = self
    }
}

extension ScrollDocumentViewController: SwitchViewControllerDelegate {
    func switchToggled(to state: UnredactorState) {
        switch state {
        case .edit:
            setTextViewEditable()
        case .redact:
            setTextViewRedactable()
        }
    }
    
    private func setTextViewEditable() {
        textView.isEditable = true
        
        // Turn off redaction detection
    }
    
    private func setTextViewRedactable() {
        textView.isEditable = false
        
        // Turn on redaction detection
    }
    
    //private func
    
    // func to make textView editable
    // func to make textView redactable
}
