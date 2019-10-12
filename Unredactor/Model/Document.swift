//
//  Text.swift
//  Unredactor
//
//  Created by tyler on 7/17/19.
//  Copyright © 2019 tyler. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Class Definition
class Document {
    
    
    // MARK: - Properties
    var classifiedText: ClassifiedText // Base text that was entered is accessible through classifiedText.rawText
    var font = UIFont(name: "Courier", size: 22)!
    
    var attributedText: NSAttributedString { // Text that is used by the DocumentCell to dsiplay black bars.
        
        let attributedText: NSMutableAttributedString = NSMutableAttributedString(string : "")
        
        for (wordIndex, word) in classifiedText.words.enumerated() {
            let string = word.redactionState == .unredacted ? word.unredactorPrediction! : word.string
            let attributedWord = NSMutableAttributedString(string: string)
            
            //print("WORD: \(string), redactionState: \(word.redactionState)")
            if word.type == .word {
                setAttributedString(attributedWord, toState: word.redactionState)
            } else if word.type == .space {
                // Make it .redacted if both surrounding words are .redacted
                if wordIndex > 0 && wordIndex + 1 < classifiedText.words.count { // Make sure the previous and next words exist
                    let wordBefore = classifiedText.words[wordIndex - 1]
                    let wordAfter = classifiedText.words[wordIndex + 1]
                    
                    if wordBefore.redactionState == .redacted && wordAfter.redactionState == .redacted {
                        setAttributedString(attributedWord, toState: .redacted) // otherwise keep it .notRedacted
                    }
                    
                }
            }
            attributedText.append(attributedWord)
        }
        
        attributedText.addAttribute(.font, value: font, range: NSMakeRange(0, attributedText.string.count))
        
        return attributedText
    }
    
    // MARK: - Interface (public methods)
    /// Sets the text of the document. Will cause the document to forget the redaction state of words. Do not use if you are modifying the text from a similar state (eg. in a text input view)
    func setText(to text: String) {
        self.classifiedText.words = ClassifiedText.classifiedWordsFromText(text)
    }
    
    /// Appends a character to the last word in a text. If the character is a space, adds an empty word with text "" and redaciotn state .notRedacted.
    func appendCharacterToText(_ character: String) {
        // TODO: Optimize implementation - This guard statement is for diction, where an entire sentence or paragraph may be added. This is an incredibly inefficient but robust way of solving it.
        guard character.count <= 1 else {
            for char in character {
                appendCharacterToText(String(char))
            }
            
            return
        }
        
        if let lastWord = classifiedText.words.last {
            if lastWord.string == " " {
                classifiedText.words.append(ClassifiedString(character)) // Create a new word
            } else if character == " " { // Each individual space is it's own word
                classifiedText.words.append(ClassifiedString(" "))
            } else {
                lastWord.string.append(character)
            }
        } else {
            classifiedText.words.append(ClassifiedString(character)) // Create the first word
        }
    }
    
    private func removeCharacter(atIndex index: Int) -> Int {
        // IMPORTANT NOTE: The index denotes the vertical line, which is actually BEFORE the character being deleted, not after
        
        guard let classifiedTextIndex = classifiedText.classifiedTextIndex(for: index) else { return index } // Make sure you don't try to delete nothing
        
        var deletedWord: ClassifiedString
        
        if classifiedTextIndex.wordAfter.string.count <= 1 { // If there is only one letter
 
            print("ClassifiedText: \(classifiedText)")
            
            
            
            deletedWord = classifiedText.words.remove(at: classifiedTextIndex.wordAfterIndex)
            
            // Fuse words if you deleted a space
            if deletedWord.type == .space {
                // Make sure it has a word before and after
                if classifiedTextIndex.wordBeforeIndex < classifiedText.words.count - 1 && classifiedTextIndex.wordBeforeIndex > 0 {
                    
                    let spaceIndex = classifiedTextIndex.wordBeforeIndex
                    
                    let wordBeforeSpace = classifiedText.words[spaceIndex]
                    let wordAfterSpace = classifiedText.words[spaceIndex + 1]
                    
                    print("WORDBEFORESPACE: \(wordBeforeSpace)")
                    print("WORDAFTERSPACE: \(wordAfterSpace)")
                    
                    if wordBeforeSpace.type != .space && wordAfterSpace.type != .space {
                        let wordAfterString = wordAfterSpace.string
                        classifiedText.words[spaceIndex].string += wordAfterString // Fuse the words
                        classifiedText.words.remove(at: spaceIndex + 1) // Remove the wordAfter
                    }
                }
            }
            
        } else { // If there is more than one letter
            print("ClassifiedText: \(classifiedText)")
            print("INDEX: \(index)")
            let deletedWordIndex = classifiedTextIndex.wordAfterIndex // The index of the word being deleted (to make it more readable)
            deletedWord = classifiedText.words[deletedWordIndex]
            if deletedWord.redactionState == .unredacted {
                classifiedText.words.remove(at: deletedWordIndex)
            } else {
                classifiedText.words[deletedWordIndex].string.remove(at: classifiedTextIndex.stringIndexInWordAfter)
            }
        }

        if deletedWord.string != " " {
            for word in classifiedText.words {
                if word.lastRedactionState == .unredacted && word.redactionState == .notRedacted {
                    word.lastRedactionState = nil
                }
            }
        }
        
        return index
    }
    
    private func insertCharacter(_ character: Character, atIndex index: Int) {
        
        // Find word and then position in word to insert the character
        
        guard let classifiedTextIndex = classifiedText.classifiedTextIndex(for: index) else {
            classifiedText.words.append(ClassifiedString(character))
            
            // Since a change was made, un-unredact all of the words (change them back to redacted)
            // TODO: move this to another function, this function shouldn't know or care about it.
            if character != " " {
                for word in classifiedText.words {
                    if word.lastRedactionState == .unredacted && word.redactionState == .notRedacted {
                        word.lastRedactionState = nil
                    }
                }
            }
            
            return
        }
        
        // TODO: Clean-up logic
        
        if classifiedTextIndex.wordBefore.type == .space { // If you are inserting a character after a space
            if classifiedTextIndex.wordAfterIndex > classifiedTextIndex.wordBeforeIndex { // If the next word exists
                //let nextWord = classifiedText.words[wordIndex + 1]
                let nextWord = classifiedTextIndex.wordAfter
                
                if nextWord.type == .word {
                    nextWord.string.insert(character, at: classifiedTextIndex.startIndex)
                } else if nextWord.type == .space {
                    classifiedText.words.insert(ClassifiedString(character), at: classifiedTextIndex.wordAfterIndex)
                }
            } else { // If it doesn't exist
                print("WordBeforeIndex: \(classifiedTextIndex.wordBeforeIndex)")
                print("WordAfterIndex: \(classifiedTextIndex.wordAfterIndex)")
                classifiedText.words.insert(ClassifiedString(character), at: classifiedText.words.count)
            }
        }
        
        else if character == " " { // If you are inserting a space
            
            // Split the word into two
            let firstWordString: String = String(classifiedTextIndex.wordBefore.string[..<classifiedTextIndex.stringIndexInWordBefore])
            
            guard !firstWordString.isEmpty else {
                classifiedText.words.insert(ClassifiedString(" "), at: classifiedTextIndex.wordBeforeIndex)
                return
            }
            
            let firstWord = ClassifiedString(firstWordString)
            let secondWordString: String = String(classifiedTextIndex.wordBefore.string[classifiedTextIndex.stringIndexInWordBefore...])
            
            
            let secondWord = ClassifiedString(secondWordString)
            
            // Delete old word
            classifiedText.words.remove(at: classifiedTextIndex.wordBeforeIndex)
            
            // Insert words - ORDER MATTERS!!!
            if secondWordString.count > 0 { classifiedText.words.insert(secondWord, at: classifiedTextIndex.wordBeforeIndex) }
            classifiedText.words.insert(ClassifiedString(" "), at: classifiedTextIndex.wordBeforeIndex)
            classifiedText.words.insert(firstWord, at: classifiedTextIndex.wordBeforeIndex)
            
            print("NUMBER OF WORDS: \(classifiedText.words.count)")
        } else {
        classifiedText.words[classifiedTextIndex.wordBeforeIndex].displayedString.insert(character, at: classifiedTextIndex.stringIndexInWordBefore)
        }
        
        // Since a change was made, un-unredact all of the words (change them back to redacted)
        // TODO: move this to another function, this function shouldn't know or care about it.
        if character != " " {
            for word in classifiedText.words {
                if word.lastRedactionState == .unredacted && word.redactionState == .notRedacted {
                    word.lastRedactionState = nil
                }
            }
        }
        
        print("ClassifiedText: \(classifiedText)")
    
    }
    
    // Returns the index of the selectedTextRange indicator after making the change
    func changeText(inRange range: NSRange, replacementText text: String) -> Int {
        // Make sure it's being inserted at the end; if the length is more than 0, it's trying to replace characters, so those characters must be deleted first
        var originalSelectedIndex = range.location
        
        
        if range.length > 0 {
            for _ in 0..<range.length {
                originalSelectedIndex = removeCharacter(atIndex: range.location)
            }
        }
        
        // Insert text at a specific point (this can be done with appendCharacterToText, which needs to be modified to insertCharacter(atIndex:)
        for (characterIndex, character) in text.enumerated() {
            insertCharacter(character, atIndex: range.location + characterIndex)
            if character == " " { originalSelectedIndex += 1 }
        }
        
        if text == " " {
            return originalSelectedIndex
        } else {
            return originalSelectedIndex + text.count
        }
        
    }
    
    // Just making basic boolean more accesible without having to dig through properties
    var isNotRedacted: Bool { return classifiedText.isNotRedacted }
    var isRedacted: Bool { return classifiedText.isRedacted }
    var isUnredacted: Bool { return classifiedText.isUnredacted }
    
     // This might be the text turned into a sequence of classified strings
    // TODO: Make sure that classifiedText is updated every time text is updated
    
    var redactionState: RedactionState { 
        if isNotRedacted { return .notRedacted }
        else if isRedacted { return .redacted }
        else { return .unredacted }
    }
    
    
    
    let unredactor: Unredactor
    
    
    // MARK: - Functions
    
    // Set the current text to be unredacted based on the model
    func unredact(completion: @escaping () -> ()) {
        guard !classifiedText.isNotRedacted else {
            print("Text not redacted (or unredacted), so unredact() did nothing")
            completion()
            return
        }
        
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

// MARK: - Helper Functions
fileprivate extension Document {
    func setAttributedString(_ attributedString: NSMutableAttributedString, toState state: RedactionState) {
        switch state {
        case .notRedacted:
            break
        case .redacted:
            attributedString.addAttribute(.backgroundColor, value: UIColor.black, range: NSRange(location: 0, length: attributedString.string.count))
            attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: attributedString.string.count))
        case .unredacted:
            attributedString.addAttribute(.backgroundColor, value: UIColor.black, range: NSRange(location: 0, length: attributedString.string.count))
            attributedString.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: attributedString.string.count))
        }
    }
}

