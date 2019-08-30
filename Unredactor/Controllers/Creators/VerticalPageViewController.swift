//
//  VerticalPageViewController.swift
//  Unredactor
//
//  Created by Tyler Gee on 8/28/19.
//  Copyright © 2019 tyler. All rights reserved.
//

import UIKit

class VerticalPageViewController: UIPageViewController {
    
    fileprivate var pages = [UIViewController]()
    //var currentIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        let contributors: ContributorsViewController! = storyboard?.instantiateViewController(withIdentifier: "Contributors") as? ContributorsViewController // TODO: Update names\
        contributors.delegate = self
        
        let tylerViewController: UIViewController! = storyboard?.instantiateViewController(withIdentifier: "Tyler")
        let julianViewController: UIViewController! = storyboard?.instantiateViewController(withIdentifier: "Julian")
        let hopeViewController: UIViewController! = storyboard?.instantiateViewController(withIdentifier: "Hope")
        let alexViewController: UIViewController! = storyboard?.instantiateViewController(withIdentifier: "Alex")
        
        pages = [contributors, tylerViewController, julianViewController, hopeViewController, alexViewController]
        
        setViewControllers([contributors], direction: .forward, animated: false, completion: nil)
        
        dataSource = self
        delegate = self
    }

}

// MARK: - UIPageViewControllerDataSource, UIPageViewControllerDelegate
extension VerticalPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController) else { return nil }
        
        if currentIndex <= 0 {
            return nil
        } else {
            print("CurrentIndex: \(currentIndex)")
            return pages[currentIndex - 1]
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController) else { return nil }
        
        if currentIndex >= pages.count - 1 {
            return nil
        } else {
            print("CurrentIndex: \(currentIndex)")
            return pages[currentIndex + 1]
        }
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pages.count
    }
    
    /// Flips a number of pages forward from the first page. Always animated. Set current page to numberOfPages to begin with.
    func flipPages(numberOfPages: Int, currentPage: Int = 0) {
        guard currentPage < numberOfPages else { return }
        
        DispatchQueue.main.async { [unowned self] in
            self.setViewControllers([self.pages[currentPage + 1]], direction: .forward, animated: true) { [unowned self] _ in
                self.flipPages(numberOfPages: numberOfPages, currentPage: currentPage + 1)
            }
        }
    }
}

extension VerticalPageViewController: ContributorsTableViewControllerDelegate {
    func didSelectRow(_ row: Int) {
        print("row: \(row)")
        
        guard row < pages.count - 1 else { return }
        self.flipPages(numberOfPages: row + 1)
        
        // Direction is always .forward because you can only select row on the first page
    }
}


