//
//  Cost.swift
//  Divider
//
//  Created by Jake Convery on 9/14/20.
//  Copyright © 2020 Jake Convery. All rights reserved.
//

import Foundation


struct Item {
    
    var name: String
    var cost: Float
    var isPersonal: Bool
    var paidBy: Person
    
    init(name: String, cost: Float, isPersonal: Bool, paidBy: Person) {
        self.name = name
        self.cost = cost
        self.isPersonal = isPersonal
        self.paidBy = paidBy
    }
    
}
