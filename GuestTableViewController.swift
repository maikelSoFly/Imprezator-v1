//
//  GuestTableViewController.swift
//  Guests
//
//  Created by Mikołaj Stępniewski on 07.07.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

extension GuestTableViewController: UISearchResultsUpdating, UISearchBarDelegate, CheckDelegate, LogInDelegate {
    func pullData() {
        print("⚽pulling items")
    }
    
    func didCheck() {
        setCheckedLabel();
    }
    
    @available(iOS 8.0, *)
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBarTextChanged(searchBar: searchBar)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("🌵")
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("💣")
    }
}

var checkedCounter: Int = 0
var guests: [String: Guest] = [:]
var events: [String: String] = [:]
var didLoggedOut = false
var currentEvent: Event!


class GuestTableViewController: UITableViewController {
    
    var test: String = ""
    
    var logInVC: LogInViewController? = nil
    
    
    
    @IBAction func handleEventsBtn(_ sender: Any) {
        performSegue(withIdentifier: "eventsSegue", sender: self)
    }
    @IBOutlet weak var checkedLabel: UILabel!
    
    @IBOutlet weak var eventButton: UIButton!
    
    
    
    var isSearching = false
    var filteredData = [Guest]()
    
    var isCellClosing = false
    
    let searchController = UISearchController(searchResultsController: nil)
    var resultController = UITableViewController()
    
    var ref: DatabaseReference!
    var loginSuccess = false
    
    @objc func setCheckedLabel() {
        self.checkedLabel.text = "Checked: \(checkedCounter) of \(guests.count)"
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logInVC = self.storyboard?.instantiateViewController(withIdentifier: "logInView") as! LogInViewController
        tableView.allowsSelection = false
        if Auth.auth().currentUser == nil {
            print("🇵🇱user logged out")
            didLoggedOut = true
            presentLogInView()
        }
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        searchController.searchBar.barStyle = UIBarStyle.black
        searchController.searchBar.searchBarStyle = UISearchBarStyle.minimal
        tableView.backgroundView = UIView()
        
        var contentOffset = tableView.contentOffset
        contentOffset.y += searchController.searchBar.frame.size.height
        tableView.contentOffset = contentOffset
        ref = Database.database().reference()
        fetchAvailableEvents()
        setCheckedLabel()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeEvent), name: Notification.Name("eventChanged"), object: nil)
        
    }
    
    func presentLogInView() {
        
        var popoverContent = self.storyboard?.instantiateViewController(withIdentifier: "logInView") as! LogInViewController
        let nav = UINavigationController(rootViewController: popoverContent)
        nav.modalPresentationStyle = UIModalPresentationStyle.popover
        let popover = nav.popoverPresentationController
        
        popover?.delegate = self as? UIPopoverPresentationControllerDelegate
        popover?.sourceView = self.view
        
        
        self.present(nav, animated: true, completion: nil)
        
    }
    
    @objc func changeEvent() {
        print("changeItem")
        ref.database.reference().removeAllObservers()
        guests.removeAll()
        checkedCounter = 0
        setCheckedLabel()
        self.title = currentEvent.name
        fetchData(forEventID: currentEvent.key)
        
    }
    
    func fetchAvailableEvents() {
        Database.database().reference().observe(.childAdded, with: { (snapshot) in
            let dict = snapshot.value as! NSDictionary
            if events.count == 0 {
                currentEvent = Event(key: snapshot.key, name: dict["name"] as! String)
                self.title = currentEvent.name
                self.fetchData(forEventID: currentEvent.key)
            }
            events[snapshot.key] = dict["name"] as? String
            
            
        }, withCancel: nil)
    }
    
    func fetchData(forEventID eventID: String) {
        print("🍏fetching")
        
        
        //When event is removed
        Database.database().reference().observe(.childRemoved, with: { (snapshot) in
       
            events[snapshot.key] = nil
            
        }, withCancel: nil)
        
        //When participant is removed
        Database.database().reference().child(eventID).child("participants").observe(.childRemoved) { (snapshot) in
            print("💣child deleted")
            let guest = guests[snapshot.key]
            print(guest?.name! as Any)
            
            guests[snapshot.key] = nil
            checkedCounter -= 1
            self.setCheckedLabel()
            self.tableView.reloadData()
            print(guests)
        }
        
        //When participant is updated
        Database.database().reference().child(eventID).child("participants").observe(.childChanged) { (snapshot) in
            print("🍏\(snapshot.key) changed")
            let value = snapshot.value as? [String: AnyObject]
            print(value!)
            let guest = guests[snapshot.key]
            let wasChecked = guest?.isChecked
            
            if let value = snapshot.value as? [String: AnyObject] {
                guest?.name = value["name"] as! String
                guest?.isChecked = value["checked"] as! Bool
                guest?.addedBy = value["addedBy"] as! String
                guest?.price = (value["price"] as! CFNumber) as! Int
            }
            
            if wasChecked! && !(guest?.isChecked)! {
                checkedCounter -= 1
            }
            else if !wasChecked! && (guest?.isChecked)! {
                checkedCounter += 1
            }
            if !self.isCellClosing {
                self.setCheckedLabel()
                self.tableView.reloadData()
            }
            
        }
        
        //When new participant is added
        Database.database().reference().child(eventID).child("participants").observe(.childAdded) { (snapshot) in
            print(snapshot.value)
            let dict = snapshot.value as! NSDictionary
            let name = dict["name"] as! String
            let key = snapshot.key
            let addedBy = dict["addedBy"] as! String
            let price = (dict["price"] as! CFNumber) as! Int
            let isChecked = dict["checked"] as! Bool
            let guest = Guest(name: name, withKey: key, from: addedBy, payed: price, isChecked: isChecked)
            
            guests[key] = guest
            if guest.isChecked {
                print("checked!!")
                checkedCounter += 1
            }
            
            self.setCheckedLabel()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    

    override func viewDidAppear(_ animated: Bool) {
        if currentEvent != nil {
            print("🌍current Event: \(currentEvent.name)")
           
        }
        
        if loginSuccess {
            print("🍏login Success!")
        }
        setCheckedLabel()
        if Auth.auth().currentUser != nil {
            
            eventButton.isEnabled = true
            
            if didLoggedOut {
                ref.database.reference().removeAllObservers()
                fetchAvailableEvents()
                if currentEvent != nil {
                    fetchData(forEventID: currentEvent.key)
                }
                didLoggedOut = false
            }
        } else {
            
            eventButton.isEnabled = false
            presentLogInView()
        }
        tableView.reloadData()
    }
    
    
    
    func searchBarTextChanged(searchBar: UISearchBar) {
        if #available(iOS 9.0, *) {
            //print("🍏")
            //UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).title = "Ok"
        } else {
            // Fallback on earlier versions
        }
    }
    
    func filterContentForSearchText(searchText: String) {
        let guestsValues = Array(guests.values)
        filteredData = guestsValues.filter { guest in
            let name = guest.name
            return name!.lowercased().contains(searchText.lowercased())
        }
        
        tableView.reloadData()
    }
    
    func setup() {
//        guests = [Guest(firstName: "Mikołaj", lastName: "Stępniewski", isChecked: false),
//                  Guest(firstName: "Artur", lastName: "Kasza", isChecked: false),
//                  Guest(firstName: "Playboi", lastName: "Carti", isChecked: false),
//                  Guest(firstName: "Dillon", lastName: "Cooper", isChecked: false),
//                  Guest(firstName: "Joey", lastName: "Bada$$", isChecked: false),
//                  Guest(firstName: "Vince", lastName: "Staples", isChecked: false),
//                  Guest(firstName: "Yung", lastName: "Internet", isChecked: false),
//                  Guest(firstName: "Kodak", lastName: "Black", isChecked: false),
//                  Guest(firstName: "Mura", lastName: "Masa", isChecked: false),
//                  Guest(firstName: "Childish", lastName: "Gambino", isChecked: false),
//                  Guest(firstName: "Kendric", lastName: "Lamar", isChecked: false),
//                  Guest(firstName: "French", lastName: "Montana", isChecked: false),
//                  Guest(firstName: "Travis", lastName: "Scot", isChecked: false),
//                  Guest(firstName: "Denzel", lastName: "Curry", isChecked: false),
//                  Guest(firstName: "Post", lastName: "Malone", isChecked: false),
//                  Guest(firstName: "Young", lastName: "Thug", isChecked: false),
//                  Guest(firstName: "Kanye", lastName: "West", isChecked: false)
//        ]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredData.count
        }
        return guests.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> TableViewCell {
        let guestsValues = Array(guests.values)
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        let guest: Guest
        if searchController.isActive && searchController.searchBar.text != "" {
            guest = filteredData[indexPath.row]
        } else {
            guest = guestsValues[indexPath.row]
        }
        cell.configure(guest: guest)
        
        cell.checkBox.delegate = self
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let guest: Guest
        var isSearchingActive = false
        
        if searchController.isActive && searchController.searchBar.text != "" {
            guest = filteredData[indexPath.row]
            isSearchingActive = true
        }
        else {
            let guestsValues = Array(guests.values)
            guest = guestsValues[indexPath.row]
        }
        print(guest.name)
        
        let more = UITableViewRowAction(style: .normal, title: "More") { action, index in
            self.tableView.setEditing(false, animated: true)
        }
        more.backgroundColor = UIColor.lightGray
        
        let check = UITableViewRowAction(style: .normal, title: "Check") { action, index in
            if !guest.isChecked {
                guest.isChecked = true
                checkedCounter += 1
                self.setCheckedLabel()
                
                let post = ["checked": true,
                            "name": guest.name,
                            "addedBy" : guest.addedBy,
                            "price": guest.price
                    ] as [String : Any]
                
                let childUpdate = ["/\(currentEvent.key)/participants/\(guest.key!)": post]
                self.ref.updateChildValues(childUpdate)
            } else {
                guest.isChecked = false
                checkedCounter -= 1
                self.setCheckedLabel()
                let post = ["checked": false,
                            "name": guest.name,
                            "addedBy" : guest.addedBy,
                            "price": guest.price
                    ] as [String : Any]
                let childUpdate = ["/\(currentEvent.key)/participants/\(guest.key!)": post]
                self.ref.updateChildValues(childUpdate)
            }
            
            CATransaction.begin()
            CATransaction.setCompletionBlock({
                tableView.reloadData()
                self.isCellClosing = false
            })
            self.isCellClosing = true
            self.tableView.setEditing(false, animated: true)
            CATransaction.commit()
        }
        check.backgroundColor = UIColor.orange
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            self.tableView.setEditing(false, animated: true)
            self.ref.child(currentEvent.key).child("participants").child(guest.key).removeValue()
            if guest.isChecked {
                checkedCounter -= 1
            }
            self.setCheckedLabel()
            guests[guest.key] = nil
            if isSearchingActive {
                self.filteredData.remove(at: indexPath.row)
            }
            self.tableView.reloadData()
            
        }
        delete.backgroundColor = UIColor.red
        
        return [delete, check, more]
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // the cells you would like the actions to appear needs to be editable
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
    }

}
