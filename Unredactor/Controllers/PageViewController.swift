//
//  UIPageViewController.swift
//  Unredactor
//
//  Created by Tyler Gee on 7/31/19.
//  Copyright © 2019 tyler. All rights reserved.
//

import UIKit

// MARK: - Class Definition
/**
 PageViewController manages a PageView and stores its pages [DocumentViewController], which it instantiates directly
 from storyboard. It has built in page flipping logic, which doesn't loop (you can't keep flipping a particular
 direction forever). It also stores the documents of its pages in an array, which it gets instantiated from FolderViewController.
*/
class PageViewController: UIPageViewController {
    
    // MARK: - Properties
    var pages = [DocumentViewController]()
    var documents: [Document] = []
    
    // MARK: - View Life Cycle
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
}

// MARK: - UIPageViewControllerDataSource, UIPageViewControllerDelegate
extension PageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
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
}
