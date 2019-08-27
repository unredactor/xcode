//
//  DocumentViewController.swift
//  Unredactor
//
//  Created by Tyler Gee on 8/12/19.
//  Copyright © 2019 tyler. All rights reserved.
//

import Foundation
import UIKit

protocol DocumentViewController: UIViewController {
    var document: Document! { get set }
    
    func dismissKeyboard()
}

// random change
