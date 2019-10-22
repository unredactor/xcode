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
    func characterIndexTapped(inDocument document: Document) -> Int? {
        let textView = self.view as! UITextView
        let attributedText = document.attributedText
        
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: textView.bounds.size)
        let textStorage = NSTextStorage(attributedString: attributedText)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        let width = textView.frame.size.width
        let sizeThatFits = textView.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
        textContainer.size = CGSize(width: width, height: sizeThatFits.height)
        textContainer.lineFragmentPadding = 0
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInTextView = self.location(in: textView) // Location within UIView (from 0,0 at bottom left)
        print("LOACTION OF TOUCH IN TEXT VIEW: \(locationOfTouchInTextView)")
        
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInTextView.x,
                                                     y: locationOfTouchInTextView.y)
        
        guard locationOfTouchInTextView.y > 0 else {
            print("TAPPED TOO HIGH")
            return nil
        }
        
        
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        print("Index of character tapped: \(indexOfCharacter)")
        print("text: \(attributedText.string)")
        
        return indexOfCharacter
    }
}
