//
//  DocumentViewController.swift
//  Unredactor
//
//  Created by Tyler Gee on 8/2/19.
//  Copyright © 2019 tyler. All rights reserved.
//

import UIKit

class DocumentViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    var document: Document = Document(withText: "", unredactor: Unredactor())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.delegate = self
    }
}

extension DocumentViewController: UITextViewDelegate {
    
    func textViewShouldReturn(_ textField: UITextField) -> Bool {
        textViewDidEndEditing()
        
        return true
    }
    
    func textViewDidEndEditing() {
        textView.resignFirstResponder()
        
        self.document.setText(to: textView.text!)
    }
}
