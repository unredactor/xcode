//
//  UnredactGestureRecognizer.swift
//  Unredactor
//
//  Created by tyler on 7/17/19.
//  Copyright © 2019 tyler. All rights reserved.
//

import Foundation
import UIKit

extension UITapGestureRecognizer {
    func characterIndexTapped(inDocument document: Document) -> Int {
        let textView = self.view as! UITextView
        let attributedText = document.attributedText
        
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: textView.bounds.size)
        let textStorage = NSTextStorage(attributedString: attributedText)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        textContainer.size = CGSize(width: textView.frame.size.width, height: textView.frame.size.height) //Add 200 to make it arbitrarily high
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInTextView = self.location(in: textView)
        
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInTextView.x,
                                                     y: locationOfTouchInTextView.y)
        //let locationOfTouchInTextContainer = self.location(in: view)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        print("Index of character tapped: \(indexOfCharacter)")
        
        return indexOfCharacter
    }
}
