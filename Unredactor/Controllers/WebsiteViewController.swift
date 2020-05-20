//
//  WebsiteViewController.swift
//  Unredactor
//
//  Created by Tyler Gee on 8/21/19.
//  Copyright © 2019 tyler. All rights reserved.
//

import UIKit
import WebKit

class WebsiteViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var urlLabel: UILabel!
    
    var urlString: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupWebView()
        setupActivityView()
        setupURLLabel()
    }
    
    func setupWebView() {
        webView.navigationDelegate = self
        
        let url = URL(string: urlString)!
        webView.load(URLRequest(url: url))
        
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
        toolbarItems = [refresh]
        navigationController?.isToolbarHidden = false // I don't think this actually does anything because I don't think there is a navigation controller
    }
}

// MARK: - WKNavigationDelegate
extension WebsiteViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
        title = webView.title
        
        urlLabel.isHidden = true
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
        
        urlLabel.isHidden = true
    }
}

// MARK: - Helper Methods
fileprivate extension WebsiteViewController {
    func setupActivityView() {
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
    }
    
    func setupURLLabel() {
        urlLabel.text = "Loading \(urlString)..."
        urlLabel.isHidden = false
    }
}



// MARK: - Subclasses
class UnredactorWebsiteViewController: WebsiteViewController {
    override func setupWebView() {
        urlString = "https://www.manceps.com/projects/unredactor"
        super.setupWebView()
    }
}

class MancepsWebsiteViewController: WebsiteViewController {
    override func setupWebView() {
        urlString = "https://manceps.com"
        super.setupWebView()
    }
}
