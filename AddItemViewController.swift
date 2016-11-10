//
//  AddItemViewController.swift
//  CloudKitShoppingList
//
//  Created by Colby Gatte on 11/9/16.
//  Copyright © 2016 colbyg. All rights reserved.
//

import UIKit
import CloudKit

protocol AddItemViewControllerDelegate {
    func addItemViewControllerDelegate_DidAddItem(item: Item, itemMovedToAnotherList: Bool)
}

class AddItemViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    // Assigned from previous view controller
    
    var item: Item!
    var lists: [List] = [List]()
    var delegate: AddItemViewControllerDelegate!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var addItemButton: UIButton!
    
    @IBOutlet weak var chooseCategoryView: UIView! // hide this for adding
    @IBOutlet weak var chooseCategory: UIPickerView!
    
    var originalListIndex: Int!
    var chosenListIndex: Int!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.chooseCategory.dataSource = self
        self.chooseCategory.delegate = self

        
        if (self.item == nil) { // adding
            item = Item()
            //chooseCategoryView.alpha = 0
            chooseCategoryView.removeFromSuperview()
        } else { // updating
            self.chooseCategory.selectRow(originalListIndex, inComponent: 0, animated: false)
            self.chosenListIndex = self.originalListIndex // set value in case slider isn't changed
            
            self.nameTextField.text = item.itemName
            self.descriptionTextField.text = item.itemDescription
            
            self.title = "Edit Item"
            self.addItemButton.setTitle("Save", for: .normal)
        }
        
        self.addItemButton.layer.cornerRadius = 5
        self.addItemButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // uipickerview
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return lists.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return lists[row].listName
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.chosenListIndex = row
    }
    
    
    
    @IBAction func addItemButtonPressed(_ sender: Any) {
        let itemMoved: Bool!
        
        if self.item.recordID == nil { // adding
            itemMoved = false
            self.item = Item(itemName: nameTextField.text!, itemDescription: descriptionTextField.text!)
        } else { // updating
            self.item.itemName = self.nameTextField.text
            self.item.itemDescription = self.descriptionTextField.text
            
            
            if(self.chosenListIndex != self.originalListIndex) {
                let list = lists[chosenListIndex]
                self.item.belongsToList = CKReference(recordID: list.recordID!, action: CKReferenceAction.deleteSelf)
                
                itemMoved = true
            } else {
                itemMoved = false
            }
            
        }
        
        self.delegate.addItemViewControllerDelegate_DidAddItem(item: self.item, itemMovedToAnotherList: itemMoved)
        self.navigationController?.popViewController(animated: true)
    }

}
