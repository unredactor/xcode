//
//  ChatViewController.swift
//  Unredactor
//
//  Created by Tyler Gee on 8/26/19.
//  Copyright © 2019 tyler. All rights reserved.
//

import UIKit

// MARK: - Class Definition
class ChatViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var messageInputView: UIView!
    @IBOutlet weak var messageTextView: UITextView!
    
    var messages: [Message] = []

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMessageInputView()
    }
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        let newMessage = Message(withText: messageTextView.text, fromSender: .user)
        messages.append(newMessage)
        
        tableView.reloadData()
        
        // Reply
        
    }
}

// MARK: - Table View Data Source & Delegate
extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        if message.sender == .user {
            let cell = tableView.dequeueReusableCell(withIdentifier: "userMessage") as! MessageTableViewCell
            
            cell.configure(withMessage: message)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "chatbotMessage") as! MessageTableViewCell
            
            cell.configure(withMessage: message)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let message = messages[indexPath.row]
        
        // From: https://www.youtube.com/watch?v=bNtsekO51iQ
        let size = CGSize(width: view.frame.width, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedFrame = NSString(string: message.text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont(name: "Courier", size: 17)!], context: nil)
        
        return estimatedFrame.height + 32
    }
}

// MARK: - Helper Methods
fileprivate extension ChatViewController {
    func setupMessageInputView() {
        messageTextView.inputAccessoryView = messageInputView
    }
}

// MARK: - Table View Cell
class MessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    
    func configure(withMessage message: Message) {
        label.text = message.text
    }
}


