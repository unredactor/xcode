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
        textContainer.lineBreakMode = .byCharWrapping
        
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
 
    // Implementing changes in this one below, the unchanged one that kinda works is above
    
    /*
    func characterIndexTapped(inDocument document: Document) -> Int? {
        let textView = self.view as! UITextView
        let attributedText = document.attributedText
        
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: textView.bounds.size)
        let textStorage = NSTextStorage(attributedString: attributedText)
        print("attributedtext: \(attributedText)")
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        let width = textView.frame.size.width
        let sizeThatFits = textView.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
        textContainer.size = CGSize(width: width, height: sizeThatFits.height)
        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = .byWordWrapping
        
        /*
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
 */
        // From https://stackoverflow.com/questions/1256887/create-tap-able-links-in-the-nsattributedstring-of-a-uilabel
        let locationOfTouchInTextView: CGPoint = self.location(in: textView)
        let textViewSize: CGSize = textView.bounds.size
        let textBoundingBox: CGRect = layoutManager.usedRect(for: textContainer)
        let textContainerOffset: CGPoint = CGPoint (
            x: (textViewSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
            y: (textViewSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y
        )
        
        let locationOfTouchInTextContainer = CGPoint (
            x: locationOfTouchInTextView.x - textContainerOffset.x,
            y: locationOfTouchInTextView.y - textContainerOffset.y
        )
        
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints:  nil)
        
        return indexOfCharacter
    }
 */
}
