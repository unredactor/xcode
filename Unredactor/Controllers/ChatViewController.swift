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
    
    var messages: [Message] = [Message(withText: "This is a long test message to try to find bugs in the program", fromSender: .user), Message(withText: "hi", fromSender: .chatbot)]
    let chatbot = Chatbot()

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMessageInputView()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
    }
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        let newMessage = Message(withText: messageTextView.text, fromSender: .user)
        
        messages.append(newMessage)
        
        let lastIndexPath = IndexPath(row: messages.count - 1, section: 0)
        
        tableView.insertRows(at: [lastIndexPath], with: .automatic)
        tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
        
        //Insert a row at the end of the table view
        
        // Reply
        chatbot.reply(toMessage: newMessage) { [unowned self] (replyMessage: Message) in
            self.messages.append(replyMessage)
            
            let lastIndexPath = IndexPath(row: self.messages.count - 1, section: 0)
            self.tableView.insertRows(at: [lastIndexPath], with: .automatic)
            self.tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
        }
    }
}

// MARK: - Table View Data Source & Delegate
extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print("Message Number: \(messages.count)")
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        print("Sender: \(message.sender)" )
        
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
        let maximumMessageWidth: CGFloat = 200
        let size = CGSize(width: maximumMessageWidth, height: CGFloat.greatestFiniteMagnitude)
        let options = NSStringDrawingOptions.usesLineFragmentOrigin
        let estimatedFrame = NSString(string: message.text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont(name: "Courier", size: 17)!], context: nil)
        
        return estimatedFrame.height + 32
    }
}

// MARK: - Helper Methods
fileprivate extension ChatViewController {
    func setupMessageInputView() {
        //messageInputView.removeFromSuperview()
        //messageTextView.inputAccessoryView = messageInputView
    }
}

// MARK: - Table View Cell
class MessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var bubbleView: UIView!
    
    
    func configure(withMessage message: Message) {
        label.text = message.text
    }
    
    override func awakeFromNib() {
        // Make the bubbles rounded
        bubbleView.layer.cornerRadius = 4
        bubbleView.layer.masksToBounds = true
    }
}


