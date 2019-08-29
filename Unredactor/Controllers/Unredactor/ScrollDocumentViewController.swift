//
//  ScrollDocumentViewController.swift
//  Unredactor
//
//  Created by Tyler Gee on 8/5/19.
//  Copyright © 2019 tyler. All rights reserved.
//

import UIKit

// MARK: - Class Definition
/**
 ScrollDocumentViewController is a subclass of ScrollViewController that conforms to DocumentViewController. It adds a TextViewController, SwitchViewController, and UIRefreshControl to allow the user to edit, redact, and unredact a document.
*/
class ScrollDocumentViewController: ScrollViewController, DocumentViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak private var switchView: UIView!
    @IBOutlet weak private var textView: UIView!
    
    var switchViewController: SwitchViewController!
    var textViewController: TextViewController!
    
    var document: Document!
    
    var isTextViewInteractionEnabled = true {
        didSet {
            textViewController.setTextViewIsUserInteractionEnabled(to: isTextViewInteractionEnabled)
        }
    }
    
    // From https://stackoverflow.com/questions/10768659/leaving-inputaccessoryview-visible-after-keyboard-is-dismissed
    // Allows accessory view to be constantly visible
    override var canBecomeFirstResponder: Bool { return true }
    override var inputAccessoryView: UIView? {
        switchViewController.removeFromParent()
        if !textView.isFirstResponder {
            // ??? Should I do this ???
            return switchView
        } else {
            return nil
        }
        
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSwitchView() // also add a shadow to the switch view and dismiss the switch view
        setupTextView() // align text view behavior with switch behavior
        setupRefreshView() // create and add a refresh view to the hierarchy that allows the user to unredact
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTextViewEditable()
    }
    
    // MARK: - Interface (public functinos)
    func dismissKeyboard() {
        textViewController.dismissKeyboard()
        self.resignFirstResponder()
    }
    
    // MARK: - Navigation
    // Nice technique for using switch let statements from https://medium.com/@superpeteblaze/ios-swift-tip-getting-references-to-container-child-view-controllers-653fe58e6f5e
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let switchViewController as SwitchViewController:
            switchViewController.delegate = self
            self.switchViewController = switchViewController
            switchViewController.removeFromParent()
        case let textViewController as TextViewController:
            textViewController.delegate = self
            self.textViewController = textViewController
            self.textViewController.document = self.document
        default:
            break
        }
    }
}

// MARK: - SwitchViewControllerDelegate
extension ScrollDocumentViewController: SwitchViewControllerDelegate {
    func switchWasToggled(to state: EditMode) {
        switch state {
        case .editable:
            setTextViewEditable()
        case .redactable:
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

// MARK: - TextViewControllerDelegate
extension ScrollDocumentViewController: TextViewControllerDelegate {
    func keyboardDidShow(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        
        // get the size of the keboard
        let keyboardRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        let keyboardSize = keyboardRect.size
        
        // Scroll the scrollView so the selected content is visible
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    func keyboardWillHide(_ notification: NSNotification) {
        // Scroll back to what it was previously
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    func textViewDidBecomeEmpty() {
        dismissSwitchView()
    }
    
    func textViewDidBecomeNotEmpty() {
        showSwitchView()
    }
}

// MARK: - Helper Functions
fileprivate extension ScrollDocumentViewController {
    
    func setupSwitchView() {
        addShadow(to: switchView)
        switchViewController.viewWillAppear(true)
    }
    
    func setupTextView() {
        textViewController.setTextView(toEditMode: switchViewController.state)
        
        // Make switch view stuck to the top of the text view's keyboard
        if let textView = textView.subviews.first?.subviews.first as? UITextView {
            dismissSwitchView(isAnimated: false)
            
            switchView.removeFromSuperview()
            textView.inputAccessoryView = switchView
        } else {
            print("ERROR: Failed to find textView in view hierarchy. Look at ScrollDocumentViewController.viewWillAppear(_:) to fix the access route.")
        } // TODO: some sort of test for this cause this is gonna break if I change anything about textViewController in code or storyboard
        // Make switch view stick to top of keyboard
    }
    
    func setupRefreshView() {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        
        if #available(iOS 10.0, *) {
            scrollView.refreshControl = refreshControl
        } else {
            scrollView.addSubview(refreshControl)
        }
        
        refreshControl.addTarget(self, action: #selector(unredact(_:)), for: .valueChanged)
    }
    
    @objc func unredact(_ sender: Any) {
        document.unredact {
            DispatchQueue.main.async { [unowned self] in
                self.textViewController.configureTextView(withDocument: self.document)
                self.scrollView.refreshControl?.endRefreshing()
            }
        }
    }
    
    private func dismissSwitchView(isAnimated: Bool = true) {
        let duration = isAnimated ? 0.3 : 0.0
        
        let downTransform: CGAffineTransform = CGAffineTransform(translationX: 0, y: switchView.frame.height)
        
        // Animate switch view down (back to normal position)
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseInOut, animations: { [unowned self] in
            self.switchView.transform = downTransform
            }, completion: { (bool) in
        })
    }
    
    private func showSwitchView(isAnimated: Bool = true) {
        let duration = isAnimated ? 0.3 : 0.0
        
        let identityTransform: CGAffineTransform = .identity
        
        // Animate switch view up
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseInOut, animations: { [unowned self] in
            self.switchView.transform = identityTransform
            }, completion: { (bool) in
        })
    }
}