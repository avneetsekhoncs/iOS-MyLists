//
//  ViewController.swift
//  A-list
//
//  Created by Avneet Sekhon on 2023-07-11.
//

import UIKit

class ListViewController: UITableViewController {
    
    let itemArray = ["Movies", "Bali Trip", "Weekend Plans"]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
        
        cellConfig.text = itemArray[indexPath.row]
        cell.contentConfiguration = cellConfig
        
        
        return cell
    }
    
    //
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(itemArray[indexPath.row])
        
        //Display checkmark to show cell is selected
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
        //UI upgrade to animate selection
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

