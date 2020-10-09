//
//  CostDivider.swift
//  Divider
//
//  Created by Jake Convery on 9/27/20.
//  Copyright © 2020 Jake Convery. All rights reserved.
//

import Foundation

class costDivider {
    
    var items = [Item]()
    var people = [Person]()
    var eachPersonOwes: Float = 0
    
    init(items: [Item], people: [Person]) {
        self.items = items
        self.people = people
        // Initialize optional parameters
        for i in 0 ..< people.count {
            self.people[i].amountOwed = 0
            self.people[i].totalPaid = 0
            self.people[i].totalSharableCost = 0
        }
    }
    
    func divide() -> [Person] {
        // Get the total paid by each person
        var totalSharableCost: Float = 0
        for item in items {
            for i in 0 ..< people.count {
                print("\(item.name) paid by \(item.paidBy.name)")
                print(people[i].name)
                if item.paidBy == people[i] {
                    if item.isPersonal {
                        // Personal cost.  Not included in the sharable total
                        people[i].totalPaid! += item.cost
                    }
                    else {
                        // Sharable cost.  Include in the total cost and
                        print("Not personal at all")
                        people[i].totalPaid! += item.cost
                        people[i].totalSharableCost! += item.cost
                        totalSharableCost += item.cost
                    }
                    break
                }
            }
        }
        // Divide the cost
        eachPersonOwes = totalSharableCost / Float(people.count)
        print(eachPersonOwes)
        for i in 0 ..< people.count {
            if (people[i].totalSharableCost! < eachPersonOwes) {
                people[i].amountOwed = eachPersonOwes - people[i].totalSharableCost!
            }
            else {
                people[i].amountOwed = 0
            }
        }
        return people
    }
    
}
