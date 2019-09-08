//
//  VerticalPageViewController.swift
//  Unredactor
//
//  Created by Tyler Gee on 8/28/19.
//  Copyright © 2019 tyler. All rights reserved.
//

import UIKit

class InformationPageViewController: UIPageViewController {
    
    fileprivate var pages = [UIViewController]()

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let summaryViewController as SummaryViewController:
            summaryViewController.delegate = self
        default:
            break
        }
    }
}

// MARK: - UIPageViewControllerDataSource, UIPageViewControllerDelegate
extension InformationPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
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

extension InformationPageViewController: SummaryTableViewControllerDelegate {
    func didSelectRow(_ row: Int) {
        print("row: \(row)")
        
        guard row < pages.count - 1 else { return }
        self.flipPages(numberOfPages: row + 1)
        
        // Direction is always .forward because you can only select row on the first page
    }
}

class ContributorsPageViewController: InformationPageViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let contributors: SummaryViewController! = storyboard?.instantiateViewController(withIdentifier: "ContributorsInfo") as? SummaryViewController
        contributors.delegate = self
        
        let tylerViewController: UIViewController! = storyboard?.instantiateViewController(withIdentifier: "Tyler")
        let julianViewController: UIViewController! = storyboard?.instantiateViewController(withIdentifier: "Julian")
        let hopeViewController: UIViewController! = storyboard?.instantiateViewController(withIdentifier: "Hope")
        let alexViewController: UIViewController! = storyboard?.instantiateViewController(withIdentifier: "Alex")
        
        pages = [contributors, tylerViewController, julianViewController, hopeViewController, alexViewController]
        
        setViewControllers([contributors], direction: .forward, animated: false, completion: nil)
    }
}

class AboutPageViewController: InformationPageViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let about: SummaryViewController! = storyboard?.instantiateViewController(withIdentifier: "AboutInfo") as? SummaryViewController
        let unredactorInfo: UIViewController! = storyboard?.instantiateViewController(withIdentifier: "UnredactorInfo")
        let iOS: UIViewController! = storyboard?.instantiateViewController(withIdentifier: "iOS")
        let flask: UIViewController! = storyboard?.instantiateViewController(withIdentifier: "Flask")
        let website: UIViewController! = storyboard?.instantiateViewController(withIdentifier: "WebsiteInfo")
        
        pages = [about, unredactorInfo, iOS, flask, website]
        
        setViewControllers([about], direction: .forward, animated: false, completion: nil)
        
        about.delegate = self
    }
}



