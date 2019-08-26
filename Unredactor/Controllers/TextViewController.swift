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
}


// MARK: - Class Definition
/**
 TextViewController manages a text view. It uses a document object to know what text to display and how
 to display it, and modifies that document object. It also gives the text view added behavior such as placeholder
 text and the ability to be redacted. It interfaces with ScrollDocumentViewController through a delegate.
*/
class TextViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak private var textView: UITextView!
    
    var document: Document!
    var editMode: EditMode = .editable
    
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
    
    func switchState(to state: RedactionState, completion: @escaping () -> Void = { }) {
        switch state {
        case .notRedacted:
            print("something")
            completion()
        case .redacted:
            document.unredact(completion: {
                DispatchQueue.main.async { [unowned self] in
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
        self.document = document
        textView.font = document.font

        guard textView.textColor != UIColor.lightGray else { return }
        textView.attributedText = document.attributedText
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
            document.appendCharacterToText(text)
            textView.attributedText = document.attributedText
            textView.font = document.font
            delegate?.textViewDidBecomeNotEmpty()
        } else {
            let textWasDeleted = updatedText.count < textView.text.count
            if textWasDeleted {
                document.removeLastCharacter()
                textView.attributedText = document.attributedText
                textView.font = document.font
            } else {
                document.appendCharacterToText(text)
                textView.attributedText = document.attributedText
                textView.font = document.font
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
        guard editMode == .redactable else {
            // EditMode must be edit, so let's start editing
            textView.becomeFirstResponder()
            
            return
        }
        
        let characterIndexTapped = gestureRecognizer.characterIndexTapped(inDocument: document)
        
        if editMode == .redactable {
            for word in document.classifiedText.words {
                print("Before: Word: \(word), State: \(word.redactionState)")
            }
            
            // Make the tapped word toggle between redacted and unredacted
            document.classifiedText.wordForCharacterIndex(characterIndexTapped)?.toggleRedactionState()
            
            for word in document.classifiedText.words {
                print("After: Word: \(word), State: \(word.redactionState)")
            }
        
            textView.attributedText = document.attributedText
            textView.font = document.font
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
    
    func setupTextView() {
        setTextView(toEditMode: editMode)
    }
}

