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
    var attributedText: NSAttributedString { // Text that is used by the DocumentCell to display black bars. Needs to remember the length of redacted words (so it looks nicer)
        let attributedText: NSMutableAttributedString = NSMutableAttributedString(string: "")
        let attributedSpace = NSMutableAttributedString(string: " ")
        
        attributedText.addAttributes([.font: UIFont.systemFont(ofSize: 14)], range: NSMakeRange(0, attributedText.string.count)) // Sets the font of the attributed text
        
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
            
            attributedText.append(attributedSpace)
            attributedText.append(attributedWord)
        }
 
    
        
        return attributedText
    }
    
    // Just making basic boolean more accesible without having to dig through properties
    var isNotRedacted: Bool { return classifiedText.isNotRedacted }
    var isRedacted: Bool { return classifiedText.isRedacted }
    var isUnredacted: Bool { return classifiedText.isUnredacted }
    
     // This might be the text turned into a sequence of classified strings
    // TODO: Make sure that classifiedText is updated every time text is updated
    
    
    
    let unredactor: Unredactor
    
    
    // MARK: - Functions
    
    // Set the current text to be unredacted based on the model
    func unredact(completion: @escaping () -> ()) {
        guard classifiedText.isRedacted else {
            print("Text not redacted, so unredact() did nothing")
            return
        }
        
        print("unredact() called")
        
        unredactor.unredact(classifiedText, completion: { (unredactedText: ClassifiedText) -> Void in
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




