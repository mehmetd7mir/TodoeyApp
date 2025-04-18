//
//  SwipeableTableViewController.swift
//  TodoeyApp
//
//  Created by Mehmet  Demir on 18.04.2025.
//

import Foundation
import UIKit

class SwipeableTableViewController : UITableViewController {
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] action, view, completionHandler in
            self?.updateModel(at: indexPath)
            completionHandler(true)
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
    
    @objc func updateModel(at indexPath : IndexPath) {
        //this method will be overrided by subclasses.
    }
}
