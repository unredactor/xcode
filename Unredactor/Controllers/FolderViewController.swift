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
    var documents: [Document] = []
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let pageViewController as PageViewController:
            pageViewController.documents = documents
        default:
            break
        }
    }

}
