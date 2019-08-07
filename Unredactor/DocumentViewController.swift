//
//  ViewController.swift
//  Unredactor
//
//  Created by tyler on 7/15/19.
//  Copyright © 2019 tyler. All rights reserved.
//

import UIKit
import Foundation


class DocumentTableViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    //@IBOutlet weak var textView: UITextView!
    
    // MARK: - IBOutlets
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var enterDocumentButton: UIButton!
    @IBOutlet weak var documentTableView: UITableView!
    
    @IBOutlet weak var containerView: UIView!
    
    // MARK: - Variables
    var documents: [Document] = []
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    var unredactor = Unredactor() // Set mask token to unk because this is what it is rn on the website
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Do any additional setup after loading the view, typically from a nib.
        textField.delegate = self
        
        //documentTableView.keyboardDismissMode = .interactive
        
        setupInputComponents()
        setupKeyboardObservers()
    }
    
    /*
    lazy var inputContainerView: UIView = {
        
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = UIColor.white
        
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.addTarget(self, action: #selector(sendButtonPressed), for: .touchUpInside)
        containerView.addSubview(sendButton)
        
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80.0).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        
        let textField = UITextField()
        textField.placeholder = "Enter some text"
        containerView.addSubview(textField)
        textField.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.addSubview(textField)
        
        textField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        textField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        textField.rightAnchor.constraint(equalTo:sendButton.leftAnchor).isActive = true
        textField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        textField.delegate = self
        
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor(white: 220.0/255.0, alpha: 1.0)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)
        
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        return containerView
    }()
 */
    
    @objc func sendButtonPressed() {
        textFieldDidEndEditing()
    }
    
    /*
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
 */
    
    func setupInputComponents() {
        // Most is already defined in the storyboard
        // We just want to change one so it goes with the keyboard
        
        containerViewBottomAnchor = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        containerViewBottomAnchor?.isActive = true
    }
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        // Move input area up somehow
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @objc func handleKeyboardWillShow(notification: NSNotification) {
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        
        containerViewBottomAnchor?.constant = -keyboardFrame!.height
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func handleKeyboardWillHide(notification: NSNotification) {
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        containerViewBottomAnchor?.constant = 0
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func enterButtonPressed(_ sender: Any) {
        textFieldDidEndEditing()
    }
    
}

extension DocumentTableViewController: UITextFieldDelegate {
    /*
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
    }
 */
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textFieldDidEndEditing()
        
        return true
    }
    
    func textFieldDidEndEditing() {
        textField.resignFirstResponder()
        
        let text = textField.text ?? ""
        addNewDocument(withText: text)
        
        textField.text = ""
    }
    
    func addNewDocument(withText text: String) {
        guard !text.isEmpty else { return }
        
        let newDocument = Document(withText: textField.text!, unredactor: unredactor)
        
        documents.append(newDocument)
        documentTableView.reloadData()
    }
}

extension DocumentTableViewController: UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = documentTableView.dequeueReusableCell(withIdentifier: "documentCell") as! DocumentCell
        
        let document = documents[indexPath.row]
        
        
        cell.configure(withDocument: document)
        
        return cell
    }
}

extension DocumentTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
}

