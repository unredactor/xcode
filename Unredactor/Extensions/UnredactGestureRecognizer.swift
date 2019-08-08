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
        var range = NSRange(location: 0, length: 1)
        print(document.attributedText.attributes(at: 0, effectiveRange: &range))
        
        print(document.attributedText)
        // as! NSMutableAttributedString
        //attributedText.addAttribute(.font, value: textView.font!, range: NSRange(location: 0, length: (textView.text?.count)!))
        //label.sizeToFit()
        
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: textView.bounds.size)
        let textStorage = NSTextStorage(attributedString: attributedText)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        //textContainer.lineFragmentPadding = 7
        //textContainer.lineBreakMode = label.lineBreakMode
        //textContainer.maximumNumberOfLines = label.numberOfLines
        let textViewSize = textView.bounds.size
        //let textRect = layoutManager.boundingRect(forGlyphRange: NSRange(location: 0, length: label.text!.count), in: textContainer)
        
        textContainer.size = CGSize(width: textView.frame.size.width, height: textView.frame.size.height) //Add 200 to make it arbitrarily high
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInTextView = self.location(in: textView)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        //let textContainerOffset = CGPoint(x: 0, y: (textViewSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInTextView.x,
                                                     y: locationOfTouchInTextView.y)
        //let locationOfTouchInTextContainer = self.location(in: view)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        print("Index of character tapped: \(indexOfCharacter)")
        
        return indexOfCharacter
    }
}
