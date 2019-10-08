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
    func pressed(sender: ButtonViewController)
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
    @IBOutlet weak var button: UIButton!
    
    weak var delegate: ButtonViewControllerDelegate?
    
    private let backgroundColor = UIColor.white.withAlphaComponent(0.8)
    private let imageViewTintColor = UIColor.white.withAlphaComponent(0.4)
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func pressed() {
        delegate?.pressed(sender: self)
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

// LoadingButtonViewController subclass
// This adds a loading screen and assumes that the button action takes time and requires feedback
class LoadingButtonViewController: ButtonViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.alpha = 0.0
        imageView.alpha = 1.0
    }
    
    override func pressed() {
        super.pressed()
    }
    
    func disable() {
        UIView.animate(withDuration: 0.15) { [ unowned self] in
                self.tintView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        }
        
        button.isEnabled = false
    }
    
    func enable() {
        UIView.animate(withDuration: 0.15) { [ unowned self] in
                self.tintView.backgroundColor = UIColor.white.withAlphaComponent(0.0)
        }
        
        button.isEnabled = true
    }
    
    func actionBegan() {
        
        DispatchQueue.main.async { [unowned self] in
            // Show activity indicator in center and hide the image view
            UIView.animate(withDuration: 0.2) { [unowned self] in
                self.activityIndicator.alpha = 1.0
                self.imageView.alpha = 0.0
            }
               
            self.activityIndicator.startAnimating()
        }
    }
    
    func actionFinished() {
        DispatchQueue.main.async { [unowned self] in
            UIView.animate(withDuration: 0.2) { [unowned self] in
                self.activityIndicator.alpha = 0.0
                self.imageView.alpha = 1.0
            }
            
            self.activityIndicator.stopAnimating()
        }
    }
    
    func animateAlpha(to alpha: CGFloat, duration: TimeInterval) {
        UIView.animate(withDuration: duration) { [unowned self] in
            self.view.alpha = alpha
        }
    }
}
