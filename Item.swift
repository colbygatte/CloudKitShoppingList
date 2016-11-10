//
//  Item.swift
//  CloudKitShoppingList
//
//  Created by Colby Gatte on 11/9/16.
//  Copyright © 2016 colbyg. All rights reserved.
//

import UIKit
import CloudKit

class Item: NSObject {
    var itemDescription: String!
    var itemName: String!
    var recordID: CKRecordID?
    var belongsToList: CKReference!
    
    init(ckRecord: CKRecord) {
        self.itemDescription = ckRecord.value(forKey: "itemDescription") as? String ?? ""
        self.itemName = ckRecord.value(forKey: "itemName") as! String
        self.recordID = ckRecord.recordID
        self.belongsToList = ckRecord.value(forKey: "belongsToList") as! CKReference
        
    }
    
    override init() {
        
    }
    
    init(itemName: String, itemDescription: String) {
        self.itemName = itemName
        self.itemDescription = itemDescription
    }
    
    
    func toCKRecord() -> CKRecord {
        let record: CKRecord!
        if(self.recordID != nil) {
            record = CKRecord(recordType: "Items", recordID: self.recordID!)
        } else {
            record = CKRecord(recordType: "Items")
        }
        record.setValue(self.belongsToList, forKey: "belongsToList")
        record.setValue(self.itemDescription, forKey: "itemDescription")
        record.setValue(self.itemName, forKey: "itemName")

        return record
    }
    
}
