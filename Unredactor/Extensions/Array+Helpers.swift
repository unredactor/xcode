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

// These help with turning a Dictionary into data so we can send it via a POST request to the server
// They are from the accepted answer on https://stackoverflow.com/questions/26364914/http-request-in-swift-with-post-method
extension Dictionary {
    func percentEscaped() -> String {
        return map { (key, value) in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
            }
            .joined(separator: "&")
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}
