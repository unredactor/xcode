//
//  ContributorsTableViewController.swift
//  Unredactor
//
//  Created by Tyler Gee on 8/29/19.
//  Copyright © 2019 tyler. All rights reserved.
//

import UIKit

protocol ContributorsTableViewControllerDelegate: class {
    func didSelectRow(_ row: Int)
}

class ContributorsTableViewController: UITableViewController {
    
    weak var delegate: ContributorsTableViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("test")
        delegate?.didSelectRow(rowForIndexPath(indexPath))
    }
}

fileprivate extension ContributorsTableViewController {
    private func rowForIndexPath(_ indexPath: IndexPath) -> Int {
        guard indexPath.section != 0 else { return indexPath.row }
        
        var row = 0
        for section in 1...indexPath.section {
            row += tableView.numberOfRows(inSection: section - 1)
        }
        
        row += indexPath.row
        
        return row
    }
}
