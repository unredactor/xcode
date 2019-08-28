//
//  VerticalPageViewController.swift
//  Unredactor
//
//  Created by Tyler Gee on 8/28/19.
//  Copyright © 2019 tyler. All rights reserved.
//

import UIKit

class VerticalPageViewController: UIPageViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let creators: UIViewController! = storyboard?.instantiateViewController(withIdentifier: "unredactorView2") as? DocumentViewController // TODO: Update names
        //let chatbot: ChatViewController! = storyboard?.instantiateViewController(withIdentifier: "chatbot") as? ChatViewController
        let about: ScrollViewController! = storyboard?.instantiateViewController(withIdentifier: "About") as? ScrollViewController
        //let creators: ScrollViewController! = storyboard?.instantiateViewController(withIdentifier: "Creators") as? ScrollViewController
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
