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
    /// A label to indicate to the user how to unredact text. Shows up once the user is able to unredact (when there is redacted text)
    
    @IBOutlet weak var unredactButton: UIView!
    
    private var switchViewController: SwitchViewController!
    private var textViewController: TextViewController!
    private var loadingButtonViewController: LoadingButtonViewController!
    private var instructionLabelViewController: InstructionLabelViewController!
    
    var document: Document!
    
    var isTextViewInteractionEnabled = true {
        didSet {
            textViewController.setTextViewIsUserInteractionEnabled(to: isTextViewInteractionEnabled)
        }
    }
    
    /*
    private let pulseAnimationKey: String = "pulseAnimation"
    private var pulseAnimation: CABasicAnimation {
        let pulseAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        pulseAnimation.duration = 0.8
        pulseAnimation.fromValue = unredactLabel.alpha
        pulseAnimation.toValue = 0.0
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .greatestFiniteMagnitude
        
        return pulseAnimation
    }
 */
    
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
    
    override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSwitchView() // also add a shadow to the switch view and dismiss the switch view
        setupTextView() // align text view behavior with switch behavior
        //setupRefreshView() // create and add a refresh view to the hierarchy that allows the user to unredact
        
        loadingButtonViewController.disable()
        instructionLabelViewController.setInstructionText(to: "Tap icon to unredact ➡️")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTextView(toEditMode: .editable)
    }
    
    // MARK: - Interface (public functinos)
    func dismissKeyboard() {
        textViewController.dismissKeyboard()
        self.resignFirstResponder()
    }
    
    func fadeUnredactButton(toAlpha alpha: CGFloat, duration: TimeInterval) {
        loadingButtonViewController.animateAlpha(to: alpha, duration: duration)
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
        case let loadingButtonViewController as LoadingButtonViewController:
            loadingButtonViewController.delegate = self
            self.loadingButtonViewController = loadingButtonViewController
        case let instructionLabelViewController as InstructionLabelViewController:
            self.instructionLabelViewController = instructionLabelViewController
        default:
            break
        }
    }
}

// MARK: - SwitchViewControllerDelegate
extension ScrollDocumentViewController: SwitchViewControllerDelegate {
    func switchWasToggled(to editMode: EditMode) {
        setTextView(toEditMode: editMode)
    }
    
    func clearText() {
        /*
        let alert = UIAlertController(title: "Are you sure you want to clear all of the text you've typed?", message: "This action is unreversable.", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Delete Text", style: .destructive, handler: { [unowned self] action in
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true)
 */
        setSubviews(toEditMode: .editable)
        self.textViewController.clearText()
    }
    
    func undo() { // Reset text to latest thing
        self.textViewController.undo() // Can only be called after clearText was just called
    }
    
    func setSubviews(toEditMode editMode: EditMode) {
        setTextView(toEditMode: editMode)
        setSwitchView(toEditMode: editMode)
    }
    
    func setTextView(toEditMode editMode: EditMode) {
        textViewController.setTextView(toEditMode: editMode)
        //switchViewController.setSwitch(to: editMode)
    }
    
    func updateTextViewEditMode() {
        textViewController.setTextView(toEditMode: textViewController.editMode)
    }
    
    func setSwitchView(toEditMode editMode: EditMode) {
        switchViewController.setSwitch(to: editMode)
    }
}

// MARK: - TextViewControllerDelegate
extension ScrollDocumentViewController: TextViewControllerDelegate {
    
    func keyboardDidShow(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        
        // get the size of the keboard
        let keyboardRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        let keyboardSize = keyboardRect.size
        print("KEYBOARD SIZE: \(keyboardRect.size)")
        
        // Scroll the scrollView so the selected content is visible
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        if keyboardSize.height > 120 { scrollView.contentInset = contentInsets }
        print("CONTENT INSETS: \(contentInsets)")
        //scrollView.scrollIndicatorInsets = contentInsets
    }
    
    func keyboardWillHide(_ notification: NSNotification) {
        // Scroll back to what it was previously
        scrollView.contentInset = .zero
        print("CONTENT INSETS: \(scrollView.contentInset)")
        //scrollView.scrollIndicatorInsets = .zero
    }
    
    func textViewDidBecomeEmpty() {
        dismissSwitchView()
        loadingButtonViewController.disable()
        hideUnredactLabel()
        switchViewController.hideInstructionLabel()
    }
    
    func textViewDidBecomeNotEmpty() {
        showSwitchView()
        switchViewController.showInstructionLabel()
        switchViewController.resetClearTextButton()
    }
    
    func textViewDidBecomeRedacted() {
        showUnredactLabel()
        loadingButtonViewController.enable()
        switchViewController.hideInstructionLabel()
    }
    
    func textViewDidBecomeNotRedacted() {
        hideUnredactLabel()
        loadingButtonViewController.disable()
    }
}

// MARK: - ButtonViewControllerDelegate
extension ScrollDocumentViewController: ButtonViewControllerDelegate {
    func pressed(sender: ButtonViewController) {
        guard let loadingButtonViewController = sender as? LoadingButtonViewController else { return }
        
        loadingButtonViewController.actionBegan()
        
        document.unredact { (errorMessage) in
            DispatchQueue.main.async { [unowned self] in
                self.textViewController.configureTextView(withDocument: self.document, selectedIndex: nil, isAnimated: true)
                loadingButtonViewController.actionFinished()
                self.hideUnredactLabel()
                self.setSubviews(toEditMode: .editable)
                
                if let errorMessage = errorMessage {
                    self.showErrorMessage(errorMessage)
                }
            }
        }
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
        // THIS CODE SNIPPET MAY BE REPETITIVE - in refactoring, look into putting this in a function
        
        document.unredact { (errorMessage) in
            DispatchQueue.main.async { [unowned self] in
                self.textViewController.configureTextView(withDocument: self.document, selectedIndex: nil, isAnimated: true)
                self.scrollView.refreshControl?.endRefreshing()
                self.hideUnredactLabel()
                self.setSubviews(toEditMode: .editable)
                
                if let errorMessage = errorMessage {
                    self.showErrorMessage(errorMessage)
                }
            }
        }
    }
    
    func dismissSwitchView(isAnimated: Bool = true) {
        let duration = isAnimated ? 0.3 : 0.0
        
        let downTransform: CGAffineTransform = CGAffineTransform(translationX: 0, y: switchView.frame.height)
        
        // Animate switch view down (back to normal position)
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseInOut, animations: { [unowned self] in
            self.switchView.transform = downTransform
            }, completion: { (bool) in
        })
    }
    
    func showSwitchView(isAnimated: Bool = true) {
        let duration = isAnimated ? 0.3 : 0.0
        
        let identityTransform: CGAffineTransform = .identity
        
        // Animate switch view up
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseInOut, animations: { [unowned self] in
            self.switchView.transform = identityTransform
            }, completion: { (bool) in
        })
    }
    
    func showUnredactLabel() {
        instructionLabelViewController.show()
    }
    
    func hideUnredactLabel() {
        instructionLabelViewController.hide()
    }
    
    func showErrorMessage(_ errorMessage: String) {
        let alert = UIAlertController(title: "Oops! Something went wrong. 😕", message: errorMessage, preferredStyle: .alert)
        
        self.present(alert, animated: true)
    }
}
