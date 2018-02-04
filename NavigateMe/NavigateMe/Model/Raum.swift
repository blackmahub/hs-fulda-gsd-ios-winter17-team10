//
//  Raum.swift
//  NavigateMe
//
//  Created by mahbub on 2/4/18.
//  Copyright © 2018 Fulda University Of Applied Sciences. All rights reserved.
//

import Foundation

struct Raum {
    
    let number: Int
    var schedule = [Schedule]()
    var status = RaumStatus.FREE(0.0)
    
    init(number: Int) {
        
        self.number = number
    }
}
