//
//  ContributorsViewController.swift
//  Unredactor
//
//  Created by Tyler Gee on 8/29/19.
//  Copyright © 2019 tyler. All rights reserved.
//

import UIKit


class SummaryViewController: UIViewController {
    
    weak var delegate: SummaryTableViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let summaryTableViewController as SummaryTableViewController:
            summaryTableViewController.delegate = self
        default:
            break
        }
    }
}

extension SummaryViewController: SummaryTableViewControllerDelegate {
    func didSelectRow(_ row: Int) {
        delegate?.didSelectRow(row)
    }
}


