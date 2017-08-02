//
//  EventsTableViewController.swift
//  Guests
//
//  Created by Mikołaj Stępniewski on 17.07.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class EventsTableViewController: UITableViewController {
    @IBAction func handleCancelBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
        print(events)
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return events.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> EventTableViewCell {
        let eventsKeys = Array(events.keys)
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventTableViewCell
        
        let key = eventsKeys[indexPath.row]
        let name = events[key]
        cell.textLabel?.text = name
        cell.configure(key: key, name: name!)
        cell.textLabel?.textColor = UIColor.white
        if currentEvent == nil {
            if indexPath.row == 0 {
                cell.accessoryType = .checkmark
                currentEvent.key = cell.key
                currentEvent.name = cell.name
                NotificationCenter.default.post(name: Notification.Name("eventChanged"), object: nil)
            } else {
                cell.accessoryType = .none
            }
        } else {
            if cell.key == currentEvent.key {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected")
        let cell = tableView.cellForRow(at: indexPath) as! EventTableViewCell
            if cell.accessoryType == .none {
                cell.accessoryType = .checkmark
                for var i in 0..<tableView.numberOfRows(inSection: 0) {
                    tableView.cellForRow(at: IndexPath(row: i, section: 0))?.accessoryType = .none
                    
                }
                cell.accessoryType = .checkmark
                
                currentEvent.key = cell.key
                currentEvent.name = cell.name
                NotificationCenter.default.post(name: Notification.Name("eventChanged"), object: nil)
            } else {
                
            }
        
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
