//
//  ViewController.swift
//  A-list
//
//  Created by Avneet Sekhon on 2023-07-11.
//

import UIKit

class ListViewController: UITableViewController {
    
    var itemArray = [DataManager]()
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Data.plist")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Load persistent data
        loadDataItems()
    }
    
    //Number of cells that will be created in the table view.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Assign checkmark bool
        itemArray[indexPath.row].checked = !itemArray[indexPath.row].checked
        
        saveDataItems()
        
        //UI upgrade to animate selection
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var newItemText = UITextField()
        let newItemAlert = UIAlertController(title: "Add new item", message: "", preferredStyle: .alert)
        let newItemAction = UIAlertAction(title: "Add item", style: .default) { newItemAction in
            
            //User pressed "Add item" button, process the following:
            let newData = DataManager()
            newData.title = newItemText.text!
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
    
    func saveDataItems() {
        //Encode instances of DataManager data types to a property list
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(itemArray)
            try data.write(to: dataFilePath!)
        } catch {
            print("Error encoding: \(error)")
        }
        
        //Reload table view
        self.tableView.reloadData()
    }
    
    func loadDataItems() {
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
                itemArray = try decoder.decode([DataManager].self, from: data)
            } catch {
                print("Error decoding data items: \(error)")
            }
        }
    }
}

