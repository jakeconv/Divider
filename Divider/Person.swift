//
//  Person.swift
//  Divider
//
//  Created by Jake Convery on 9/24/20.
//  Copyright © 2020 Jake Convery. All rights reserved.
//

import Foundation

struct Person: Equatable {
    var name: String
    var id: Int
    var totalPaid: Float?
    var totalSharableCost: Float?
    var amountOwed: Float?
    
    init(name: String) {
        self.name = name
        self.id = Person.getUniqueIdentifier()
    }
    
    private static var identifierFactory = 0
    
    private static func getUniqueIdentifier() -> Int {
        Person.identifierFactory += 1
        return Person.identifierFactory
    }
    
    static func == (lhs: Person, rhs: Person) -> Bool {
        return lhs.id == rhs.id
    }

}
