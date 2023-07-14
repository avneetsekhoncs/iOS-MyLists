//
//  CategoryTableViewController.swift
//  A-list
//
//  Created by Avneet Sekhon on 2023-07-13.
//

import UIKit
import CoreData
import SwipeCellKit

class CategoryTableViewController: UITableViewController {

    var categoryArray = [CategoryManager]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        loadDataCategories()
        tableView.rowHeight = 65.0
    }

    // MARK: - TableView data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! SwipeTableViewCell
        
        var cellConfig = UIListContentConfiguration.cell()
        cellConfig.text = categoryArray[indexPath.row].name
        cell.contentConfiguration = cellConfig
        
        cell.delegate = self
        
        return cell
    }
    
    //MARK: - TableView Delegate Functionality
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToChildList", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray[indexPath.row]
        }
    }
    
    //MARK: - Context Functionality
    func saveDataCategories() {
        do {
            try context.save()
        } catch {
            print("Error saving through context: \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadDataCategories(with request: NSFetchRequest<CategoryManager> = CategoryManager.fetchRequest()) {
        do {
            categoryArray = try context.fetch(request)
        } catch {
            print("Error fetching data through context: \(error)")
        }
        
        tableView.reloadData()
    }
    
    //MARK: - Add Button Functionality
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var newCategoryText = UITextField()
        let newCategoryAlert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        let newCategoryAction = UIAlertAction(title: "Add", style: .default) { newCategoryAction in

            let newCategory = CategoryManager(context: self.context)
            newCategory.name = newCategoryText.text!
            self.categoryArray.append(newCategory)
            
            self.saveDataCategories()
        }
        
        newCategoryAlert.addTextField { alertTextField in
            alertTextField.placeholder = "Add category"
                newCategoryText = alertTextField
        }
        newCategoryAlert.addAction(newCategoryAction)
        present(newCategoryAlert, animated: true, completion: nil)
    }
    
}

//MARK: - SwipeTableViewCell Delegate Functionality
extension CategoryTableViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            //Delete item from context then the array. Order matters.
            self.context.delete(self.categoryArray[indexPath.row])
            self.categoryArray.remove(at: indexPath.row)
            
            /*
             Can't call saveDataCategories() because you can't realodData before "editActionsOptionsForRowAt" runs. Reloading too early will cause an error because you are trying to delete something that is already gone.
             */
            do {
                try self.context.save()
            } catch {
                print("Error saving through context: \(error)")
            }
        }

        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")

        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
    
}
