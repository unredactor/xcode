//
//  ContainerViewController.swift
//  Unredactor
//
//  Created by Tyler Gee on 8/5/19.
//  Copyright © 2019 tyler. All rights reserved.
//

import UIKit


// Manages the top level of views, including the background, the file menu, and the pageViewController
class FolderViewController: UIViewController {
    
    var documents: [Document] = []
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
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
