//
//  ContributorsViewController.swift
//  Unredactor
//
//  Created by Tyler Gee on 8/29/19.
//  Copyright © 2019 tyler. All rights reserved.
//

import UIKit


class ContributorsViewController: UIViewController {
    
    weak var delegate: ContributorsTableViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("start")
        switch segue.destination {
        case let contributorsTableViewController as ContributorsTableViewController:
            print("test2")
            contributorsTableViewController.delegate = self
        default:
            break
        }
    }
}

extension ContributorsViewController: ContributorsTableViewControllerDelegate {
    func didSelectRow(_ row: Int) {
        delegate?.didSelectRow(row)
    }
}


