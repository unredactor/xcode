//
//  ContainerViewController.swift
//  Unredactor
//
//  Created by Tyler Gee on 8/5/19.
//  Copyright © 2019 tyler. All rights reserved.
//

import UIKit

// MARK: - Class Definition
/**
 FolderViewController manages the highest level of views, including the background, folder side menu, and PageViewController.
 It stores an array of documents, which it gets instantiated directly from AppDelegate at runtime.
*/
class FolderViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var pageView: UIView!
    @IBOutlet weak var sideMenu: UIView!
    
    var sideMenuViewController: SideMenuViewController!
    
    var documents: [Document] = []
    
    var menuIsShown: Bool = false
    
    private let animationDuration: TimeInterval = 0.6
    private let transformIdentity = CATransform3DIdentity
    /// The shadow offset of the folder side when the folder is out of view and up
    private let shadowOffsetBeginning: CGSize = CGSize(width: 190.0, height: 0)
    /// The shadow offset of the folder while it is in between being shown and hidden
    //private let shadowOffsetMiddle: CGSize = CGSize(width: 10000.0, height: 0)
    /// The shadow offset of the folder side menu when the folder is visible and down
    private let shadowOffsetEnd: CGSize = CGSize(width: 0.0, height: 0)
    
    private lazy var flipToHideTransform: CATransform3D = {
        return CATransform3DRotate(transformIdentity, -1 * CGFloat.pi / 2, 0, 1, 0)
    }()
    
    private var lastRotateTransform: CATransform3D?
    private var lastShadowOffset: CGSize?
    private var lastShadowGradientOpacity: CGFloat?
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSideMenu()
        setupPanGestureRecognizer()
        updateSideMenu(isAnimated: false)
    }
    
    // MARK: - IBActions
    @IBAction func menuButtonPressed(_ sender: Any) {
        menuIsShown.toggle()
        
        updateSideMenu(isAnimated: true)
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let pageViewController as PageViewController:
            pageViewController.documents = documents
        case let sideMenuViewController as SideMenuViewController:
            self.sideMenuViewController = sideMenuViewController
        default:
            break
        }
    }
}

// MARK: - UIGestureRecognizerDelegate (and relevant helper functions)
extension FolderViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        sideMenu.isHidden = false
        sideMenu.layer.position = CGPoint(x: 0, y: view.frame.height / 2)
        
        guard let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else {
            print("Couldn't cast gestureRecognizer in FolderViewController: UIGestureRecognizerDelegate to UIPanGestureRecgonizer.")
            return true
        }
        
        //updateSideMenuAngle(withTranslation: gestureRecognizer.translation(in: view), gestureRecognizer: gestureRecognizer, duration: 0.2)
        
        return true
    }
    
    @objc private func panGestureDragged(_ gestureRecognizer: UIPanGestureRecognizer) {
        
        let sideMenuWidth = view.frame.width - 60
        let translation = gestureRecognizer.translation(in: view).x
        
        var percentageDone = translation / sideMenuWidth
        if percentageDone > 1 { percentageDone = 1 }
        if percentageDone < -1 { percentageDone = -1 }
        
        // Set all of the values to proper values w/ folder
        updateSideMenuAngle(percentageDone: percentageDone)
        updateSideMenuShadowOffset(percentageDone: percentageDone)
        
        if gestureRecognizer.state == .ended {
            let velocity = gestureRecognizer.velocity(in: view).x
            
            if velocity > 0 && !menuIsShown {
                showSideMenu(duration: TimeInterval(10 / sqrt(velocity)))
                menuIsShown = true
            } else if velocity < 0 {
                hideSideMenu(duration: TimeInterval(10 / sqrt(abs(velocity))))
                menuIsShown = false
            } else {
                menuIsShown ? showSideMenu() : hideSideMenu() // go back to what it was
            }
        }
    }
    
    // MARK: - Pan Gesture Helper Methods
    private func updateSideMenuAngle(percentageDone: CGFloat, duration: TimeInterval = 0.0) {
        
        // Many of these values are arbitrary and only being used because they appear to work
        var angle: CGFloat = -2 * (acos(percentageDone)) + CGFloat.pi / 2
        if menuIsShown { angle += CGFloat.pi / 4 + 0.5 } // + fudge factor
        
        // bound angle
        if angle > 0 { angle = 0 }
        
        let rotateTransform = CATransform3DRotate(transformIdentity, angle, 0, 1, 0)
        let rotateAnimation = CABasicAnimation(keyPath: "transform", toValue: rotateTransform, fromValue: lastRotateTransform, duration: duration)
        lastRotateTransform = rotateTransform
        
        sideMenu.layer.add(rotateAnimation, forKey: "rotate")
    }
    
    private func updateSideMenuShadowOffset(percentageDone: CGFloat, duration: TimeInterval = 0.0) {
        var shadowOffset: CGSize
        
        let fudgeFactor: CGFloat = 1.5
        
        if menuIsShown {
            shadowOffset = CGSize(width: shadowOffsetBeginning.width * (-1 * percentageDone) * fudgeFactor, height: 0)
        } else {
            shadowOffset = CGSize(width: shadowOffsetBeginning.width * (1 - percentageDone) * fudgeFactor, height: 0)
        }
        
        print("Shadow Offset: \(shadowOffset)")
        
        let shadowOffsetAnimation = CABasicAnimation(keyPath: "shadowOffset", toValue: shadowOffset, fromValue: lastShadowOffset, duration: duration)
        lastShadowOffset = shadowOffset
        
        sideMenu.layer.add(shadowOffsetAnimation, forKey: "shadowOffset")
    }
    
    private func updateSideMenuShadowGradient(percentageDone: CGFloat, duration: TimeInterval = 0.0) {
        var opacity: CGFloat
        
        if menuIsShown {
            opacity = -1 * percentageDone
        } else {
            opacity = percentageDone
        }
        
        let shadowGradientOpacityAnimation = CABasicAnimation(keyPath: "opacity", toValue: opacity, fromValue: lastShadowGradientOpacity)
        lastShadowGradientOpacity = opacity
        
        if let sublayer = sideMenu.layer.sublayers?.first {
            sublayer.add(shadowGradientOpacityAnimation, forKey: "shadowGradient")
        }
    }
}

// MARK: - Helper Functions
fileprivate extension FolderViewController {
    
    func setupPanGestureRecognizer() {
        // Add pan gesture recognizer
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureDragged(_:)))
        pageView.addGestureRecognizer(panGestureRecognizer)
        panGestureRecognizer.delegate = self
    }
    
    // Configure the layer to be proper
    func setupSideMenu() {
        setAnchorPoint(to: CGPoint(x: 0, y: 0.5), ofView: sideMenu)
        sideMenu.layer.shadowColor = UIColor.black.cgColor
        sideMenu.layer.position = CGPoint(x: 0, y: view.frame.height / 2)
        sideMenu.layer.shadowRadius = 50
        sideMenu.layer.shadowOpacity = 0.4
        sideMenu.layer.shadowOffset = shadowOffsetBeginning
        sideMenu.isHidden = true
        
        // Create gradient layer
        let color1: UIColor = .clear
        let color2: UIColor = UIColor.black.withAlphaComponent(0.2)
        let shadowGradient = CAGradientLayer()
        shadowGradient.name = "shadowGradient"
        shadowGradient.frame = sideMenu.frame
        shadowGradient.colors = [color2.cgColor, color1.cgColor]
        shadowGradient.startPoint = CGPoint(x: 0, y: 0.5)
        shadowGradient.endPoint = CGPoint(x: 1, y: 0.5)
        shadowGradient.zPosition = 5 // Move in front of side menu
        sideMenu.layer.insertSublayer(shadowGradient, at: 0)
    }
    
    // from: https://stackoverflow.com/questions/1968017/changing-my-calayers-anchorpoint-moves-the-view
    func setAnchorPoint(to anchorPoint: CGPoint, ofView view: UIView) {
        var newPoint = CGPoint(x: view.bounds.size.width * anchorPoint.x,
                               y: view.bounds.size.height * anchorPoint.y)
        
        var oldPoint = CGPoint(x: view.bounds.size.width * view.layer.anchorPoint.x,
                               y: view.bounds.size.height * view.layer.anchorPoint.y)
        
        newPoint = newPoint.applying(view.transform)
        oldPoint = oldPoint.applying(view.transform)
        
        var position = view.layer.position
        position.x -= oldPoint.x
        position.x += newPoint.x
        
        position.y -= oldPoint.y
        position.y += newPoint.y
        
        view.layer.position = position
        view.layer.anchorPoint = anchorPoint
    }
    
    func updateSideMenu(isAnimated animated: Bool = true) {
        if menuIsShown {
            showSideMenu(duration: animationDuration)
        } else {
            hideSideMenu(duration: animationDuration)
        }
    }
    
    func showSideMenu(duration: TimeInterval = 0.0) {
        
        sideMenu.isHidden = false
        
        let flipToShowAnimation = CABasicAnimation(keyPath: "transform", toValue: transformIdentity, fromValue: nil, duration: duration)
        sideMenu.layer.position = CGPoint(x: 0, y: view.frame.height / 2)
        sideMenu.layer.add(flipToShowAnimation, forKey: "showTransform")
        
        let shadowOffsetAnimation = CABasicAnimation(keyPath: "shadowOffset", toValue: shadowOffsetEnd, fromValue: nil, duration: duration)
        sideMenu.layer.add(shadowOffsetAnimation, forKey: "showShadowOffset")
        
        let shadowAnimation = CABasicAnimation(keyPath: "opacity", toValue: 0.0, fromValue: nil, duration: duration)
        if let sublayer = sideMenu.layer.sublayers?.first {
            sublayer.add(shadowAnimation, forKey: "showShadow")
        }
        
        let blurAnimation = CABasicAnimation(keyPath: "shadowRadius", toValue: 15, fromValue: nil, duration: duration)
        sideMenu.layer.add(blurAnimation, forKey: "showBlurAnimation")
        
        sideMenuViewController.animateLighten(withDuration: duration)
        
        sideMenu.isUserInteractionEnabled = true
    }
    
    func hideSideMenu(duration: TimeInterval = 0.0) {
        
        let flipToHideAnimation = CABasicAnimation(keyPath: "transform", toValue: flipToHideTransform, fromValue: nil, duration: duration)
        sideMenu.layer.position = CGPoint(x: 0, y: view.frame.height / 2)
        sideMenu.layer.add(flipToHideAnimation, forKey: "hideTransform")
        
        let shadowOffsetAnimation = CABasicAnimation(keyPath: "shadowOffset", toValue: shadowOffsetBeginning, fromValue: nil, duration: duration)
        sideMenu.layer.add(shadowOffsetAnimation, forKey: "hideShadowOffset")
        
        let shadowAnimation = CABasicAnimation(keyPath: "opacity", toValue: 1.0, fromValue: nil, duration: duration)
        if let sublayer = sideMenu.layer.sublayers?.first {
            sublayer.add(shadowAnimation, forKey: "hideShadow")
        }
 
        let blurAnimation = CABasicAnimation(keyPath: "shadowRadius", toValue: 100, fromValue: nil, duration: duration)
        sideMenu.layer.add(blurAnimation, forKey: "hideBlurAnimation")
        
        // Also darken the side menu
        sideMenuViewController.animateDarken(withDuration: duration)
        
        sideMenu.isUserInteractionEnabled = false
    }
}
