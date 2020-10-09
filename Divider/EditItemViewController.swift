//
//  SheetViewController.swift
//  Divider
//
//  Created by Jake Convery on 9/15/20.
//  Copyright © 2020 Jake Convery. All rights reserved.
//

import Cocoa

class EditItemViewController: NSViewController {

    @IBOutlet var itemName: NSTextField!
    @IBOutlet var cost: NSTextField!
    @IBOutlet var newOrEditButton: NSButton!
    @IBOutlet var peopleDropDown: NSPopUpButton!
    @IBOutlet var isPersonalBox: NSButton!
    
    var newItem: Item?
    var people = [Person]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // Get the people array
    }
    
    func editItem(_ item: Item) {
        itemName.stringValue = item.name
        cost.floatValue = item.cost
        peopleDropDown.selectItem(at: people.firstIndex(of: item.paidBy)!)
        if (item.isPersonal) {
            isPersonalBox.state = NSControl.StateValue.init(rawValue: 1)
        }
        newOrEditButton.title = "Save"
    }
    
    func setPeople(_ people: [Person]) {
        self.people = people
        for person in people {
            peopleDropDown.addItem(withTitle: person.name)
        }
        
    }
    
    @IBAction func createOrEdit(_ sender: Any) {
        var error = false
        // Check that the item name is valid
        if (itemName.stringValue == "") {
            itemName.highlight(color: NSColor.red)
            itemName.shake(duration: 0.5)
        }
        else {
            itemName.highlight(color: NSColor.clear)
        }
        // Check that the cost is valid
        if (cost.stringValue == "") {
            cost.highlight(color: NSColor.red)
            cost.shake(duration: 0.5)
            error = true
        }
        else {
            cost.highlight(color: NSColor.clear)
        }
        if (error) {
            return
        }
        // Checks have passed.  Create the item.
        newItem = Item(name: itemName.stringValue, cost: cost.floatValue, isPersonal: isPersonalBox.state.rawValue == 1 ? true : false , paidBy: people[peopleDropDown.indexOfSelectedItem])
        guard let window = self.view.window, let parent = window.sheetParent else { return }
        parent.endSheet(window, returnCode: .OK)
    }
    
    @IBAction func cancel(_ sender: Any) {
        guard let window = self.view.window, let parent = window.sheetParent else { return }
        parent.endSheet(window, returnCode: .cancel)
    }
    
}
