//
//  TextViewController.swift
//  Unredactor
//
//  Created by Tyler Gee on 8/7/19.
//  Copyright © 2019 tyler. All rights reserved.
//

import UIKit


protocol TextViewControllerDelegate {
    func keyboardWillShow(_ notification: NSNotification)
    func keyboardWillHide(_ notification: NSNotification)
    
    func textViewDidBecomeEmpty()
    func textViewDidBecomeNotEmpty()
    
    func documentStateSwitched(to state: RedactionState)
}



// Handles the text view, including the placeholder text, editableness, redaction of keyboard, etc., and interfaces with the ScrollDocumentVC through a delegate. Effectively displays and edits a document.

class TextViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    fileprivate let placeholderText = "Enter redacted text here..."
    
    var delegate: TextViewControllerDelegate?
    var document: Document!
    
    var editMode: EditMode = .edit

    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardDidShow, object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: self.view.window)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        removeObservers()
    }
    
    // This function is MEANT to be used by the superior controller
    func switchState(to state: RedactionState, completion: @escaping () -> Void = { }) {
        switch state {
        case .notRedacted:
            print("something")
            completion()
        case .redacted:
            document.unredact(completion: {
                DispatchQueue.main.async {
                    self.textView.attributedText = self.document.attributedText
                    completion()
                }
            })
        case .unredacted:
            for word in document.classifiedText.words {
                if word.redactionState != .notRedacted {
                    word.redactionState = word.lastRedactionState ?? .notRedacted
                }
            }
            
            textView.attributedText = document.attributedText
            
            completion()
        }
    }
    
    func setTextViewEditable() {
        textView.isEditable = true
        editMode = .edit
    }
    
    func setTextViewRedactable() {
        textView.isEditable = false
        editMode = .redact
    }
    
    deinit {
        removeObservers()
    }
}

extension TextViewController: UITextViewDelegate {
    func textViewDidEndEditing() {
        textView.resignFirstResponder()
        
        self.document.setText(to: textView.text)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let text: String = textView.text
        
        if text.isEmpty {
            delegate?.textViewDidBecomeEmpty()
        } else {
            delegate?.textViewDidBecomeNotEmpty()
        }
    }
    
    // From: https://stackoverflow.com/questions/27652227/text-view-uitextview-placeholder-swift
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Combine the textView text and the replacement text to
        // Create the updated text tring
        let currentText: String = textView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
        
        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        if updatedText.isEmpty {
            selectBeginningOfTextView()
        }
            
            // Else if the text view's placeholder is showing
            // and the length of the replacement string is greater than 0,
            // set the text color to black and then set its text to the replacement string
        else if textView.textColor == .lightGray && !text.isEmpty {
            textView.textColor = .black
            textView.text = text
        }
            
            // For every other case, the text should change with the usual
            // behavior...
        else {
            return true
        }
        
        // ...otherwise return false since the updates have
        // already been made
        return false
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == .lightGray {
                selectBeginningOfTextView()
            }
        }
    }
}

extension TextViewController: UIGestureRecognizerDelegate {
    @objc func textViewTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        guard editMode == .redact else { return }
        
        let characterIndexTapped = gestureRecognizer.characterIndexTapped()
        
        let previousDocumentState: RedactionState = document.state
        
        // Make the tapped word toggle between redacted and unredacted
        document.classifiedText.wordForCharacterIndex(characterIndexTapped)?.toggleRedactionState()
        
        textView.attributedText = document.attributedText
        
        if document.state != previousDocumentState { // If document state changed
            delegate?.documentStateSwitched(to: document.state)
        }
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        delegate?.keyboardWillShow(notification)
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        delegate?.keyboardWillHide(notification)
    }
}

// MARK: - Helper methods
// (that you don't need to know about)
fileprivate extension TextViewController {
    func configureTextView(withDocument document: Document) {
        textView.attributedText = document.attributedText
        
        selectBeginningOfTextView()
        textView.becomeFirstResponder()
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
    
    func setupTapGestureRecognizer() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TextViewController.textViewTapped(_:)))
        gestureRecognizer.delegate = self
        textView.addGestureRecognizer(gestureRecognizer)
    }
    
    func selectBeginningOfTextView() { // Make it select the very start of the text view, "ignoring" the placeholder text
        textView.text = placeholderText
        textView.textColor = .lightGray
        textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
    }
}

enum EditMode { // Can be either edit or redact
    case edit, redact
    
    var textColor: UIColor {
        switch self {
        case .edit:
            return UIColor(white: 0.54, alpha: 0.9)
        case .redact:
            return UIColor(white: 0.69, alpha: 0.9)
        }
    }
    
    func toggled() -> EditMode {
        if self == .edit {
            return .redact
        } else {
            return .edit
        }
    }
}

