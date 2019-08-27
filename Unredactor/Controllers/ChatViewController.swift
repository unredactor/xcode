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
    @IBOutlet weak private var tableView: UITableView!
    
    @IBOutlet weak private var messageInputView: UIView!
    @IBOutlet weak private var messageTextField: UITextField!
    
    var messages: [Message] = [Message(withText: "This is a long test message to try to find bugs in the program", fromSender: .user), Message(withText: "hi", fromSender: .chatbot)]
    let chatbot = Chatbot()
    
    var bottomConstraint: NSLayoutConstraint?

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        
        bottomConstraint = NSLayoutConstraint(item: messageInputView!, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        
        view.addConstraint(bottomConstraint!)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        messageTextField.becomeFirstResponder()
    }
    
    // MARK: - IBActions
    @IBAction func sendButtonPressed(_ sender: Any) {
        let newMessage = Message(withText: messageTextField.text!, fromSender: .user)
        
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
    
    // MARK: - Interface (public functions)
    func dismissKeyboard() {
        messageTextField.resignFirstResponder()
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
        
        var identifier: String
        if message.sender == .user { identifier = "userMessage" }
        else { identifier = "chatbotMessage" }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as! MessageTableViewCell
        cell.configure(withMessage: message)
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        messageTextField.endEditing(true)
    }
}

// MARK: - Helper Methods
fileprivate extension ChatViewController {
    @objc func handleKeyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
            
            let isKeyboardShowing = (notification.name == UIResponder.keyboardWillShowNotification)
            
            bottomConstraint?.constant = isKeyboardShowing ? -keyboardFrame.height : 0
            
            UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: { [unowned self] (completed) in
                let lastIndexPath = IndexPath(row: self.messages.count - 1, section: 0)
                self.tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
            })
        }
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
        bubbleView.layer.masksToBounds = false
        bubbleView.layer.shadowOffset = CGSize(width: 2, height: 2)
        bubbleView.layer.shadowOpacity = 0.1
        bubbleView.layer.shadowRadius = 2
        
        label.text = "test"
    }
}


