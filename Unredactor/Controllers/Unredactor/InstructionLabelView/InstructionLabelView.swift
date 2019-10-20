//
//  InstructionLabelView.swift
//  Unredactor
//
//  Created by Tyler Gee on 10/19/19.
//  Copyright © 2019 tyler. All rights reserved.
//

import UIKit

class InstructionLabelView: UIView {

    // MARK: - Subviews
    
    
    // Use to initialize from code
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    // Use to intialize from xib or storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(code: aDecoder)
        setupView()
    }

}

// MARK: - Helper Functions
fileprivate extension InstructionLabelView {
    // The common iinit. Setup subviews, properties, constraints, etc.
    func setupView() {
        addSubviews()
        addConstraints()
    }
    
    func addSubviews() {
        
    }
}
