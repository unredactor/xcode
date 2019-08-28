//
//  Text.swift
//  Unredactor
//
//  Created by tyler on 7/17/19.
//  Copyright © 2019 tyler. All rights reserved.
//

import Foundation
import UIKit

class Document {
    
    // MARK: - Properties
    var classifiedText: ClassifiedText // Base text that was entered is accessible through classifiedText.rawText
    //var redactedText: String? // Text where redacted words are replaced with unk. This is likely what would be sent to the API
    
    var font = UIFont(name: "Courier", size: 17)!
    
    var attributedText: NSAttributedString { // Text that is used by the DocumentCell to display black bars. Needs to remember the length of redacted words (so it looks nicer)
        
        let attributedText: NSMutableAttributedString = NSMutableAttributedString(string: "")//, attributes: attributes)
        let attributedSpace = NSMutableAttributedString(string: " ")
        
        //attributedText.addAttributes([.font: font], range: NSMakeRange(0, attributedText.string.count)) // Sets the font of the attributed text
        //attributedText.addAttribute(.font, value: font, range: NSMakeRange(0, attributedText.string.count))
        
        for word in classifiedText.words {
            let string = word.redactionState == .unredacted ? word.unredactorPrediction! : word.string
            let attributedWord = NSMutableAttributedString(string: string)
            if word.redactionState == .redacted {
                attributedWord.addAttribute(.backgroundColor, value: UIColor.black, range: NSRange(location: 0, length: word.string.count))
                attributedWord.addAttribute(.backgroundColor, value: UIColor.black, range: NSRange(location: 0, length: word.string.count))
            } else if word.redactionState == .unredacted {
                attributedWord.addAttribute(.backgroundColor, value: UIColor.black, range: NSRange(location: 0, length: word.unredactorPrediction!.count))
                attributedWord.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: word.unredactorPrediction!.count))
            }
            
            if string != " " { attributedText.append(attributedSpace) } // If the string is " ", this means the user typed a space. This is used to separate words of different redaction states when typing. If the space was added, this would produce two spaces when the user typed only one. There should only be one " " word if any, and it should be at the end of the sentence.
            attributedText.append(attributedWord)
        }
        
        attributedText.addAttribute(.font, value: font, range: NSMakeRange(0, attributedText.string.count))
        
        // Since a space is added before every word, we need to get rid of the initial space
        if !attributedText.string.isEmpty {
            attributedText.deleteCharacters(in: NSRange(location: 0, length: 1))
        }
    
        
        return attributedText
    }
    
    /// Sets the text of the document. Will cause the document to forget the redaction state of words. Do not use if you are modifying the text from a similar state (eg. in a text input view)
    func setText(to text: String) {
        self.classifiedText.words = ClassifiedText.classifiedWordsFromText(text)
    }
    
    /// Appends a character to the last word in a text. If the character is a space, adds an empty word with text "" and redaciotn state .notRedacted.
    func appendCharacterToText(_ character: String) {
        if character == " " {
            classifiedText.words.append(ClassifiedString(" "))
        } else if let lastWord = classifiedText.words.last {
            if lastWord.string == " " {
                lastWord.string = character
            } else {
                lastWord.string.append(character)
            }
        } else {
            classifiedText.words.append(ClassifiedString(character)) // Create the first word
        }
    }
    
    func removeLastCharacter() {
        guard let lastWord = classifiedText.words.last else { return }
        
        let string: String = (lastWord.redactionState == RedactionState.unredacted) ? lastWord.unredactorPrediction! : lastWord.string
        
        if string.count > 1 {
            if lastWord.redactionState == RedactionState.unredacted { lastWord.unredactorPrediction?.removeLast() }
            else { lastWord.string.removeLast() }
        } else {
            classifiedText.words.removeLast()
            if lastWord.string != " " { classifiedText.words.append(ClassifiedString(" ")) }
        }
    }
    
    // Just making basic boolean more accesible without having to dig through properties
    var isNotRedacted: Bool { return classifiedText.isNotRedacted }
    var isRedacted: Bool { return classifiedText.isRedacted }
    var isUnredacted: Bool { return classifiedText.isUnredacted }
    
     // This might be the text turned into a sequence of classified strings
    // TODO: Make sure that classifiedText is updated every time text is updated
    
    var state: RedactionState { 
        if isNotRedacted { return .notRedacted }
        else if isRedacted { return .redacted }
        else { return .unredacted }
    }
    
    
    
    let unredactor: Unredactor
    
    
    // MARK: - Functions
    
    // Set the current text to be unredacted based on the model
    func unredact(completion: @escaping () -> ()) {
        guard classifiedText.isRedacted else {
            print("Text not redacted, so unredact() did nothing")
            completion()
            return
        }
        
        print("unredact() called")
        
        unredactor.unredact(classifiedText, completion: { [unowned self] (unredactedText: ClassifiedText) -> Void in
            self.classifiedText = unredactedText
            completion()
        })
    }
    
    
    // MARK: - Init
    init(withText text: String, unredactor: Unredactor) {
        self.unredactor = unredactor
        classifiedText = ClassifiedText(withText: text)
    }
}




