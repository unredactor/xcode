//
//  TextViewController.swift
//  Unredactor
//
//  Created by Tyler Gee on 8/7/19.
//  Copyright © 2019 tyler. All rights reserved.
//

import UIKit

// MARK: - Delegate
protocol TextViewControllerDelegate: class {
    func keyboardDidShow(_ notification: NSNotification)
    func keyboardWillHide(_ notification: NSNotification)
    
    func textViewDidBecomeEmpty()
    func textViewDidBecomeNotEmpty()
    func textViewDidBecomeRedacted()
    func textViewDidBecomeNotRedacted()
}


// MARK: - Class Definition
/**
 TextViewController manages a text view. It uses a document object to know what text to display and how
 to display it, and modifies that document object. It also gives the text view added behavior such as placeholder
 text and the ability to be redacted. It interfaces with ScrollDocumentViewController through a delegate.
*/
class TextViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak private var textView: UnredactorTextView!
    
    var document: Document!
    var editMode: EditMode = .editable
    private var isTypingSuggestion: Bool = false // This is to prevent multiple delegate calls when the user types one of the three suggestions provided above the iOS keyboard
    
    weak var delegate: TextViewControllerDelegate?
    
    fileprivate let placeholderText = "Enter text here..."
    
    // MARK: - View Life Cycle
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
    
    deinit {
        removeObservers()
    }
    
    // MARK: - Interface (public functions)
    func dismissKeyboard() {
        textView.resignFirstResponder()
    }
    
    func configureTextView(withDocument document: Document, isAnimated: Bool = false) {
        self.document = document
        textView.font = document.font
        
        guard textView.textColor != UIColor.lightGray else { return }
        
        if isAnimated {
            UIView.transition(with: textView, duration: 0.5, options: .transitionCrossDissolve, animations: { [unowned self] in
                self.textView.attributedText = self.document.attributedText
            })
        } else {
            textView.attributedText = document.attributedText
        }
    }
    
    func setTextView(toEditMode editMode: EditMode) {
        switch editMode {
        case .editable:
            if textView.textColor == .lightGray {
                selectBeginningOfTextView()
            } else if textView.text.isEmpty || textView.text == nil {
                setTextToPlaceholderText()
                selectBeginningOfTextView()
            } else {
                selectEndOfTextView()
            }
            setTextViewEditable()
        case .redactable:
            setTextViewRedactable()
            textView.resignFirstResponder()
        }
    }
    
    func updateTextViewEditMode() {
        if editMode == .editable { setTextViewEditable() }
        else { setTextViewRedactable() }
    }
    
    func setTextViewIsUserInteractionEnabled(to isUserInteractionEnabled: Bool) {
        textView.isUserInteractionEnabled = isUserInteractionEnabled
    }
    
    func setTextViewEditable() {
        textView.isEditable = true
        editMode = .editable
        textView.becomeFirstResponder()
    }
    
    func setTextViewRedactable() {
        textView.isEditable = false
        editMode = .redactable
    }
}

// MARK: - UITextViewDelegate
extension TextViewController: UITextViewDelegate {
    func textViewDidEndEditing() {
        textView.resignFirstResponder()
        
        document.setText(to: textView.text)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        textView.resignFirstResponder()
    }
    
    // From: https://stackoverflow.com/questions/27652227/text-view-uitextview-placeholder-swift
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Guarantee that this isn't an extra delegate call from typing a suggestion
        guard !isTypingSuggestion else { return false }
        
        print("Range: \(range)")

        // Combine the textView text and the replacement text to
        // Create the updated text string
        
        var currentText: String = ""
        let previousRedactionState = document.redactionState
        
        if textView.text.isEmpty {
            currentText = textView.attributedText.string
        } else {
            isTypingSuggestion = true
            currentText = textView.text
            isTypingSuggestion = false
        }
        
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
        
        let textWasDeleted = updatedText.count <= textView.text.count // they are equal in the case that you press backspace and there is no text yet
        
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
        else if textView.textColor == .lightGray {
            guard !textWasDeleted && !text.isEmpty else { return false }
            
            textView.textColor = .black
            document.changeText(inRange: range, replacementText: text)
            isTypingSuggestion = true
            textView.attributedText = document.attributedText
            isTypingSuggestion = false
            textView.font = document.font
            delegate?.textViewDidBecomeNotEmpty()
        } else {
            if textWasDeleted {
                
                let selectedIndex = document.removeCharacter(atIndex: range.location)
                isTypingSuggestion = true
                textView.attributedText = document.attributedText
                isTypingSuggestion = false
                textView.font = document.font
                
                if document.redactionState != .redacted && previousRedactionState == .redacted {
                    delegate?.textViewDidBecomeNotRedacted()
                }
                
                selectTextView(atIndex: selectedIndex)
            } else {
                let selectedIndex = document.changeText(inRange: range, replacementText: text)
                isTypingSuggestion = true
                textView.attributedText = document.attributedText
                isTypingSuggestion = false
                textView.font = document.font
                
                selectTextView(atIndex: selectedIndex)
            }
            
            return false
        }
        
        // ...otherwise return false since the updates have
        // already been made
        return false
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if view.window != nil && textView.textColor == .lightGray {
            selectBeginningOfTextView()
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension TextViewController: UIGestureRecognizerDelegate {
    @objc func textViewTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        
        let previousRedactionState = document.redactionState
        
        guard textView.isUserInteractionEnabled == true else { return }
        
        guard editMode == .redactable else {
            // EditMode must be edit, so let's start editing
            textView.becomeFirstResponder()
            
            return
        }
        
        guard let characterIndexTapped = gestureRecognizer.characterIndexTapped(inDocument: document) else { return }
        
        if editMode == .redactable {
            
            // Make the tapped word toggle between redacted and unredacted
            document.classifiedText.wordForCharacterIndex(characterIndexTapped)?.toggleRedactionState()
            
            UIView.transition(with: textView, duration: 0.15, options: .transitionCrossDissolve, animations: { [unowned self] in
                self.textView.attributedText = self.document.attributedText
            })
            
            // Notify delegate if there are changes
            if document.redactionState == .redacted && previousRedactionState != .redacted { delegate?.textViewDidBecomeRedacted() }
            else if document.redactionState != .redacted && previousRedactionState == .redacted { delegate?.textViewDidBecomeNotRedacted() }
        } else if editMode == .editable {
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

// MARK: - Helper Functions
fileprivate extension TextViewController {
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(_:)), name: UIResponder.keyboardDidShowNotification, object: view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: view.window)
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
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
    
    func selectTextView(atIndex index: Int) {
        guard let selectedPosition = textView.position(from: textView.beginningOfDocument, offset: index) else { return }
        textView.selectedTextRange = textView.textRange(from: selectedPosition, to: selectedPosition)
    }
    
    func setupTextView() {
        setTextView(toEditMode: editMode)
    }
}

