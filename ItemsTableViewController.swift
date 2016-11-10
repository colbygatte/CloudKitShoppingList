//
//  ItemsTableViewController.swift
//  CloudKitShoppingList
//
//  Created by Colby Gatte on 11/9/16.
//  Copyright © 2016 colbyg. All rights reserved.
//

import UIKit
import CloudKit

class ItemsTableViewController: UITableViewController, AddItemViewControllerDelegate {
    
    var lists: [List]!
    var list: List!
    var db: CKDatabase!
    var originalListIndex: Int!
    
    var items: [Item]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        items = [Item]()
        
        let ref = CKReference(recordID: list.recordID!, action: .deleteSelf)
        let query = CKQuery(recordType: "Items", predicate: NSPredicate(format: "belongsToList == %@", ref))
        
        self.db.perform(query, inZoneWith: nil, completionHandler:{ (records: [CKRecord]?, error: Error?) in
            if error != nil {
                print(error?.localizedDescription ?? "idk, error happened")
            }
            
            for record in records! {
                self.items.append(Item(ckRecord: record))
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    // MARK: Did add item
    
    func addItemViewControllerDelegate_DidAddItem(item: Item, itemMovedToAnotherList: Bool) {
        
        if(item.recordID != nil) { // updating
            
            let modify = CKModifyRecordsOperation(recordsToSave: [item.toCKRecord()], recordIDsToDelete: nil)
            modify.savePolicy = .allKeys // THIS KILLED ME!!!!!!!!!! REMEMBER TO SET THIS!!!!!!!!!!!!
            modify.modifyRecordsCompletionBlock = { (savedRecords: [CKRecord]?, deletedRecordIDs: [CKRecordID]?, error: Error?) in
                print(error?.localizedDescription ?? "no error")
            }
            
            self.db.add(modify)
            if itemMovedToAnotherList {
                self.items.remove(at: (self.tableView.indexPathForSelectedRow?.row)!)
            }
        
        } else { // adding
            
            item.belongsToList = CKReference(recordID: list.recordID!, action: .deleteSelf)
            self.db.save(item.toCKRecord(), completionHandler:{ (record: CKRecord?, error: Error?) in
                if error != nil { print(error.debugDescription) }
            })
            self.items.append(item)
        }
        
        self.tableView.reloadData()
    }
    
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.textLabel?.text = self.items[indexPath.row].itemName
        cell.detailTextLabel?.text = self.items[indexPath.row].itemDescription

        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let recordID = items[indexPath.row].recordID
        let delete = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [recordID!])
        delete.modifyRecordsCompletionBlock = { (savedRecords: [CKRecord]?, deletedRecordIDs: [CKRecordID]?, error: Error?) in
            print(error?.localizedDescription ?? "(((♥))) no deletion error of item")
        }
        
        self.db.add(delete)
        
        self.items.remove(at: indexPath.row)
        self.tableView.reloadData()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddItem" {
            let vc = segue.destination as! AddItemViewController
            vc.delegate = self
        } else if segue.identifier == "ViewItem" {
            let vc = segue.destination as! AddItemViewController
            vc.delegate = self
            vc.item = self.items[(self.tableView.indexPathForSelectedRow?.row)!]
            vc.lists = self.lists
            vc.originalListIndex = self.originalListIndex
        }
    }
    

}
