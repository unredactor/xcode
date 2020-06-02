//
//  ClassifiedText.swift
//  Unredactor
//
//  Created by tyler on 7/18/19.
//  Copyright © 2019 tyler. All rights reserved.
//

import Foundation
import UIKit

// MARK: - ClassifiedText
class ClassifiedText: NSCopying { // NSCopying is effectively for the unredactor
    var words: [ClassifiedString]
    
    var rawText: String { // Returns just the underlying original text, ignoring redactions/unredactions
        
        var rawText: String = ""
        for word in self.words {
            let string = word.string
            
            rawText.append(string)
            //rawText.append(" ")
        }
        
        return rawText
    }
    
    var urlText: String {
        var urlText: String = ""
        for word in self.words {
            var string = word.string
            if word.redactionState != .notRedacted { string = "unk" }
            
            /*
            // space for urls
            if word.type == .space { urlText.append("%20") }
            else { urlText.append(string) }
 */
            urlText.append(string)
        }
        
        return urlText
    }
    
    var maskTokenText: String {
        // This is sent to unredactor.com. It uses the mask token ("unk")
        var maskTokenText: String = ""
        for word in self.words {
            if word.redactionState == .redacted {
                maskTokenText.append(Unredactor.maskToken)
            } else {
                maskTokenText.append(word.string)
            }
        }
        return maskTokenText
    }
    
    var numberOfCharacters: Int {
        var numberOfCharacters: Int = 0
        for word in words {
            let string: String = (word.redactionState == .unredacted) ? word.unredactorPrediction! : word.string
            numberOfCharacters += string.count
        }
        
        // Account for spaces
        numberOfCharacters += words.count - 1
        
        return numberOfCharacters
    }
    
    /*
    func wordForCharacterIndex(_ characterIndex: Int) -> ClassifiedString? {
        guard characterIndex >= 0 && characterIndex < numberOfCharacters else { return nil }
        
        var startIndex = 0
        var endIndex = 0 // Place we are at in the sequence currently
        for word in words {
            let wordLength = (word.redactionState == .unredacted) ? word.unredactorPrediction!.count : word.string.count
            
            if let unredactorPrediction = word.unredactorPrediction {
                print("UNREDACTOR PREDICTION: \(unredactorPrediction)")
            }
            
            endIndex += wordLength
            startIndex = endIndex - wordLength
            if characterIndex >= startIndex && characterIndex <= endIndex - 1 {
                if word.type != .space { return word }
                else { return nil }
            }
        }
        
        return nil
    }
 */
    func wordForCharacterIndex(_ characterIndex: Int) -> ClassifiedString? {
        guard characterIndex >= 0 && characterIndex < numberOfCharacters else { return nil }
        
        var startIndex = 0
        var endIndex = 0 // Place we are at in the sequence currently
        for word in words {
            let wordLength = (word.redactionState == .unredacted) ? word.unredactorPrediction!.count : word.string.count
            
            if let unredactorPrediction = word.unredactorPrediction {
                print("UNREDACTOR PREDICTION: \(unredactorPrediction)")
            }
            
            endIndex += wordLength
            startIndex = endIndex - wordLength
            if characterIndex >= startIndex && characterIndex <= endIndex - 1 {
                if word.type != .space { return word }
                else { return nil }
            }
        }
        
        return nil
    }
    
    // Returns true if this classified text contains any redactions/unredactions
    var isNotRedacted: Bool {
        
        for word in words {
            //print(word.redactionState)
            if word.redactionState != .notRedacted {
                return false
            }
        }
        
        return true
    }
    
    var isRedacted: Bool {
        for word in words {
            if word.redactionState == .redacted {
                return true
            }
        }
        
        return false
    }
    
    var isUnredacted: Bool {
        for word in words {
            if word.redactionState == .unredacted {
                return true
            }
        }
        
        return false
    }
    
    // Returns the index of the first character of a word
    func characterIndexForWord(wordIndex: Int) -> Int? {
        var characterIndex = 0
        for (index, word) in words.enumerated() {
            characterIndex += word.string.count
            if index == wordIndex {
                //let numberOfSpaces = wordIndex
                return characterIndex// + numberOfSpaces
            }
        }
        
        return nil
    }
    
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = ClassifiedText(withClassifiedWords: words)
        return copy
    }
 
    
    static func classifiedWordsFromText(_ text: String) -> [ClassifiedString] {
        
        var words = [ClassifiedString]()
        
        var currentWord: String = ""
        
        for character in text {
            if character == " " {
                if currentWord.count > 0 { words.append(ClassifiedString(currentWord)) }
                words.append(ClassifiedString(" "))
                
                currentWord = ""
            } else {
                currentWord += String(character)
            }
        }
        
        // The last word would be non added, so add it
        if currentWord.count > 0 { words.append(ClassifiedString(currentWord)) }
        
        return words
    }
    
    init(withWords words: [String]) {
        self.words = words.map { ClassifiedString($0) }
    }
    
    init(withText text: String) {
        let words = ClassifiedText.classifiedWordsFromText(text)
        self.words = words
    }
    
    init(withClassifiedWords classifiedWords: [ClassifiedString]) {
        self.words = classifiedWords
    }
    
    class Index {
        // When wordBeforeIndex and wordAfterIndex are the same, then it means that you are at the end of the text (there is no wordAfter but I just make it the wordBefore so that the app doens't crash)
        var wordBeforeIndex: Int
        var wordAfterIndex: Int
        var indexInWordBefore: Int
        var indexInWordAfter: Int
        var wordBefore: ClassifiedString
        var wordAfter: ClassifiedString
        var startIndex: String.Index
        var stringIndexInWordBefore: String.Index
        var stringIndexInWordAfter: String.Index
        
        init(wordBeforeIndex: Int, wordAfterIndex: Int, wordBefore: ClassifiedString, wordAfter: ClassifiedString, indexInWordBefore: Int, indexInWordAfter: Int) {
            self.wordBeforeIndex = wordBeforeIndex
            self.wordAfterIndex = wordAfterIndex
            self.indexInWordBefore = indexInWordBefore
            self.indexInWordAfter = indexInWordAfter
            self.wordBefore = wordBefore
            self.wordAfter = wordAfter
            self.startIndex = wordAfter.string.startIndex
            self.stringIndexInWordBefore = wordBefore.displayedString.index(startIndex, offsetBy: indexInWordBefore)
            self.stringIndexInWordAfter = wordAfter.displayedString.index(startIndex, offsetBy: indexInWordAfter)
        }
    }
    
    func classifiedTextIndex(for index: Int) -> ClassifiedText.Index? {
        var indexInText = 0
        
        for (wordIndex, word) in words.enumerated() {
            let wordLength = word.displayedString.count
            
            // Keep counting if you haven't counted to the desired word yet
            if indexInText + wordLength < index && wordIndex + 1 < words.count {
                indexInText += wordLength
            } else {
                var indexInWordBefore = index - indexInText
                //print("INDEX IN WORD: \(indexInWord)")
                //print("INDEX IN TEXT: \(indexInText)")
                //print("WORD INDEX: \(wordIndex)")
                
                // Word After will be different from word before only when we are at the end of a word (which also includes the start of another word)
                var isIndexAtEndOfWord: Bool = false
                if (indexInWordBefore == words[wordIndex].displayedString.count || indexInWordBefore == 0) { isIndexAtEndOfWord = true }
                // THIS IS BROKEN ^^^ (possibly due to deleting spaces)
                
                // FIX WORD AFTER INDEX - it's 5 instead of 0 for some reason...? (when typing this unk)
                var wordAfterIndex = wordIndex
                var indexInWordAfter = indexInWordBefore
                if isIndexAtEndOfWord {
                    indexInWordAfter = 0
                    
                    if wordIndex + 1 < words.count && index != 0 { wordAfterIndex += 1 }
                }
                //print("INDEX IN WORD AFTER \(indexInWordAfter)")
                
                let wordBeforeIndex = wordIndex
                let wordBefore = words[wordBeforeIndex]
                let wordAfter = words[wordAfterIndex]
                
                // Completely make sure indexInWord is in the word
                if indexInWordBefore < 0 { indexInWordBefore = 0 }
                if indexInWordBefore > words[wordBeforeIndex].displayedString.count {
                    indexInWordBefore -= words[wordBeforeIndex].displayedString.count
                }
                
                // Double check that they are within the upper bound
                if indexInWordBefore > wordBefore.string.count { indexInWordBefore = wordBefore.string.count }
                if indexInWordAfter > wordAfter.string.count {
                    indexInWordAfter = wordAfter.string.count }
                
                return Index(wordBeforeIndex: wordBeforeIndex, wordAfterIndex: wordAfterIndex, wordBefore: wordBefore, wordAfter: wordAfter, indexInWordBefore: indexInWordBefore, indexInWordAfter: indexInWordAfter)
            }
        }
        
        return nil
    }
}

// Make it printable with print()
extension ClassifiedText: CustomStringConvertible {
    var description: String {
        var description: String = ""
        for (index, word) in words.enumerated() {
            description += "|\(word.string)"
        }
        
        return description
    }
}

// MARK: - ClassifiedString
// A special string that knows whether or not is has been redacted or not
class ClassifiedString: CustomStringConvertible {
    var string: String
    var type: ClassifiedStringType
    var unredactorPrediction: String?
    var redactionState: RedactionState = .notRedacted
    var lastRedactionState: RedactionState?
    
    // For identifying through the link method:
    var id: UUID
    
    var displayedString: String { // The string that is actually used/displayed (it is just the unredactorPrediction when the ClassifiedString.redactionState == .unredacted)
        get {
            if let unredactorPrediction = unredactorPrediction, redactionState == .unredacted {
                return unredactorPrediction
            } else {
                return string
            }
        }
        
        set {
            if var unredactorPrediction = unredactorPrediction, redactionState == .unredacted {
                unredactorPrediction = newValue
            } else {
                string = newValue
            }
        }
    }
    
    func toggleRedactionState() {
        print("Toggling word: \(string)")
        
        switch redactionState {
        case .notRedacted:
            redactionState = lastRedactionState ?? .redacted
            lastRedactionState = .notRedacted
        case .redacted:
            redactionState = .notRedacted
            lastRedactionState = .redacted
        case .unredacted:
            redactionState = .notRedacted
            lastRedactionState = .unredacted
            // TODO: Make this also toggle the string to be it's predicted word version instead of the raw string
        }
    }
    
    init(_ string: String) {
        self.string = string
        
        if string == " " {
            type = .space
        } else {
            type = .word
        }
        
        id = UUID()
    }
    
    init(_ character: Character) {
        self.string = String(character)
        
        if character == " " {
            type = .space
        } else {
            type = .word
        }
        
        id = UUID()
    }
    
    enum ClassifiedStringType {
        case word, space
    }
    
    var description: String {
        return string
    }
}

enum RedactionState {
    case notRedacted, redacted, unredacted // Not redacted is normal, unredacted is when the model makes a prediction for it.
}

extension NSAttributedString {
    func height(withConstrainedWidth width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return ceil(boundingBox.width)
    }
}
