//
//  SideMenuTableTableViewController.swift
//  Unredactor
//
//  Created by Tyler Gee on 8/15/19.
//  Copyright © 2019 tyler. All rights reserved.
//

import UIKit

class SideMenuTableTableViewController: UITableViewController {

    @IBOutlet var imageViews: [UIImageView]!
    private let imageViewColor: UIColor = UIColor.black.withAlphaComponent(0.3)
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        print(UIFont.fontNames(forFamilyName: "Courier"))
        
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
}


// MARK: - Helper Methods
fileprivate extension SideMenuTableTableViewController {
    func setupImageViews() {
        for imageView in imageViews {
            imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = imageViewColor
        }
    }
}

// MARK: - Table View Cell
class SideMenuTableViewCell: UITableViewCell {
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        backgroundView?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }
}
