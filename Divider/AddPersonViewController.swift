//
//  EditPersonViewController.swift
//  Divider
//
//  Created by Jake Convery on 9/24/20.
//  Copyright © 2020 Jake Convery. All rights reserved.
//

import Cocoa

class AddPersonViewController: NSViewController {

    @IBOutlet var nameField: NSTextField!
    
    var newPerson: Person?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func addOrEdit(_ sender: Any) {
        if (nameField.stringValue == "") {
            // User must enter in a name.  Highlight the field red.
            nameField.highlight(color: NSColor.red)
            nameField.shake(duration: 0.5)
            return
        }
        newPerson = Person(name: nameField.stringValue)
        guard let window = self.view.window, let parent = window.sheetParent else { return }
        parent.endSheet(window, returnCode: .OK)
    }
    
    @IBAction func cancel(_ sender: Any) {
        guard let window = self.view.window, let parent = window.sheetParent else { return }
        parent.endSheet(window, returnCode: .cancel)
    }
    
}
