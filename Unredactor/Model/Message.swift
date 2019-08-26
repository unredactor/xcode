//
//  Message.swift
//  Unredactor
//
//  Created by Tyler Gee on 8/26/19.
//  Copyright © 2019 tyler. All rights reserved.
//

import Foundation

class Message {
    var text: String
    var sender: Sender
    
    init(withText text: String, fromSender sender: Sender) {
        self.text = text
        self.sender = sender
    }
}

enum Sender {
    case chatbot, user
}
