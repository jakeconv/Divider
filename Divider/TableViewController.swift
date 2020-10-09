//
//  TableViewController.swift
//  Divider
//
//  Created by Jake Convery on 9/15/20.
//  Copyright © 2020 Jake Convery. All rights reserved.
//

import Cocoa

class TableViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    // Table view outlet
    @IBOutlet var tableView: NSTableView!
    
    // Array of items
    var items = [Item]()
    var people = [Person]()
    
    var totalCost: String {
        var sum: Float = 0
        for item in items {
            sum += item.cost
        }
        return String(format: "%.2f", sum/2)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let vw = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else {
            print("An error done occurred")
            return nil
        }
        if tableColumn?.title == "Item Name" {
            // We're looking for the item name.  Add in the name of the expense.
            vw.textField?.stringValue = items[row].name
        }
        else if tableColumn?.title == "Cost" {
            // We're looking for the item cost.
            vw.textField?.stringValue = "$\(items[row].cost)"
        }
        else if tableColumn?.title == "Paid By" {
            // We're looking for the person who paid
            vw.textField?.stringValue = items[row].paidBy.name
        }
        else {
            // We're looking to see if this is a personal expense
            if items[row].isPersonal {
                vw.textField?.stringValue = "Yes"
            }
            else {
                vw.textField?.stringValue = "No"
            }
        }
        return vw
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return items.count
    }
    
    func addItem(_ newItem: Item) {
        items.append(newItem)
        tableView.insertRows(at: IndexSet(integer: items.count - 1), withAnimation: .slideDown)
    }
    
    func remove() {
        let id = tableView.selectedRow
        if (id == -1) {
            // No item selected
            let alert = NSAlert()
            alert.messageText = "Error"
            if (items.count == 0) {
                // No items to delete
                alert.informativeText = "There are no items to delete!"
                alert.runModal()
                return
            }
            alert.informativeText = "Please select an item to delete."
            alert.runModal()
            return
        }
        items.remove(at: id)
        tableView.removeRows(at: IndexSet(integer: id), withAnimation: .effectFade)
    }
    
    func getSelectedItem() -> Item? {
        let id = tableView.selectedRow
        if (id == -1) {
            return nil
        }
        return items[id]
    }
    
    func edit(modifiedItem: Item) {
        items[tableView.selectedRow] = modifiedItem
        tableView.reloadData()
    }

}
