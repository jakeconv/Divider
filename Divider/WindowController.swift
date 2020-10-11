//
//  WindowController.swift
//  Divider
//
//  Created by Jake Convery on 9/15/20.
//  Copyright © 2020 Jake Convery. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {
    
    var pendingItem: Item?
    var people = [Person]()
    
    override func windowDidLoad() {
        super.windowDidLoad()
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    @IBAction func addItemFromMenu(_ sender: NSMenuItem) {
        // First, make sure that there are people created
        if (!checkForPeople()) {
            return
        }
        // People exist.  Prompt the user for an item
        addOrRemoveItemSheetHandler(isEdit: false)
    }
    
    @IBAction func addPersonFromMenu(_ sender: NSMenuItem) {
        // Run the add person sheet
        addOrRemovePersonSheetHandler(isRemoval: false)
    }
    
    @IBAction func addOrRemoveItem(_ sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 {
            // Add a new item
            // First, make sure that there are people created
            if (!checkForPeople()) {
                return
            }
            // People exist.  Prompt the user for an item
            addOrRemoveItemSheetHandler(isEdit: false)
        }
        else {
            // Remove an item
            guard let tableView = self.contentViewController as? TableViewController else { print("Unable to get view controller"); return }
            tableView.remove()
        }
    }
    
    @IBAction func editItem(_ sender: NSButton) {
        // Call the add or remove item sheet handler
        addOrRemoveItemSheetHandler(isEdit: true)
    }
    
    @IBAction func addOrRemovePerson(_ sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 {
            // Add a new person
            addOrRemovePersonSheetHandler(isRemoval: false)
        }
        else {
            // Remove a person
            addOrRemovePersonSheetHandler(isRemoval: true)
        }
    }
    
    @IBAction func divide(_ sender: Any?) {
        // Pull the items to be divided
        guard let tableView = self.contentViewController as? TableViewController else { print("Unable to get view controller"); return }
        // Set up the divider
        let divider = costDivider(items: tableView.items, people: people)
        let results = divider.divide()
        var resultString = "Each person is responsible for $\(String(format: "%.2f", divider.eachPersonOwes))"
        for person in results {
            resultString += "\n\(person.name) paid $\(String(format: "%.2f", person.totalPaid!)) and owes $\(String(format: "%.2f", person.amountOwed!))"
        }
        let alert = NSAlert()
        alert.messageText = "Divide Cost"
        alert.informativeText = resultString
        alert.runModal()
    }
    
    private func checkForPeople() -> Bool {
        // make sure there is at least one person
        if (people.count == 0) {
            let alert = NSAlert()
            alert.messageText = "Error"
            alert.informativeText = "Please create a person before adding items."
            alert.runModal()
            return false
        }
        // Check passed.  Return true
        return true
    }
    
    private func addOrRemoveItemSheetHandler(isEdit: Bool) {
        let storyboardName = NSStoryboard.Name(stringLiteral: "Main")
        let storyboard = NSStoryboard(name: storyboardName, bundle: nil)
        let sceneIdentifier = NSStoryboard.SceneIdentifier(stringLiteral: "EditItemWindowController")
        guard let windowController = storyboard.instantiateController(withIdentifier: sceneIdentifier) as? NSWindowController,
            let newItemWindow = windowController.window, let editItemViewController = windowController.contentViewController as? EditItemViewController else { print("An error occured making the sheet view"); return }
        editItemViewController.setPeople(people)
        if (isEdit) {
            if let itemToEdit = getSelectedItem() {
                editItemViewController.editItem(itemToEdit)
            }
            else {
                // No item was selected.  Throw an error.
                let alert = NSAlert()
                alert.messageText = "Error"
                alert.informativeText = "Please select an item to edit."
                alert.runModal()
                return
            }
        }
        self.window?.beginSheet(newItemWindow, completionHandler: { (response) in if response == NSApplication.ModalResponse.OK {
            guard let currentItem = editItemViewController.newItem else { return }
            print(currentItem.name)
            guard let tableView = self.contentViewController as? TableViewController else { print("Unable to get view controller"); return }
            if (isEdit) {
                tableView.edit(modifiedItem: currentItem)
            }
            else {
                tableView.addItem(currentItem)
            }
            }})
    }
    
    private func addOrRemovePersonSheetHandler(isRemoval: Bool) {
        if (isRemoval) {
            // Show the person removal sheet
            let storyboardName = NSStoryboard.Name(stringLiteral: "Main")
            let storyboard = NSStoryboard(name: storyboardName, bundle: nil)
            let sceneIdentifier = NSStoryboard.SceneIdentifier(stringLiteral: "RemovePersonWindowController")
            guard let windowController = storyboard.instantiateController(withIdentifier: sceneIdentifier) as? NSWindowController,
                let newPersonWindow = windowController.window, let removePersonViewController = windowController.contentViewController as? RemovePersonViewController else { print("An error occured making the sheet view"); return }
            removePersonViewController.setPeople(people)
            self.window?.beginSheet(newPersonWindow, completionHandler: { (response) in if response == NSApplication.ModalResponse.OK {
                guard let personToRemove = removePersonViewController.personToRemove else { return }
                if (self.safeToRemovePerson(personToRemove)) {
                    // It is safe to remove this person.
                    if let index = self.people.firstIndex(of: personToRemove) {
                        self.people.remove(at: index)
                    }
                }
                else {
                    // Person is not safe to remove.  Return.
                    return
                }
                }})
        }
        else {
            // Show the add person sheet
            let storyboardName = NSStoryboard.Name(stringLiteral: "Main")
            let storyboard = NSStoryboard(name: storyboardName, bundle: nil)
            let sceneIdentifier = NSStoryboard.SceneIdentifier(stringLiteral: "EditPersonWindowController")
            guard let windowController = storyboard.instantiateController(withIdentifier: sceneIdentifier) as? NSWindowController,
                let newPersonWindow = windowController.window, let editPersonViewController = windowController.contentViewController as? AddPersonViewController else { print("An error occured making the sheet view"); return }
            self.window?.beginSheet(newPersonWindow, completionHandler: { (response) in if response == NSApplication.ModalResponse.OK {
                guard let newPerson = editPersonViewController.newPerson else { return }
                print(newPerson.name)
                self.people.append(newPerson)
                }})
        }
    }
    
    private func getSelectedItem() -> Item? {
        guard let tableView = self.contentViewController as? TableViewController else { print("Unable to get view controller"); return nil }
        let selectedItem = tableView.getSelectedItem()
        return selectedItem
    }
    
    private func safeToRemovePerson(_ person: Person) -> Bool {
        // Make sure this person is tied to no expenses
        guard let tableView = self.contentViewController as? TableViewController else { print("Unable to get view controller"); return false} // If we can't get the items, assume the person can't be removed
        for item in tableView.items {
            if item.paidBy == person {
                // Person is tied to an expense.  We cannot remove this person.
                let alert = NSAlert()
                alert.messageText = "Error Removing Person"
                alert.informativeText = "\(person.name) cannot be removed because this person is tied to an item.  Please remove \(item.name) or assign this cost to a different person."
                alert.runModal()
                return false
            }
        }
        // Checks passed.  Person is safe to remove
        return true
    }
    
    }

extension NSView {
    // Borrowed from https://gist.github.com/mourad-brahim/cf0bfe9bec5f33a6ea66
    // This will allow incomplete fields to shake, indicating an error
    func shake(duration: CFTimeInterval) {
        let translation = CAKeyframeAnimation(keyPath: "transform.translation.x");
        translation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        translation.values = [-5, 5, -5, 5, -3, 3, -2, 2, 0]
        let shakeGroup: CAAnimationGroup = CAAnimationGroup()
        shakeGroup.animations = [translation]
        shakeGroup.duration = duration
        self.layer?.add(shakeGroup, forKey: "shakeIt")
    }
    // This will highlight the view
    func highlight(color: NSColor) {
        self.wantsLayer = true
        self.layer?.borderColor = color.cgColor
        self.layer?.borderWidth = 2
    }
}

