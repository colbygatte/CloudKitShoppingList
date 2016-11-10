//
//  List.swift
//  CloudKitShoppingList
//
//  Created by Colby Gatte on 11/9/16.
//  Copyright © 2016 colbyg. All rights reserved.
//

import UIKit
import CloudKit

class List: NSObject {
    var listName: String!
    var recordID: CKRecordID?
    
    
    init(ckRecord: CKRecord) {
        self.listName = ckRecord.value(forKey: "listName") as! String!
        self.recordID = ckRecord.recordID
    }
    
    init(listName: String) {
        self.listName = listName
    }
    
    func toCKRecord() -> CKRecord {
        let record: CKRecord!
        if(self.recordID != nil) {
            record = CKRecord(recordType: "Lists", recordID: self.recordID!)
        } else {
            record = CKRecord(recordType: "Lists")
        }
        record.setValue(self.listName, forKey: "listName")
        return record
    }
}
