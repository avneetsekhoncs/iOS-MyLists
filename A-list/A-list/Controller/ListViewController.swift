//
//  ViewController.swift
//  A-list
//
//  Created by Avneet Sekhon on 2023-07-11.
//

import UIKit
import CoreData

class ListViewController: SwipeTableViewController {
    
    var itemArray = [DataManager]()
    //Optional CategoryManager because it will be nil until something is seleceted.
    var selectedCategory: CategoryManager? {
        didSet {
            //Load persistent data
            loadDataItems()
        }
    }
    
    //Access to the AppDelegate.swift as an object so we can use NSPersistentContainer
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let catTitle = selectedCategory?.name {
            title = catTitle
        }
    }
    //MARK: - TableView Data Source Functionality
    //Number of cells that will be created in the table view.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    //Cell modifications
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Create the cell
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        var cellConfig = UIListContentConfiguration.cell()
        cellConfig.text = itemArray[indexPath.row].title
        cell.contentConfiguration = cellConfig
        
        //Display the checkmark
        cell.accessoryType = itemArray[indexPath.row].checked ? .checkmark : .none
        
        return cell
    }
    
    //MARK: - TableView Delegate Functionality
    //Cell selection
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Assign checkmark bool
        itemArray[indexPath.row].checked = !itemArray[indexPath.row].checked
        
        saveDataItems()
        
        //UI upgrade to animate selection
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Plus Button Functionality
    //New list item
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var newItemText = UITextField()
        let newItemAlert = UIAlertController(title: "Add new item", message: "", preferredStyle: .alert)
        let newItemAction = UIAlertAction(title: "Add item", style: .default) { newItemAction in

            //User pressed "Add item" button, process the following:
            let newData = DataManager(context: self.context)
            newData.title = newItemText.text!
            newData.checked = false
            newData.parentCategory = self.selectedCategory
            self.itemArray.append(newData)
            
            self.saveDataItems()
        }
        
        //Add item button on pop up
        newItemAlert.addTextField { alertTextField in
            alertTextField.placeholder = "Add item"
                newItemText = alertTextField
        }
        newItemAlert.addAction(newItemAction)
        present(newItemAlert, animated: true, completion: nil)
    }
    
    //MARK: - CoreData Functionality
    //Save list items to CoreData
    func saveDataItems() {
        do {
            try context.save()
        } catch {
            print("Error saving through context: \(error)")
        }
        
        //Reload table view
        tableView.reloadData()
    }
    
    //Load items from CoreData, DataManager.fetchRequest() is the default value
    func loadDataItems(with request: NSFetchRequest<DataManager> = DataManager.fetchRequest(), predicate: NSPredicate? = nil) {
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let originalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, originalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data through context: \(error)")
        }
        
        //Reload table view
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        //Delete item from context then the array. Order matters.
        self.context.delete(self.itemArray[indexPath.row])
        self.itemArray.remove(at: indexPath.row)
        
        /*
         Can't call saveDataCategories() because you can't realodData before "editActionsOptionsForRowAt" runs. Reloading too early will cause an error because you are trying to delete something that is already gone.
         */
        do {
            try self.context.save()
        } catch {
            print("Error saving through context: \(error)")
        }
    }
}

//MARK: - Search Bar Functionality
extension ListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<DataManager> = DataManager.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadDataItems(with: request, predicate: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadDataItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
}
