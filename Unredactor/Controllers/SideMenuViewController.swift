//
//  SideMenuViewController.swift
//  Unredactor
//
//  Created by Tyler Gee on 8/12/19.
//  Copyright © 2019 tyler. All rights reserved.
//

import UIKit

class SideMenuViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var tintImageView: UIImageView!
    @IBOutlet weak var fileIconImageView: UIImageView!
    
    
    
    var lastDarkLayerOpacity: CGFloat?
    let textColor: UIColor = .black
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTintImageView()
        setupFileIconImageView()
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
        
        print("OPACITY: \(opacity)")
        
        let darkLayerOpacityAnimation = CABasicAnimation(keyPath: "opacity", toValue: opacity, fromValue: lastDarkLayerOpacity, duration: duration)
        lastDarkLayerOpacity = opacity
        
        tintImageView.layer.add(darkLayerOpacityAnimation, forKey: "darkLayerOpacity")
    }
}

// MARK: - Helper Functions
extension SideMenuViewController {
    func setupTintImageView() {
        tintImageView.tintColor = .white
        tintImageView.image = tintImageView.image?.withRenderingMode(.alwaysTemplate)
    }
    
    func setupFileIconImageView() {
        fileIconImageView.tintColor = UIColor.black.withAlphaComponent(0.4)
        fileIconImageView.image = fileIconImageView.image?.withRenderingMode(.alwaysTemplate)
    }
    
    
}
