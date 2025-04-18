//
//  CategoryTableViewController.swift
//  TodoeyApp
//
//  Created by Mehmet  Demir on 18.04.2025.
//

import UIKit
import CoreData

class CategoryTableViewController: SwipeableTableViewController {
    
    var categoryArray = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }
    
    // MARK: TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    //i prepare the every cell , they come from order.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCategoryCell", for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        
        let category = categoryArray[indexPath.row]
        
        content.text = category.name
        
        cell.contentConfiguration = content
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "GotoItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GotoItems" {
            let destinationVC = segue.destination as! TodoListViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.selectedCategory = categoryArray[indexPath.row]
            }
        }
    }
    // MARK: Data Manipulation Methods
    func saveCategories(){
        do {
            try self.context.save()
        } catch {
            print("save error")
        }
        self.tableView.reloadData()
    }
    
    func loadCategories(with request : NSFetchRequest<Category> = Category.fetchRequest()) {
        do {
            categoryArray = try context.fetch(request)
        } catch {
            print("load error")
        }
        tableView.reloadData()
    }
    
    
    // MARK: Add New Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new category!", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add category, I am sure", style: .default) { action in
            let new = Category(context: self.context)
            new.name = textField.text!
            self.categoryArray.append(new)
            self.saveCategories()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        
        
        present(alert, animated: true)
    }
    // MARK: Deleting
    override func updateModel(at indexPath: IndexPath) {
        let categoryToDelete = categoryArray[indexPath.row]
        context.delete(categoryToDelete)
        categoryArray.remove(at: indexPath.row)
        saveCategories()
    }
}
// MARK: Search Bar Method
extension CategoryTableViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchCategory(with: searchBar.text!)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            loadCategories()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder() //keyboard bye bye
            }
        } else {
            searchCategory(with: searchBar.text!)
        }
    }
    
    func searchCategory(with query : String) {
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", query)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        loadCategories(with: request)
    }
}


