//
//  ViewController.swift
//  A-list
//
//  Created by Avneet Sekhon on 2023-07-11.
//

import UIKit
import CoreData

class ListViewController: UITableViewController {
    
    var itemArray = [DataManager]()
    //Access to the AppDelegate.swift as an object so we can use NSPersistentContainer
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        //Load persistent data
        //loadDataItems()
    }
    
    //Number of cells that will be created in the table view.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    //Cell modifications
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Create the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListItemCell", for: indexPath)
        
        //Configure the cell
        var cellConfig = UIListContentConfiguration.cell()
        cellConfig.text = itemArray[indexPath.row].title
        cell.contentConfiguration = cellConfig
        
        //Display the checkmark
        cell.accessoryType = itemArray[indexPath.row].checked ? .checkmark : .none
        
        return cell
    }
    
    //Cell selection
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Assign checkmark bool
        itemArray[indexPath.row].checked = !itemArray[indexPath.row].checked
        
        saveDataItems()
        
        //UI upgrade to animate selection
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //New list item
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var newItemText = UITextField()
        let newItemAlert = UIAlertController(title: "Add new item", message: "", preferredStyle: .alert)
        let newItemAction = UIAlertAction(title: "Add item", style: .default) { newItemAction in

            //User pressed "Add item" button, process the following:
            let newData = DataManager(context: self.context)
            newData.title = newItemText.text!
            newData.checked = false
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
    
    //Save list items to a plist
    func saveDataItems() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
        
        //Reload table view
        self.tableView.reloadData()
    }
    
    //Load items from a plist
//    func loadDataItems() {
//        if let data = try? Data(contentsOf: dataFilePath!) {
//            let decoder = PropertyListDecoder()
//            do {
//                itemArray = try decoder.decode([DataManager].self, from: data)
//            } catch {
//                print("Error decoding data items: \(error)")
//            }
//        }
//    }
}

