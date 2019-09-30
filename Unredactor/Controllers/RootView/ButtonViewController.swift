//
//  FileButtonViewController.swift
//  Unredactor
//
//  Created by Tyler Gee on 8/17/19.
//  Copyright © 2019 tyler. All rights reserved.
//

import UIKit

// MARK: - Delegate
protocol ButtonViewControllerDelegate: class {
    func pressed()
}

// MARK: - Class Definition
/**
 FileButtonViewController manages a file button - it sets the view up visually, handles animations, and has a delegate to convey the important info (when the button is pressed)
*/
class ButtonViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tintView: UIView!
    
    weak var delegate: ButtonViewControllerDelegate?
    
    private let backgroundColor = UIColor.white.withAlphaComponent(0.8)
    private let imageViewTintColor = UIColor.white.withAlphaComponent(0.4)
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func pressed() {
        delegate?.pressed()
    }
    
    // MARK: - IBActions
    @IBAction func buttonTouchUpInside(_ sender: UIButton) {
        animateButtonNormal()
        pressed()
    }
    
    @IBAction func buttonTouchBegan(_ sender: UIButton) {
        animateButtonHighlighted()
    }
    
    @IBAction func buttonTouchDraggedOutside(_ sender: UIButton) {
        animateButtonNormal()
    }
    
    @IBAction func buttonTouchDraggedInside(_ sender: UIButton) {
        animateButtonHighlighted()
    }
    
    @IBAction func buttonTouchUpOutside(_ sender: UIButton) {
        animateButtonNormal()
    }
    
    @IBAction func touchCanceled(_ sender: UIButton) {
        animateButtonNormal()
    }
}

// MARK: - Helper Functions
fileprivate extension ButtonViewController {
    func setup() {
        // Set background (transparent so rounded corners look rounded even when layered with the other views
        view.backgroundColor = .clear
        backgroundView.backgroundColor = backgroundColor
        tintView.backgroundColor = .clear
        
        // Give rounded corners
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        
        // Make transclucent and blurry
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.insertSubview(blurView, at: 0)
        
        // Align blurView with backgroundView
        NSLayoutConstraint.activate([
            blurView.heightAnchor.constraint(equalTo: backgroundView.heightAnchor),
            blurView.widthAnchor.constraint(equalTo: backgroundView.widthAnchor)
            ])
        
        // Make image view semi-transparent (set to template mode because that lets you set the color)
        imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = imageViewTintColor
    }
    
    func animateButtonNormal() {
        UIView.animate(withDuration: 0.1) { [unowned self] in
            self.tintView.backgroundColor = .clear
        }
    }
    
    func animateButtonHighlighted() {
        UIView.animate(withDuration: 0.1) { [unowned self] in
            self.tintView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        }
    }
}
