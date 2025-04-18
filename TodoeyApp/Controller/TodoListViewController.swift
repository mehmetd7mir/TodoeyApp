//
//  ViewController.swift
//  TodoeyApp
//
//  Created by Mehmet  Demir on 17.04.2025.
//

import UIKit
import CoreData

class TodoListViewController : SwipeableTableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    var itemArray = [Item]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
    }
    
    // MARK: TableView Datasource Methods
    
    //we tell us the number of rows in every section and returns Int
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell",for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        
        let item = itemArray[indexPath.row]
        
        content.text = item.title
        
        cell.contentConfiguration = content
        
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    // MARK: TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item!", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item,I am sure.", style: .default) { action in
            //what will hapen once the user clicks  the add ıtem button on alert
            let new = Item(context : self.context)
            new.title = textField.text!
            new.done = false
            new.parentCategory = self.selectedCategory!
            self.itemArray.append(new)
            self.saveItems()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(cancelAction)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
        
    }
    
    // MARK: Model Manupulation Methods
    
    func saveItems() {
        do {
            try self.context.save()
        } catch {
            print("error saving data")
        }
        self.tableView.reloadData()
    }
    
    func loadItems(with request : NSFetchRequest<Item> = Item.fetchRequest() , predicate : NSPredicate? = nil) {
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let safePredicate = predicate {
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,safePredicate])
            request.predicate = compoundPredicate
        } else {
            request.predicate = categoryPredicate
        }
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("errror fetcignf data")
        }
        tableView.reloadData()
    }
    
    // MARK: Deleting
    override func updateModel(at indexPath: IndexPath) {
        let itemToDelete = itemArray[indexPath.row]
        context.delete(itemToDelete)
        itemArray.remove(at: indexPath.row)
        saveItems()
    }
    
}


// MARK: Search Bar Method
extension TodoListViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchItems(with: searchBar.text!)
    }
    // live filtre
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder() // keyboard good bye
            }
        } else {
            searchItems(with: searchText)
        }
    }
    
    // coommonfiltre method
    func searchItems(with query: String) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", query)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        request.predicate = predicate
        loadItems(with: request,predicate: predicate)
    }
}
