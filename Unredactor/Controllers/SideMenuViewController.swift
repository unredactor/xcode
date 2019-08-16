//
//  SideMenuViewController.swift
//  Unredactor
//
//  Created by Tyler Gee on 8/12/19.
//  Copyright © 2019 tyler. All rights reserved.
//

import UIKit

// MARK: - Delegate
protocol SideMenuViewControllerDelegate: class {
    func menuButtonPressed()
    func panGestureRecognizerValueChanged(gestureRecognizer: UIPanGestureRecognizer)
    func didSelectRow(_ row: Int)
}

// MARK: - View Definition
/**
 SideMenuViewController manages a sideMenuView, which is stylized to look like a folder. It presents a static table view controller that the user can use to navigate throughout the app.
*/
class SideMenuViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var tintImageView: UIImageView!
    @IBOutlet weak var fileIconImageView: UIImageView!
    @IBOutlet weak var menuButtonView: UIView!
    
    var lastDarkLayerOpacity: CGFloat?
    
    weak var delegate: SideMenuViewControllerDelegate?
    
    let textColor: UIColor = .black
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTintImageView()
        setupFileIconImageView()
        setupPanGestureRecognizer()
        setupMenuButtonView()
    }
    
    //MARK: - IBActions
    @IBAction func menuButtonPressed(_ sender: Any) {
        delegate?.menuButtonPressed()
    }
    
    // MARK: - Interface (public functions)
    func animateDarken(withDuration duration: TimeInterval) {
        let darkenAnimation = CABasicAnimation(keyPath: "opacity", toValue: 0.0, fromValue: lastDarkLayerOpacity, duration: duration)
        darkenAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        
        tintImageView.layer.add(darkenAnimation, forKey: "darkenAnimation")
    }
    
    func animateLighten(withDuration duration: TimeInterval) {
        let lightenAnimation = CABasicAnimation(keyPath: "opacity", toValue: 0.3, fromValue: lastDarkLayerOpacity, duration: duration)
        lightenAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        
        tintImageView.layer.add(lightenAnimation, forKey: "lightenAnimation")
    }
    
    func updateDarkLayer(percentageDone: CGFloat, duration: TimeInterval = 0.0, menuIsShown: Bool) {
        var opacity: CGFloat
        
        let maxOpacity: CGFloat = 0.3
        let fudgeFactor: CGFloat = 1.5
        
        if menuIsShown {
            opacity = maxOpacity * (-1 * percentageDone) * fudgeFactor
        } else {
            opacity = maxOpacity * (0.6 - percentageDone) * fudgeFactor
        }
        if opacity > maxOpacity { opacity = 0.2 }
        
        let darkLayerOpacityAnimation = CABasicAnimation(keyPath: "opacity", toValue: opacity, fromValue: lastDarkLayerOpacity, duration: duration)
        lastDarkLayerOpacity = opacity
        
        tintImageView.layer.add(darkLayerOpacityAnimation, forKey: "darkLayerOpacity")
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let sideMenuTableViewController as SideMenuTableViewController:
            sideMenuTableViewController.delegate = self
        default:
            break
        }
    }
}

// MARK: - SideMenuTableViewControllerDelegate
extension SideMenuViewController: SideMenuTableViewControllerDelegate {
    func didSelectRow(_ row: Int) {
        delegate?.didSelectRow(row)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension SideMenuViewController: UIGestureRecognizerDelegate {
    @objc func panGestureDragged(_ gestureRecognizer: UIPanGestureRecognizer) {
        delegate?.panGestureRecognizerValueChanged(gestureRecognizer: gestureRecognizer)
    }
}


// MARK: - Helper Functions
fileprivate extension SideMenuViewController {
    func setupTintImageView() {
        tintImageView.tintColor = .white
        tintImageView.image = tintImageView.image?.withRenderingMode(.alwaysTemplate)
    }
    
    func setupFileIconImageView() {
        fileIconImageView.tintColor = UIColor.black.withAlphaComponent(0.4)
        fileIconImageView.image = fileIconImageView.image?.withRenderingMode(.alwaysTemplate)
    }
    
    func setupMenuButtonView() {
        // Round corners
        menuButtonView.layer.cornerRadius = 15
        menuButtonView.clipsToBounds = true
        
        // Make transclucent and blurry
        menuButtonView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        menuButtonView.insertSubview(blurView, at: 0)
        
        // Align blurView with view
        NSLayoutConstraint.activate([
            blurView.heightAnchor.constraint(equalTo: menuButtonView.heightAnchor),
            blurView.widthAnchor.constraint(equalTo: menuButtonView.widthAnchor)
            ])
        
        // Make image view transparent
        fileIconImageView.image = fileIconImageView.image?.withRenderingMode(.alwaysTemplate)
        fileIconImageView.tintColor = UIColor.white.withAlphaComponent(0.4)
    }
    
    func setupPanGestureRecognizer() {
        // Add pan gesture recognizer
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureDragged(_:)))
        view.addGestureRecognizer(panGestureRecognizer)
        panGestureRecognizer.delegate = self
    }
}
