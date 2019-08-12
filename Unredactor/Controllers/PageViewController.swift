//
//  UIPageViewController.swift
//  Unredactor
//
//  Created by Tyler Gee on 7/31/19.
//  Copyright © 2019 tyler. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var pages = [DocumentViewController]()
    var documents: [Document] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
        self.dataSource = self
        
        let page1: DocumentViewController! = storyboard?.instantiateViewController(withIdentifier: "unredactorView") as? DocumentViewController // TODO: Update names
        let page2: DocumentViewController! = storyboard?.instantiateViewController(withIdentifier: "unredactorView2") as? DocumentViewController
        
        page1.document = documents[0]
        page2.document = documents[1]
        
        pages.append(page1)
        pages.append(page2)
        
        setViewControllers([page1], direction: .forward, animated: false, completion: nil)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let currentIndex = pages.index(of: viewController as! DocumentViewController)!
        
        guard currentIndex != 0 else { return nil } // Make sure it isn't the first page
        
        let previousIndex = abs((currentIndex - 1) % pages.count)
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let currentIndex = pages.index(of: viewController as! DocumentViewController)!
        
        guard currentIndex != self.pages.count - 1 else { return nil } // Make sure it isn't the last page
        
        let nextIndex = abs((currentIndex + 1) % pages.count)
        return pages[nextIndex]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pages.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
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
