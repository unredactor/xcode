//
//  TextViewController.swift
//  Unredactor
//
//  Created by Tyler Gee on 8/7/19.
//  Copyright © 2019 tyler. All rights reserved.
//

import UIKit


protocol TextViewControllerDelegate {
    func keyboardDidShow(_ notification: NSNotification)
    func keyboardWillHide(_ notification: NSNotification)
    
    func textViewDidBecomeEmpty()
    func textViewDidBecomeNotEmpty()
    
    func documentStateSwitched(to state: RedactionState)
}



// Handles the text view, including the placeholder text, editableness, redaction of keyboard, etc., and interfaces with the ScrollDocumentVC through a delegate. Effectively displays and edits a document.

class TextViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    fileprivate let placeholderText = "Enter text here..."
    
    var delegate: TextViewControllerDelegate?
    var document: Document!
    
    var editMode: EditMode = .edit

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTextView(withDocument: document)
        
        if textView.text.isEmpty {
            setTextToPlaceholderText()
        }
        
        textView.delegate = self
        
        addObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupTapGestureRecognizer()
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
    
    func configureTextView(withDocument document: Document) {
        textView.attributedText = document.attributedText
        textView.font = document.font
    }
    
    func setTextView(toEditMode editMode: EditMode) {
        switch editMode {
        case .edit:
            print("TextView text: \(textView.text)")
            if textView.textColor == .lightGray {
                selectBeginningOfTextView()
            } else if textView.text.isEmpty || textView.text == nil {
                setTextToPlaceholderText()
                selectBeginningOfTextView()
            } else {
                selectEndOfTextView()
            }
            setTextViewEditable()
        case .redact:
            setTextViewRedactable()
            textView.resignFirstResponder()
        }
    }
    
    func setTextViewEditable() {
        print("Text view set to be editable")
        textView.isEditable = true
        editMode = .edit
        textView.becomeFirstResponder()
        print(textView.text)
    }
    
    func setTextViewRedactable() {
        print("Text view set to be redactable")
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
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        textView.resignFirstResponder()
    }
    
    /*
    func textViewDidChange(_ textView: UITextView) {
        let text: String = textView.attributedText.string
        
        if text.isEmpty {
            delegate?.textViewDidBecomeEmpty()
        } else {
            delegate?.textViewDidBecomeNotEmpty()
        }
    }
 */
    
    
    // From: https://stackoverflow.com/questions/27652227/text-view-uitextview-placeholder-swift
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Combine the textView text and the replacement text to
        // Create the updated text string
        
        
        
        var currentText: String = ""
        
        if textView.text.isEmpty {
            currentText = textView.attributedText.string
        } else {
            currentText = textView.text
        }
        
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
        
        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        
        
        if updatedText.isEmpty {
            setTextToPlaceholderText()
            selectBeginningOfTextView()
            document.setText(to: "")
            delegate?.textViewDidBecomeEmpty()
        }
            
            // Else if the text view's placeholder is showing
            // and the length of the replacement string is greater than 0,
            // set the text color to black and then set its text to the replacement string
        else if textView.textColor == .lightGray && !text.isEmpty {
            textView.textColor = .black
            print("Replacement Text: \(text)")
            document.setText(to: text)
            textView.attributedText = document.attributedText
            textView.font = document.font
            delegate?.textViewDidBecomeNotEmpty()
        } else {
            document.setText(to: updatedText)
            
            return true
            //print(textView.font)
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
        guard editMode == .redact else {
            // EditMode must be edit, so let's start editing
            textView.becomeFirstResponder()
            
            return
        }
        
        //print("\(document.classifiedText.rawText)")
        
        let characterIndexTapped = gestureRecognizer.characterIndexTapped(inDocument: document)
        
        if editMode == .redact {
            let previousDocumentState: RedactionState = document.state
        
            // Make the tapped word toggle between redacted and unredacted
            document.classifiedText.wordForCharacterIndex(characterIndexTapped)?.toggleRedactionState()
            print("\(document.classifiedText.rawText)")
        
            textView.attributedText = document.attributedText
            textView.font = document.font
        
            if document.state != previousDocumentState { // If document state changed
                delegate?.documentStateSwitched(to: document.state)
            }
        } else if editMode == .edit {
            textView.becomeFirstResponder()
            
            let selectedPosition = textView.position(from: textView.beginningOfDocument, offset: characterIndexTapped) ?? textView.endOfDocument
            textView.selectedTextRange = textView.textRange(from: selectedPosition, to: selectedPosition)
        }
    }
    
    @objc func keyboardDidShow(_ notification: NSNotification) {
        delegate?.keyboardDidShow(notification)
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        delegate?.keyboardWillHide(notification)
    }
}

// MARK: - Helper methods
// (that you don't need to know about)
fileprivate extension TextViewController {
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(_:)), name: .UIKeyboardDidShow, object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: self.view.window)
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
    
    func setTextToPlaceholderText() {
        textView.text = placeholderText
        textView.textColor = .lightGray
        textView.backgroundColor = .clear
    }
    
    func selectBeginningOfTextView() { // Make it select the very start of the text view, "ignoring" the placeholder text
        textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
    }
    
    func selectEndOfTextView() {
        textView.selectedTextRange = textView.textRange(from: textView.endOfDocument, to: textView.endOfDocument)
    }
    
    func setupTextView() {
        setTextView(toEditMode: editMode)
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

