//
//  AboutViewController.swift
//  Unredactor
//
//  Created by Tyler Gee on 5/20/20.
//  Copyright © 2020 tyler. All rights reserved.
//

import UIKit

class AboutViewController: ScrollViewController {

    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setAttributedText()
        textView.isUserInteractionEnabled = true
        textView.isEditable = false
        textView.isSelectable = false
        
        // Set up the tap gesture
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedTextView(tapGesture:)))
        textView.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func tappedTextView(tapGesture: UIGestureRecognizer) {

        let textView = tapGesture.view as! UITextView
        let tapLocation = tapGesture.location(in: textView)
        guard let textPosition = textView.closestPosition(to: tapLocation) else { return }
        let attr: NSDictionary = textView.textStyling(at: textPosition, in: UITextStorageDirection.forward)! as NSDictionary
        
        
        

        if let url: NSURL = attr[NSAttributedString.Key.link] as? NSURL {
            // Add a responsive animation to clarify which website you went to
            // Figure out which word you picked
            
            
            UIApplication.shared.open(url as URL)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func setAttributedText() {
        let attributedText = NSMutableAttributedString(string: "Unredactor is a Manceps experiment. It was created by our Summer Interns, class of 2019. Manceps makes it easy for enterprise organizations to deploy AI models that put their data to work.\n\nVisit our website.\n\nGet notified of future internship opportunities.")
        
        let websiteURL = URL(string: "https://www.manceps.com/?utm_source=Unredactor&utm_medium=App")!
        let internshipOpportunitiesURL = URL(string: "https://www.manceps.com/careers?utm_source=Unredactor&utm_medium=App#r197")!
        
        let websiteRange = NSRange(location: 200, length: 7)
        if #available(iOS 13.0, *) {
            attributedText.addAttributes([.link: websiteURL, .underlineStyle: 1, .foregroundColor: UIColor.link], range: websiteRange)
        } else {
            attributedText.addAttributes([.link: websiteURL, .underlineStyle: 1, .foregroundColor: UIColor.blue], range: websiteRange)
        }
        
        let internshipOpportunitiesRange = NSRange(location: 232, length: 25)
        if #available(iOS 13.0, *) {
            attributedText.addAttributes([.link: internshipOpportunitiesURL, .underlineStyle: 1, .foregroundColor: UIColor.link], range: internshipOpportunitiesRange)
        } else {
            attributedText.addAttributes([.link: internshipOpportunitiesURL, .underlineStyle: 1, .foregroundColor: UIColor.blue], range: internshipOpportunitiesRange)
        }
        
        attributedText.addAttributes([.font: UIFont(name: "Courier", size: 16)!], range: NSRange(location: 0, length: attributedText.length))
        
        textView.attributedText = attributedText
    }
}
