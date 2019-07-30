//
//  Array+Helpers.swift
//  Unredactor
//
//  Created by tyler on 7/22/19.
//  Copyright © 2019 tyler. All rights reserved.
//

import Foundation

// Adds a safe way of accessing Arrays that returns an optional value
// Ex: if let arrayItem = array[safeIndex: index] { // Do stuff with array item }
extension Array {
    subscript (safeIndex index: UInt) -> Element? {
        return Int(index) < count ? self[Int(index)] : nil
    }
}
