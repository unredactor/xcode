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
    
    // These are container views that connect to other view controllers, so they appear to be just plain old UIViews, although they aren't.
    @IBOutlet weak var switchView: UIView!
    @IBOutlet weak var textView: UIView!
    
    var switchViewController: SwitchViewController!
    var textViewController: TextViewController!
    
    var keyboardIsShown = false // Make sure nothing weird happens
    
    let unredactor = Unredactor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupScrollView() // for now, just add a shadow to the document so it looks nice.
        setupSwitchView() // also add a shadow to the switch view and dismiss the switch view
        
        setupTextView() // align text view behavior with switch behavior
        
        
        if let textView = textView.subviews.first?.subviews.first as? UITextView {
            dismissSwitchView(isAnimated: false)
            
            textView.inputAccessoryView = switchView
            switchView.removeFromSuperview()
        } else {
            print("ERROR: Failed to find textView in view hierarchy. Look at ScrollDocumentViewController.viewWillAppear(_:) to fix the access route.")
        } // TODO: some sort of test for this cause this is gonna break if I change anything about textViewController in code or storyboard
        // Make switch view stick to top of keyboard
        
        
        setupRefreshView() // create and add a refresh view to the hierarchy that allows the user to unredact
    }
    
    // From https://stackoverflow.com/questions/10768659/leaving-inputaccessoryview-visible-after-keyboard-is-dismissed
    // Allows accessory view to be constantly visible
    override var canBecomeFirstResponder: Bool { return true }
    override var inputAccessoryView: UIView? {
        switchViewController.removeFromParentViewController() // ??? Should I do this ???
        return switchView
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
        switchViewController.viewWillAppear(true)
        //switchViewController.viewWillAppear(true)
        //switchViewController.disableSwitch()
        //dismissSwitchView(isAnimated: false)
        //switchViewController.
        //switchViewCont
    }
    
    private func setupTextView() {
        print(switchViewController.state)
        textViewController.setTextView(toEditMode: switchViewController.state)
    }
    
    private func setupRefreshView() {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        
        if #available(iOS 10.0, *) {
            scrollView.refreshControl = refreshControl
        } else {
            scrollView.addSubview(refreshControl)
        }
        
        refreshControl.addTarget(self, action: #selector(unredact(_:)), for: .valueChanged)
    }
    
    @objc private func unredact(_ sender: Any) {
        document.unredact {
            DispatchQueue.main.async { [unowned self] in
                self.textViewController.configureTextView(withDocument: self.document)
                self.scrollView.refreshControl?.endRefreshing()
            }
        }
    }
    
    private func addShadow(to view: UIView) {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 10
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.scale
    }
    
    private func dismissSwitchView(isAnimated: Bool = true) {
        let duration = isAnimated ? 0.3 : 0.0
        
        let downTransform: CGAffineTransform = CGAffineTransform(translationX: 0, y: switchView.frame.height)
        
        
        // Animate switch view down (back to normal position)
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseInOut, animations: { [unowned self] in
            self.switchView.transform = downTransform
        }, completion: { (bool) in
            print("something")
        })
    }
    
    private func showSwitchView(isAnimated: Bool = true) {
        let duration = isAnimated ? 0.3 : 0.0

        let identityTransform: CGAffineTransform = .identity
        
        // Animate switch view up
        //let moveUpTransform: CGAffineTransform = CGAffineTransform(translationX: 0, y: 60)
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseInOut, animations: { [unowned self] in
            self.switchView.transform = identityTransform
        }, completion: { (bool) in
            print("something")
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        //NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        //NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        //NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
    
    // Nice technique for using switch let statements from https://medium.com/@superpeteblaze/ios-swift-tip-getting-references-to-container-child-view-controllers-653fe58e6f5e
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //guard segue.identifier == "embedSwitchView", let switchViewController = segue.destination as? SwitchViewController else { return }
        
        switch segue.destination {
        case let switchViewController as SwitchViewController:
            switchViewController.delegate = self
            self.switchViewController = switchViewController
        case let textViewController as TextViewController:
            textViewController.delegate = self
            self.textViewController = textViewController
            self.textViewController.document = self.document
        default:
            break
        }
        
        //switchViewController.delegate = self
    }
}

extension ScrollDocumentViewController: SwitchViewControllerDelegate {
    func switchWasToggled(to state: EditMode) {
        switch state {
        case .edit:
            setTextViewEditable()
        case .redact:
            setTextViewRedactable()
        }
    }
    
    private func setTextViewEditable() {
        textViewController.setTextViewEditable()
    }
    
    private func setTextViewRedactable() {
        textViewController.setTextViewRedactable()
    }
}

extension ScrollDocumentViewController: TextViewControllerDelegate {
    func keyboardDidShow(_ notification: NSNotification) {
        print("KEYBOARD WILL SHOW")
        //print("TextView text: \(textViewController.textView.text)")
        
        guard let userInfo = notification.userInfo else { return }
        
        // get the size of the keboard
        let keyboardRect = userInfo[UIKeyboardFrameEndUserInfoKey] as! CGRect
        let keyboardSize = keyboardRect.size
        print("Keyboard Size: \(keyboardRect.size)")
        
        // resize the scrollView
        var viewFrame: CGRect = self.view.frame
        
        print("ScrollView size: \(self.scrollView.frame)")
        
        viewFrame.size.height -= keyboardSize.height // subtract the height of the keyboard (when the keyboard is shown, we have less space to display stuff)
        
        // Account for switchView:
        
        
        // move the switchView
        //var switchViewFrame: CGRect = self.switchView.frame
        //switchViewFrame.origin.y -= keyboardSize.height
        
        // Animate the change
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        //self.scrollView.frame = viewFrame
        //self.switchView.frame = switchViewFrame
        UIView.commitAnimations()
        
        // Scroll the scrollView so the selected content is visible
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        keyboardIsShown = true
        print("ScrollView sizeAfter: \(self.scrollView.frame)")
    }
    
    func keyboardWillHide(_ notification: NSNotification) {
        print("KEYBOARD WILL HIDE")
        
        guard let userInfo = notification.userInfo else { return }
        
        // get the size of the keyboard
        let keyboardRect = userInfo[UIKeyboardFrameEndUserInfoKey] as! CGRect
        let keyboardSize = keyboardRect.size
        print("Keyboard Size: \(keyboardRect.size)")
        
        // resize the scrollView
        //var viewFrame: CGRect = self.scrollView.frame
        //print("ScrollView size: \(self.scrollView.frame)")
        // Account for the height of the keyboard
        //viewFrame.size.height += keyboardSize.height - switchView.frame.height
        
       // Move the switchview
        //var switchViewFrame: CGRect = self.switchView.frame
        //switchViewFrame.size.height += keyboardSize.height
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        //self.scrollView.frame = viewFrame
        //self.scrollView.frame = self.view.frame
        //self.switchView.frame = switchViewFrame
        UIView.commitAnimations()
        
        // Scroll back to what it was previously
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
        
        keyboardIsShown = false
        
        print("ScrollView sizeAfter: \(self.scrollView.frame)")
    }
    
    func textViewDidBecomeEmpty() {
        dismissSwitchView()
        //switchViewController.disableSwitch()
    }
    
    func textViewDidBecomeNotEmpty() {
        showSwitchView()
        //switchViewController.enableSwitch()
    }
    
    func documentStateSwitched(to state: RedactionState) {
        
    }
}
