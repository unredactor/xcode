//
//  Chatbot.swift
//  Unredactor
//
//  Created by Tyler Gee on 8/26/19.
//  Copyright © 2019 tyler. All rights reserved.
//

import Foundation

class Chatbot {
    func reply(toMessage message: Message, completion: @escaping (Message) -> Void) {
        // Calculate message
        let replyMessage = Message(withText: "This is an automated reply", fromSender: .chatbot)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            completion(replyMessage)
        }
        
    }
}
