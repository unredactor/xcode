//
//  EditMode.swift
//  Unredactor
//
//  Created by Tyler Gee on 8/12/19.
//  Copyright © 2019 tyler. All rights reserved.
//

import Foundation
import UIKit

enum EditMode { // Can be either edit or redact
    case editable, redactable
    
    var textColor: UIColor {
        switch self {
        case .editable:
            return UIColor(white: 0.54, alpha: 0.9)
        case .redactable:
            return UIColor(white: 0.69, alpha: 0.9)
        }
    }
    
    func toggled() -> EditMode {
        if self == .editable {
            return .redactable
        } else {
            return .editable
        }
    }
}

// random change
