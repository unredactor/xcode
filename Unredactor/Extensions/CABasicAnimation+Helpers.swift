//
//  CABasicAnimation+Helpers.swift
//  Unredactor
//
//  Created by Tyler Gee on 8/14/19.
//  Copyright © 2019 tyler. All rights reserved.
//

import Foundation
import UIKit

extension CABasicAnimation {
    convenience init(keyPath: String, toValue: Any, fromValue: Any?, duration: TimeInterval) {
        self.init(keyPath: keyPath)
        self.toValue = toValue
        self.fromValue = fromValue
        self.duration = duration
        self.isRemovedOnCompletion = false
        self.fillMode = .forwards
    }
}

// random change
