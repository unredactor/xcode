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
    
    var font = UIFont(name: "Courier", size: 22)!
    
    /*
    var attributedText: NSAttributedString { // Text that is used by the DocumentCell to display black bars. Needs to remember the length of redacted words (so it looks nicer)
        
        let attributedText: NSMutableAttributedString = NSMutableAttributedString(string: "")//, attributes: attributes)
        let attributedSpace = NSMutableAttributedString(string: " ")
        let redactedAttributedSpace = NSMutableAttributedString(string: " ", attributes: [NSAttributedString.Key.backgroundColor : UIColor.black])
        
        //attributedText.addAttributes([.font: font], range: NSMakeRange(0, attributedText.string.count)) // Sets the font of the attributed text
        //attributedText.addAttribute(.font, value: font, range: NSMakeRange(0, attributedText.string.count))
        
        for (index, word) in classifiedText.words.enumerated() {
            let string = word.redactionState == .unredacted ? word.unredactorPrediction! : word.string
            let attributedWord = NSMutableAttributedString(string: string)
            if word.redactionState == .redacted {
                attributedWord.addAttribute(.backgroundColor, value: UIColor.black, range: NSRange(location: 0, length: word.string.count))
                attributedWord.addAttribute(.backgroundColor, value: UIColor.black, range: NSRange(location: 0, length: word.string.count))
            } else if word.redactionState == .unredacted {
                attributedWord.addAttribute(.backgroundColor, value: UIColor.black, range: NSRange(location: 0, length: word.unredactorPrediction!.count))
                attributedWord.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: word.unredactorPrediction!.count))
            }
            
            if string != " " {
                
                // TODO: Clean up this logic
                if index > 0 {
                    let lastWord = classifiedText.words[index - 1]
                    if lastWord.redactionState == .redacted && word.redactionState == .redacted {
                        attributedText.append(redactedAttributedSpace)
                    } else {
                        attributedText.append(attributedSpace)
                    }
                } else {
                    attributedText.append(attributedSpace)
                }
                
                
                
            } // If the string is " ", this means the user typed a space. This is used to separate words of different redaction states when typing. If the space was added, this would produce two spaces when the user typed only one. There should only be one " " word if any, and it should be at the end of the sentence.
            attributedText.append(attributedWord)
            print("AttributedWord: \(attributedWord.string)")
        }
        
        attributedText.addAttribute(.font, value: font, range: NSMakeRange(0, attributedText.string.count))
        
        // Since a space is added before every word, we need to get rid of the initial space
        if !attributedText.string.isEmpty {
            attributedText.deleteCharacters(in: NSRange(location: 0, length: 1))
        }
    
        
        return attributedText
    }
 */
    var attributedText: NSAttributedString { // Text that is used by the DocumentCell to dsiplay black bars.
        
        let attributedText: NSMutableAttributedString = NSMutableAttributedString(string :"")
        
        for (_, word) in classifiedText.words.enumerated() {
            let string = word.redactionState == .unredacted ? word.unredactorPrediction! : word.string
            let attributedWord = NSMutableAttributedString(string: string)
            
            //print("WORD: \(string), redactionState: \(word.redactionState)")
            
            if word.redactionState == .redacted {
               // Add black background
                attributedWord.addAttribute(.backgroundColor, value: UIColor.black, range: NSRange(location: 0, length: word.string.count))
                attributedWord.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: word.string.count))
            } else if word.redactionState == .unredacted {
                attributedWord.addAttribute(.backgroundColor, value: UIColor.black, range: NSRange(location: 0, length: word.unredactorPrediction!.count))
                attributedWord.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: word.unredactorPrediction!.count))
            }
            
            attributedText.append(attributedWord)
        }
        
        attributedText.addAttribute(.font, value: font, range: NSMakeRange(0, attributedText.string.count))
        
        return attributedText
    }
    
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
    
    func removeCharacter(atIndex index: Int) -> Int {
        //let classifiedTextLength = classifiedText.rawText.count
        
        guard let classifiedTextIndex = classifiedText.classifiedTextIndex(for: index) else { return index } // Make sure you don't try to delete nothing
        
        //let word = classifiedTextIndex.word
        //let startIndex = classifiedTextIndex.startIndex
        
        //print("REMOVECHARACTER(at:\(index)")
        /*
        let wordIndex = classifiedTextIndex.wordIndex
        let deletionIndex = classifiedTextIndex.deletionIndex
 */
        
        //print("WORD: \(classifiedTextIndex.wordBefore.string)")
        
        var deletedWord: ClassifiedString
        
        if classifiedTextIndex.wordAfter.string.count <= 1 { // If there is only one letter
            
            //let word = classifiedText.words[wordIndex]
            print("ClassifiedText: \(classifiedText)")
            //print("DeletedWord: \(word.string)")
            
            
            
            deletedWord = classifiedText.words.remove(at: classifiedTextIndex.wordAfterIndex)
            
            /*
            // Wacky special case, but I just want to get this to work
            if wordIndex < classifiedText.words.count {
                print("STRING: \(classifiedText.words[wordIndex].string)\"")
                deletedWord = classifiedText.words.remove(at: wordIndex)
            } else {
                deletedWord = classifiedText.words.remove(at: wordIndex)
            }
 */
            
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
            // TODO: Cleanup logic and remove redudant classifiedText.words.remove(at:)
            
            /* USED TO BE USED
            if wordIndex < classifiedText.words.count && classifiedText.words[wordIndex].string.count <= 1 {
                print("STRING: \(classifiedText.words[wordIndex].string)\"")
                deletedWord = classifiedText.words.remove(at: classifiedTextIndex.wordBeforeIndex)
            } else {
                print("TESTING WORD: \(classifiedText.words[wordIndex].string)")
                classifiedText.words[wordIndex].string.remove(at: deletionIndex)
                deletedWord = ClassifiedString("") // Didn't delete any word
            }
 */
            classifiedText.words[classifiedTextIndex.wordAfterIndex].string.remove(at: classifiedTextIndex.deletionIndex)
            
            
            //print("DeletedWord: \(classifiedText.words[wordIndex].string)")
            
            /* USED TO BE USED
            // Fuse words if you deleted a space
            if deletedWord.type == .space {
                // Make sure it has a word before and after
                
                print("wordIndex: \(wordIndex)")
                if wordIndex + 1 < classifiedText.words.count && wordIndex + 1 > 0 {
                    let wordBefore = classifiedText.words[wordIndex]
                    print("WORD BEFORE: \(wordBefore.string)")
                    let wordAfter = classifiedText.words[wordIndex + 1]
                    print("WORD AFTER: \(wordAfter.string)")
                    
                    if wordBefore.type != .space && wordAfter.type != .space {
                        let wordAfterString = wordAfter.string
                        classifiedText.words[wordIndex].string += wordAfterString // Fuse the words
                        classifiedText.words.remove(at: wordIndex + 1) // Remove the wordAfter
                    }
                }
            }
 */
            
            /*
            if wordIndex < classifiedText.words.count - 1 {
                print("STRING: \(classifiedText.words[wordIndex + 1].string)\"")
                if classifiedText.words[wordIndex + 1].string == " " {
                    classifiedText.words.remove(at: wordIndex + 1)
                    return index
                } else {
                    print("STRING: \(classifiedText.words[wordIndex + 1].string)\"")
                }
            }
            */
                /*
                // If that was the last letter, add a space word
                if wordLength == 1 {
                    classifiedText.words.append(ClassifiedString(" "))
                }
 */
        }
            
        /* USES TO BE USED
        if deletedWord.string != " " {
            for word in classifiedText.words {
                if word.redactionState == .unredacted {
                    word.redactionState = .redacted
                }
            }
        }
*/
        
        return index
    }
    
    
    private func insertCharacter(_ character: Character, atIndex index: Int) {
        
        // Find word and then position in word to insert the character
        
        //print("INDEX: \(index)")
        
        guard let classifiedTextIndex = classifiedText.classifiedTextIndex(for: index) else {
            classifiedText.words.append(ClassifiedString(character))
            
            // Since a change was made, un-unredact all of the words (change them back to redacted)
            // TODO: move this to another function, this function shouldn't know or care about it.
            if character != " " {
                for word in classifiedText.words {
                    if word.redactionState == .unredacted {
                        word.redactionState = .redacted
                    }
                }
            }
            
            return
        }
        
    
        //let classifiedTextIndex = classifiedText.classifiedTextIndex(for: index)!
        //let word = classifiedTextIndex.word
        //let wordIndex = classifiedTextIndex.wordIndex
        
        // TODO: Clean-up logic
        
        if classifiedTextIndex.wordBefore.type == .space { // If you are inserting a character after a space
            if classifiedTextIndex.wordAfterIndex > classifiedTextIndex.wordBeforeIndex && classifiedTextIndex.wordAfter.type == .word { // If the next word exists
                //let nextWord = classifiedText.words[wordIndex + 1]
                classifiedText.words[classifiedTextIndex.wordAfterIndex].string.insert(character, at: classifiedTextIndex.startIndex)
            } else { // If it doesn't exist
                print("WordBeforeIndex: \(classifiedTextIndex.wordBeforeIndex)")
                print("WordAfterIndex: \(classifiedTextIndex.wordAfterIndex)")
                classifiedText.words.insert(ClassifiedString(character), at: classifiedTextIndex.wordAfterIndex + 1)
            }
        }
        
        else if character == " " { // If you are inserting a space
            
            // Split the word into two
            let firstWordString: String = String(classifiedTextIndex.wordBefore.string[..<classifiedTextIndex.insertionIndex])
            
            guard !firstWordString.isEmpty else {
                classifiedText.words.insert(ClassifiedString(" "), at: classifiedTextIndex.wordBeforeIndex)
                return
            }
            
            let firstWord = ClassifiedString(firstWordString)
            let secondWordString: String = String(classifiedTextIndex.wordBefore.string[classifiedTextIndex.insertionIndex...])
            
            
            let secondWord = ClassifiedString(secondWordString)
            
            // Delete old word
            classifiedText.words.remove(at: classifiedTextIndex.wordBeforeIndex)
            
            // Insert words - ORDER MATTERS!!!
            if secondWordString.count > 0 { classifiedText.words.insert(secondWord, at: classifiedTextIndex.wordBeforeIndex) }
            classifiedText.words.insert(ClassifiedString(" "), at: classifiedTextIndex.wordBeforeIndex)
            classifiedText.words.insert(firstWord, at: classifiedTextIndex.wordBeforeIndex)
            
            print("NUMBER OF WORDS: \(classifiedText.words.count)")
        } /*else if word.string == " " {
            classifiedText.words[wordIndex].string = String(character)
 
        }*/
 else {
            //print("INSERTION INDEX: \(classifiedTextIndex.insertionIndex)")
            classifiedText.words[classifiedTextIndex.wordBeforeIndex].string.insert(character, at: classifiedTextIndex.insertionIndex)
        }
        
        // Since a change was made, un-unredact all of the words (change them back to redacted)
        // TODO: move this to another function, this function shouldn't know or care about it.
        if character != " " {
            for word in classifiedText.words {
                if word.redactionState == .unredacted {
                    word.redactionState = .redacted
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
            for _ in 0...range.length {
                removeCharacter(atIndex: range.location + 1)
                originalSelectedIndex -= 1
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
    
    /*
    func removeLastCharacter() {
        guard let lastWord = classifiedText.words.last else { return }
        
        let string: String = (lastWord.redactionState == RedactionState.unredacted) ? lastWord.unredactorPrediction! : lastWord.string
        
        if string.count > 1 {
            if lastWord.redactionState == RedactionState.unredacted { lastWord.unredactorPrediction?.removeLast() }
            else { lastWord.string.removeLast() }
        } else {
            classifiedText.words.removeLast()
            //if lastWord.string != " " { classifiedText.words.append(ClassifiedString(" ")) }
        }
    }
 */
    
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
        guard classifiedText.isRedacted else {
            print("Text not redacted, so unredact() did nothing")
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




