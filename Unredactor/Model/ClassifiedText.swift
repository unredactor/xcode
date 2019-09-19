//
//  ClassifiedText.swift
//  Unredactor
//
//  Created by tyler on 7/18/19.
//  Copyright © 2019 tyler. All rights reserved.
//

import Foundation
import UIKit

class ClassifiedText: NSCopying { // NSCopying is effectively for the unredactor
    var words: [ClassifiedString]
    
    var rawText: String { // Returns just the underlying original text, ignoring redactions/unredactions
        
        var rawText: String = ""
        for word in self.words {
            let string = word.string
            
            rawText.append(string)
            rawText.append(" ")
        }
        if rawText.count > 0 { rawText.removeLast() }// Remove the last space that was added 
        
        return rawText
    }
    
    var urlText: String {
        var urlText: String = ""
        for word in self.words {
            var string = word.string
            if word.redactionState == .redacted { string = "unk" }
            
            urlText.append(string)
            urlText.append("%20") // space for urls
        }
        
        for _ in 0..<3 { urlText.removeLast() } // Remove the "%20" at the end
        
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
            maskTokenText.append(" ")
        }
        
        maskTokenText.removeLast() // Remove the last space that was added.
        
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
    
    func wordForCharacterIndex(_ characterIndex: Int) -> ClassifiedString? {
        guard characterIndex >= 0 && characterIndex < numberOfCharacters else { return nil }
        
        var startIndex = 0
        var endIndex = 0 // Place we are at in the sequence currently
        for word in words {
            let wordLength = word.redactionState == .unredacted ? word.unredactorPrediction!.count : word.string.count
            
            if let unredactorPrediction = word.unredactorPrediction {
                print("UNREDACTOR PREDICTION: \(unredactorPrediction)")
            }
            
            endIndex += wordLength
            startIndex = endIndex - wordLength
            if characterIndex >= startIndex && characterIndex <= endIndex - 1 {
                return word
            }
            
            // Add a space
            startIndex += 1
            endIndex += 1
        }
        
        return nil
    }
    
    // Returns true if this classified text contains any redactions/unredactions
    var isNotRedacted: Bool {
        for word in words {
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
        //let wordSubstrings = text.split(whereSeparator: { ($0 == " " || $0.isNewLine) }) // split by both spaces and line breaks
        let wordSubstrings = text.split { (separator) -> Bool in
            return separator == " " || separator.isNewline
        }
        let words = wordSubstrings.map { String($0) }
        let classifiedWords = words.map { ClassifiedString($0) }
        
        return classifiedWords
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
        var wordIndex: Int
        var indexInWord: Int
        var word: ClassifiedString
        var startIndex: String.Index
        var insertionIndex: String.Index
        var deletionIndex: String.Index
        
        init(wordIndex: Int, indexInWord: Int, word: ClassifiedString) {
            self.wordIndex = wordIndex
            self.indexInWord = indexInWord
            self.word = word
            self.startIndex = word.string.startIndex
            self.insertionIndex = word.string.index(startIndex, offsetBy: indexInWord)
            if word.string.count > 0 { self.deletionIndex = word.string.index(startIndex, offsetBy: indexInWord) } else {
                self.deletionIndex = self.insertionIndex
            }
        }
    }
    
    func classifiedTextIndex(for index: Int) -> ClassifiedText.Index? {
        var indexInText = 0
        
        for (wordIndex, word) in words.enumerated() {
            print("word: \(word.string)")
            let wordLength = word.string.count
            
            // Keep counting if you haven't counted to the desired word yet
            if indexInText + wordLength < index {
                indexInText += wordLength + 1
            } else {
                let indexInWord = index - indexInText
                
                print("INDEX: \(index), WORDINDEX: \(wordIndex)")
                
                return Index(wordIndex: wordIndex, indexInWord: indexInWord, word: word)
            }
        }
        
        return nil
    }
}

// A special string that knows whether or not is has been redacted or not
class ClassifiedString {
    var string: String
    var unredactorPrediction: String?
    var redactionState: RedactionState = .notRedacted
    var lastRedactionState: RedactionState?
    
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
    }
    
    init(_ character: Character) {
        self.string = String(character)
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
