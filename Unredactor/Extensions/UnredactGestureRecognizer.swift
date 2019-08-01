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
    func characterIndexTapped() -> Int {
        let label = self.view as! UILabel
        let attributedText = label.attributedText as! NSMutableAttributedString
        attributedText.addAttribute(.font, value: label.font, range: NSRange(location: 0, length: (label.text?.count)!))
        //label.sizeToFit()
        
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: label.bounds.size)
        let textStorage = NSTextStorage(attributedString: attributedText)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 7
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        //let textRect = layoutManager.boundingRect(forGlyphRange: NSRange(location: 0, length: label.text!.count), in: textContainer)
        
        textContainer.size = CGSize(width: label.frame.size.width, height: label.frame.size.height) //Add 200 to make it arbitrarily high
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: 0, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x,
                                                     y: locationOfTouchInLabel.y - textContainerOffset.y)
        //let locationOfTouchInTextContainer = self.location(in: view)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        print("Index of character tapped: \(indexOfCharacter)")
        
        return indexOfCharacter
    }
}
