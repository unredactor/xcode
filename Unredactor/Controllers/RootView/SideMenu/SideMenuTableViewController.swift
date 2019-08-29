//
//  SideMenuTableTableViewController.swift
//  Unredactor
//
//  Created by Tyler Gee on 8/15/19.
//  Copyright © 2019 tyler. All rights reserved.
//

import UIKit

// MARK: - Delegate
protocol SideMenuTableViewControllerDelegate: class {
    func didSelectRow(_ row: Int)
}

// View Definition
/**
 SideMenuTableViewController manages the table view within the side menu and what/how it is displayed
*/
class SideMenuTableViewController: UITableViewController {
    
    // MARK: - Properties
    @IBOutlet var imageViews: [UIImageView]!
    
    weak var delegate: SideMenuTableViewControllerDelegate?
    
    private let imageViewColor: UIColor = UIColor.black.withAlphaComponent(0.3)
    
    // MARK: - View LIfe Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Interface
    func selectRow(atRow row: Int, isAnimated animated: Bool) {
        let selectedRow = indexPathForRow(row)
        tableView.selectRow(at: selectedRow, animated: animated, scrollPosition: .top)
        tableView.delegate?.tableView?(tableView, didSelectRowAt: selectedRow)
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.black.withAlphaComponent(0.6)
        header.textLabel?.font = UIFont(name: "Courier-Bold", size: 17)!
        let moveRightTransform = CGAffineTransform(translationX: 16, y: 0)
        header.textLabel?.transform = moveRightTransform
        header.textLabel?.translatesAutoresizingMaskIntoConstraints = false
        header.backgroundColor = .clear
        header.contentView.backgroundColor = .clear
        
        let backgroundView = UIView(frame: header.frame)
        backgroundView.backgroundColor = .clear
        header.backgroundView = backgroundView
        
        setupImageViews()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        // Add custom backgroundView
        let backgroundView = UIView()
        let maskPath = UIBezierPath(roundedRect: cell.bounds, byRoundingCorners: [.bottomRight, .topRight], cornerRadii: CGSize(width: cell.frame.height / 3, height: cell.frame.height / 2))
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        backgroundView.layer.mask = shape
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.05)
        
        cell.selectedBackgroundView = backgroundView
        
        return cell
    }
    
    /// Returns the actual number of rows in each section. In section 0, there is an extra empty row for spacing/drawing purposes. Use the private helper method numberOfRows(inSection:) for internal logic purposes.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else {
            return 4
        }
    }
    
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //super.tableView(tableView, didSelectRowAt: indexPath)
        delegate?.didSelectRow(rowForIndexPath(indexPath))
    }
}


// MARK: - Helper Methods
fileprivate extension SideMenuTableViewController {
    func setupImageViews() {
        for imageView in imageViews {
            imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = imageViewColor
        }
    }
    
    func rowForIndexPath(_ indexPath: IndexPath) -> Int {
        guard indexPath.section > 0 else { return indexPath.row }
        
        var row = 0
        for section in 1...indexPath.section {
            row += numberOfRows(inSection: section - 1)
        }
        row += indexPath.row
        print("row: \(indexPath.row)")
        
        return row
    }
    
    func indexPathForRow(_ row: Int) -> IndexPath {
        guard row < numberOfRows(inSection: 0) else { return IndexPath(row: row, section: 0) }
        
        var rowCount = row
        let numberOfSections = tableView.numberOfSections
        for section in 0..<numberOfSections {
            let numberOfRowsInSection = numberOfRows(inSection: section)
            if rowCount > numberOfRowsInSection - 1 {
                rowCount -= numberOfRowsInSection
            } else {
                return IndexPath(row: rowCount, section: section)
            }
        }
        
        print("Looped through all IndexPaths without finding appropriate row. Check in indexPathForRow(_ row: Int) -> IndexPath in SideMenuTableViewController; the logic is incorrect.")
        return IndexPath(row: 0, section: 0)
    }
    
    func numberOfRows(inSection section: Int) -> Int {
        // This allows a visual padding row to be placed at the bottom of section 0 without having to manually account for it in logic. The other section (there is only 1 other section for now) can be computed normally, as it has no padding row (because there is no section below it).
        
        if section == 0 { return tableView.numberOfRows(inSection: section) - 1 }
        else { return tableView.numberOfRows(inSection: section) }
    }
}

// MARK: - Table View Cell
class SideMenuTableViewCell: UITableViewCell {
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        backgroundView?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }
}
