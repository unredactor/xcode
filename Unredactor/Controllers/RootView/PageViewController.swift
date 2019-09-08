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
    var currentIndex: Int = 0
    
    private var pages = [UIViewController]()
    var documents: [Document] = [Document(withText: "", unredactor: Unredactor()), Document(withText: "", unredactor: Unredactor())]
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        //self.delegate = self
        //self.dataSource = self
        
        
        let unredactor: DocumentViewController! = storyboard?.instantiateViewController(withIdentifier: "unredactorView2") as? DocumentViewController // TODO: Update names
        //let chatbot: ChatViewController! = storyboard?.instantiateViewController(withIdentifier: "chatbot") as? ChatViewController
        let about: AboutPageViewController! = storyboard?.instantiateViewController(withIdentifier: "About") as? AboutPageViewController
        let contributors: ContributorsPageViewController! = storyboard?.instantiateViewController(withIdentifier: "Contributors") as? ContributorsPageViewController
        let website: UnredactorWebsiteViewController! = storyboard?.instantiateViewController(withIdentifier: "Website") as? UnredactorWebsiteViewController
        let manceps: MancepsWebsiteViewController! = storyboard?.instantiateViewController(withIdentifier: "Manceps") as? MancepsWebsiteViewController
        
        unredactor.document = documents[0]
        //page2.document = documents[1]
        
        pages.append(contentsOf: [unredactor, website, manceps])
        
        setViewControllers([unredactor], direction: .forward, animated: false, completion: nil)
    }
    
    // MARK: - Interface (public functions)
    func dismissKeyboardOfCurrentPage() {
        if let currentPage = pages[currentIndex] as? DocumentViewController {
            currentPage.dismissKeyboard()
        } else if let currentPage = pages[currentIndex] as? ChatViewController {
            currentPage.dismissKeyboard()
        }
    }
    
    func setCurrentPageFirstResponder() {
        if let currentPage = pages[currentIndex] as? ScrollDocumentViewController {
            currentPage.becomeFirstResponder()
        }
    }
    
    func setCurrentPageUserInteractionEnabled(to isUserInteractionEnabled: Bool) {
        if let currentPage = pages[currentIndex] as? ScrollDocumentViewController {
            currentPage.isTextViewInteractionEnabled = isUserInteractionEnabled
        }
    }
    
    func flipToPage(atIndex index: Int) {
        var direction: UIPageViewController.NavigationDirection
        if index > currentIndex {
            direction = .forward
        } else if index < currentIndex {
            direction = .reverse
        } else {
            return
        }
        
        currentIndex = index
        setViewControllers([pages[currentIndex]], direction: direction, animated: true, completion: nil)
    }
}

/*
// MARK: - UIPageViewControllerDataSource, UIPageViewControllerDelegate
extension PageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if currentIndex <= 0 {
            return nil
        } else {
            currentIndex -= 1
            return pages[currentIndex]
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if currentIndex >= pages.count - 1 {
            return nil
        } else {
            currentIndex += 1
            return pages[currentIndex]
        }
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pages.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}
*/
