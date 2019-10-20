//
//  UnredactoTextView.swift
//  Unredactor
//
//  Created by Tyler Gee on 8/28/19.
//  Copyright © 2019 tyler. All rights reserved.
//

import UIKit

class UnredactorTextView: UITextView {
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        print(sender)
        
        return super.canPerformAction(action, withSender: sender)
        
        var canPerformAction = super.canPerformAction(action, withSender: sender)
    }
}
