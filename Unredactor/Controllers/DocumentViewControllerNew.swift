//
//  DocumentViewController.swift
//  Unredactor
//
//  Created by Tyler Gee on 8/2/19.
//  Copyright © 2019 tyler. All rights reserved.
//

import UIKit

class DocumentViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    fileprivate let placeholderText = "Enter redacted text here..."
    
    var document: Document = Document(withText: "", unredactor: Unredactor())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.delegate = self
        
        setupTextView() // Add placeholder
    }
    
    private func setupTextView() {
        selectBeginningOfTextView()
        
        textView.becomeFirstResponder()
    }
    
    fileprivate func selectBeginningOfTextView() { // Make it select the very start of the text view, "ignoring" the placeholder text
        textView.text = placeholderText
        textView.textColor = .lightGray
        textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
    }
}

extension DocumentViewController: UITextViewDelegate {
    
    func textViewShouldReturn(_ textField: UITextField) -> Bool {
        textViewDidEndEditing()
        
        return true
    }
    
    func textViewDidEndEditing() {
        textView.resignFirstResponder()
        
        self.document.setText(to: textView.text!)
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
