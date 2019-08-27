//
//  ScrollViewController.swift
//  Unredactor
//
//  Created by Tyler Gee on 8/16/19.
//  Copyright © 2019 tyler. All rights reserved.
//

import UIKit

// MARK: - Class Definition
/**
 ScrollViewController manages a ScrollView.
*/

class ScrollViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var scrollView: UIScrollView!
    
    // MARK: - View Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupScrollView()
    }
    
    func addShadow(to view: UIView) {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 10
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.scale
    }
}

// MARK: - Helper Functions
fileprivate extension ScrollViewController {
    func setupScrollView() {
        guard let backgroundView = scrollView.subviews.first else {
            print("Setup scroll view unsuccessful; backgroundView not found in subviews as first view")
            return
        }
        
        addShadow(to: backgroundView)
        
        // Set correct content size
        scrollView.contentInset = .zero
    }
}

// random change
