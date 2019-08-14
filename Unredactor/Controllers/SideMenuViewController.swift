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
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImageView()
    }
    
    
    // MARK: - Interface (public functions)
    func animateDarken(withDuration duration: TimeInterval) {
        let darkenAnimation = CABasicAnimation(keyPath: "opacity", toValue: 0.4, fromValue: 0.0, duration: duration)
        darkenAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        
        tintImageView.layer.add(darkenAnimation, forKey: "darkenAnimation")
    }
    
    func animateLighten(withDuration duration: TimeInterval) {
        let lightenAnimation = CABasicAnimation(keyPath: "opacity", toValue: 0.0, fromValue: 0.4, duration: duration)
        lightenAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        
        tintImageView.layer.add(lightenAnimation, forKey: "lightenAnimation")
    }

}

// MARK: - Helper Functions
extension SideMenuViewController {
    func setupImageView() {
        tintImageView.tintColor = .black
        tintImageView.image = tintImageView.image?.withRenderingMode(.alwaysTemplate)
    }
}
