//
//  TextCell.swift
//  Unredactor
//
//  Created by tyler on 7/17/19.
//  Copyright © 2019 tyler. All rights reserved.
//

import UIKit

class DocumentCell: UITableViewCell {
    
    var document: Document?
    
    @IBOutlet weak var documentLabel: UILabel!
    @IBOutlet weak var unredactButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setupTapGestureRecognizer()
    }
    
    // Creates a tap gesture recognizer for the document label
    func setupTapGestureRecognizer() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DocumentCell.documentLabelTapped(_:)))
        gestureRecognizer.delegate = self
        documentLabel.addGestureRecognizer(gestureRecognizer)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(withDocument document: Document) {
        self.document = document
        documentLabel.attributedText = document.attributedText
        
        // Any other setup here
    }
    
    @IBAction func unredactButtonPressed(_ sender: UIButton) {
        guard let document = document else { return }
        
        if document.isRedacted {
            sender.setTitle("Revert", for: .normal)
            
            sender.isEnabled = false
            
            print("starting unredaction")
            document.unredact(completion: {
                print("ending unredaction")
                
                DispatchQueue.main.async { // TODO: Make the button wait for the server request to finish
                    self.documentLabel.attributedText = document.attributedText
                    sender.isEnabled = true
                }
            })
        } else if document.isUnredacted {
            for word in document.classifiedText.words {
                if word.redactionState != .notRedacted {
                    word.redactionState = word.lastRedactionState ?? .notRedacted // Still remembers the earlier prediction and the last redaction state
                }
            }
            
            sender.isEnabled = true
            sender.setTitle("Unredact", for: .normal)
            
            
            documentLabel.attributedText = document.attributedText
        } else { // Document is not redacted
            print("Document is not redactd, so unredact() does nothing. TODO: Implement a animation implying that you can't redact a document that isn't redacted (maybe shaking back and forth?)")
        }
        
        
        
        print("UnredactButtonPressed")
    }
    
    
    @objc func documentLabelTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let document = document else {
            print("Document in documentCell found nil. Look in documentLabelTapped(_:)")
            
            return
        }
        
        let characterIndexTapped = gestureRecognizer.characterIndexTapped()
        
        // Make the tapped word redact or unredact (literally, not with the model)
        document.classifiedText.wordForCharacterIndex(characterIndexTapped)?.toggleRedactionState() // Goes back and forth between .notRedacted and .isRedacted or .notRedacted and .unredacted
        
        // TODO: Update documentLabel
        documentLabel.attributedText = document.attributedText
        
        // Make sure the button reflects the state of the cell
        if document.isUnredacted {
            unredactButton.setTitle("Revert", for: .normal)
        } else {
            unredactButton.isEnabled = true
            unredactButton.setTitle("Unredact", for: .normal)
        }
    }
}
