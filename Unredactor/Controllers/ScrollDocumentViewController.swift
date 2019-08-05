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
    
    var keyboardIsShown = false // Make sure nothing weird happens
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: self.view.window)
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
        
        keyboardIsShown = false
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
