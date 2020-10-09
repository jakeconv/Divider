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
    // TODO: Move items out of the table view and into this class
    var items = [Item]()
    
    override func windowDidLoad() {
        super.windowDidLoad()
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    @IBAction func adjustItem(_ sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 {
            // Add a new item
            // First, make sure that there are people created
            if (people.count == 0) {
                let alert = NSAlert()
                alert.messageText = "Error"
                alert.informativeText = "Please create a person before adding items."
                alert.runModal()
                return
            }
            let storyboardName = NSStoryboard.Name(stringLiteral: "Main")
            let storyboard = NSStoryboard(name: storyboardName, bundle: nil)
            let sceneIdentifier = NSStoryboard.SceneIdentifier(stringLiteral: "EditItemWindowController")
            guard let windowController = storyboard.instantiateController(withIdentifier: sceneIdentifier) as? NSWindowController,
                let newItemWindow = windowController.window, let editItemViewController = windowController.contentViewController as? EditItemViewController else { print("An error occured making the sheet view"); return }
            editItemViewController.setPeople(people)
            self.window?.beginSheet(newItemWindow, completionHandler: { (response) in if response == NSApplication.ModalResponse.OK {
                guard let newItem = editItemViewController.newItem else { return }
                print(newItem.name)
                guard let tableView = self.contentViewController as? TableViewController else { print("Unable to get view controller"); return }
                tableView.addItem(newItem)
                }})
        }
        else {
            // Remove an item
            guard let tableView = self.contentViewController as? TableViewController else { print("Unable to get view controller"); return }
            tableView.remove()
        }
    }
    
    @IBAction func editItem(_ sender: NSButton) {
        // Pull the item to be edited
        guard let tableView = self.contentViewController as? TableViewController else { print("Unable to get view controller"); return }
        if let itemToEdit = tableView.getSelectedItem() {
            let storyboardName = NSStoryboard.Name(stringLiteral: "Main")
            let storyboard = NSStoryboard(name: storyboardName, bundle: nil)
            let sceneIdentifier = NSStoryboard.SceneIdentifier(stringLiteral: "EditItemWindowController")
            guard let windowController = storyboard.instantiateController(withIdentifier: sceneIdentifier) as? NSWindowController,
                let newItemWindow = windowController.window, let editItemViewController = windowController.contentViewController as? EditItemViewController else { print("An error occured making the sheet view"); return }
            editItemViewController.setPeople(people)
            editItemViewController.editItem(itemToEdit)
            self.window?.beginSheet(newItemWindow, completionHandler: { (response) in if response == NSApplication.ModalResponse.OK {
                guard let editedItem = editItemViewController.newItem else { return }
                print(editedItem.name)
                tableView.edit(modifiedItem: editedItem)
                }})
        }
    }
    
    @IBAction func adjustPerson(_ sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 {
            // Add a new person
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
        else {
            // Remove a person
            let storyboardName = NSStoryboard.Name(stringLiteral: "Main")
            let storyboard = NSStoryboard(name: storyboardName, bundle: nil)
            let sceneIdentifier = NSStoryboard.SceneIdentifier(stringLiteral: "RemovePersonWindowController")
            guard let windowController = storyboard.instantiateController(withIdentifier: sceneIdentifier) as? NSWindowController,
                let newPersonWindow = windowController.window, let removePersonViewController = windowController.contentViewController as? RemovePersonViewController else { print("An error occured making the sheet view"); return }
            removePersonViewController.setPeople(people)
            self.window?.beginSheet(newPersonWindow, completionHandler: { (response) in if response == NSApplication.ModalResponse.OK {
                guard let personToRemove = removePersonViewController.personToRemove else { return }
                // Make sure this person is tied to no expenses
                guard let tableView = self.contentViewController as? TableViewController else { print("Unable to get view controller"); return }
                for item in tableView.items {
                    if item.paidBy == personToRemove {
                        // Person is tied to an expense.  We cannot remove this person.
                        let alert = NSAlert()
                        alert.messageText = "Error Removing Person"
                        alert.informativeText = "\(personToRemove.name) cannot be removed because this person is tied to an item.  Please remove \(item.name) or assign this cost to a different person."
                        alert.runModal()
                        return
                    }
                }
                // It is safe to remove this person.
                if let index = self.people.firstIndex(of: personToRemove) {
                    self.people.remove(at: index)
                }
                }})
        }
    }
    
    
    @IBAction func divide(_ sender: Any?) {
        // Pull the item to be edited
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

