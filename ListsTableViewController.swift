//
//  ListsTableViewController.swift
//  CloudKitShoppingList
//
//  Created by Colby Gatte on 11/9/16.
//  Copyright © 2016 colbyg. All rights reserved.
//

import UIKit
import CloudKit

class ListsTableViewController: UITableViewController {
    @IBOutlet var newListTextField: UITextField!
    
    var lists: [List]!
    var container: CKContainer!
    var db: CKDatabase!

    override func viewDidLoad() {
        super.viewDidLoad()
        lists = [List]()
        self.container = CKContainer.default()
        self.db = container.publicCloudDatabase
        
        let query = CKQuery(recordType: "Lists", predicate: NSPredicate(value: true))
        
        self.db.perform(query, inZoneWith: nil, completionHandler:{ (records: [CKRecord]?, error: Error?) in
            for record in records! {
                self.lists.append(List(ckRecord: record))
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    @IBAction func addListButtonPressed() {
        let menu = UIAlertController(title: "List name", message: nil, preferredStyle: .alert)
        menu.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        menu.addAction(UIAlertAction(title: "Okay", style: .default, handler:{ (alertAction: UIAlertAction) in
            let list = List(listName: self.newListTextField.text!)
            self.db.save(list.toCKRecord(), completionHandler:{ (record, error) in
                list.recordID = record?.recordID
                self.lists.append(list)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            })
        }))
        menu.addTextField(configurationHandler:{ (textField: UITextField) in
            self.newListTextField = textField
        })
        
        self.present(menu, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.lists.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.textLabel?.text = self.lists[indexPath.row].listName

        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let recordID = lists[indexPath.row].recordID
            
            let delete = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [recordID!])
            delete.modifyRecordsCompletionBlock = { (savedRecords: [CKRecord]?, deletedRecordIDs: [CKRecordID]?, error: Error?) in
                print(error?.localizedDescription ?? "(((♥))) no deletion error")
            }
            self.db.add(delete)

            self.lists.remove(at: indexPath.row)
            self.tableView.reloadData()
        }
    }
    

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewItems" {
            let vc = segue.destination as! ItemsTableViewController
            vc.list = lists[(tableView.indexPathForSelectedRow?.row)!]
            vc.db = self.db
            vc.lists = self.lists
            vc.originalListIndex = (tableView.indexPathForSelectedRow?.row)!
        }
    }
    

}
