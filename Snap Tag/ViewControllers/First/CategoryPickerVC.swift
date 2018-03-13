//
//  CategoryPickerVC.swift
//  Snap Tag
//
//  Created by Afiq Ramli on 07/03/2018.
//  Copyright © 2018 Afiq Ramli. All rights reserved.
//

import UIKit

protocol CategoryPickerVCDelegate {
    func didFinishSelecting(_ category: String)
}

class CategoryPickerVC: UITableViewController {
    var selectedCategoryName = ""
    let categories = [
        "No Category",
        "Apple Store",
        "Bar",
        "Bookstore",
        "Club",
        "Grocery Store",
        "Historic Building",
        "House",
        "Icecream Vendor",
        "Landmark",
        "Park"
    ]
    var selectedIndexPath = IndexPath()
    var delegate: CategoryPickerVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View Should Load")
        print("Category: \(selectedCategoryName)")
        for i in 0..<categories.count {
            if categories[i] == selectedCategoryName {
                selectedIndexPath = IndexPath(row: i, section: 0)
                break
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension CategoryPickerVC {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let categoryName = categories[indexPath.row]
        cell.textLabel!.text = categoryName
        
        if categoryName == selectedCategoryName {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CategoryPickerVC {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row != selectedIndexPath.row {
            if let newCell = tableView.cellForRow(at: indexPath) {
                newCell.accessoryType = .checkmark
            }
            if let oldCell = tableView.cellForRow(at: selectedIndexPath) {
                oldCell.accessoryType = .none
            }
            selectedIndexPath = indexPath
        }
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.didFinishSelecting(categories[indexPath.row])
    }
}



















