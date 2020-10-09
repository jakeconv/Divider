//
//  RemovePersonViewController.swift
//  Divider
//
//  Created by Jake Convery on 10/4/20.
//  Copyright © 2020 Jake Convery. All rights reserved.
//

import Cocoa

class RemovePersonViewController: NSViewController {

    var people = [Person]()
    var personToRemove: Person?
    
    @IBOutlet var peopleDropDown: NSPopUpButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func setPeople(_ people: [Person]) {
        self.people = people
        for person in people {
            peopleDropDown.addItem(withTitle: person.name)
        }
        
    }
    @IBAction func remove(_ sender: Any) {
        personToRemove = people[peopleDropDown.indexOfSelectedItem]
        guard let window = self.view.window, let parent = window.sheetParent else { return }
        parent.endSheet(window, returnCode: .OK)
    }
    
    @IBAction func cancel(_ sender: Any) {
        guard let window = self.view.window, let parent = window.sheetParent else { return }
        parent.endSheet(window, returnCode: .cancel)
    }
    
}
