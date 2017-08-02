//
//  Event.swift
//  Guests
//
//  Created by Mikołaj Stępniewski on 31.07.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import UIKit

struct Event {
    var key: String
    var name: String
    
    init(key: String, name: String) {
        self.key = key
        self.name = name
    }
}
