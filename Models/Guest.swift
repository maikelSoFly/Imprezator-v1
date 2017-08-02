//
//  Guest.swift
//  Guests
//
//  Created by Mikołaj Stępniewski on 04.07.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import UIKit

class Guest: NSObject {
    var name: String!
    var isChecked: Bool!
    var addedBy: String!
    var price: Int
    var key: String!
    
    init(name: String, withKey key: String, from addedBy: String, payed price: Int, isChecked: Bool) {
        self.name = name
        self.price = price
        self.addedBy = addedBy
        self.isChecked = isChecked
        self.key = key
    }
}
