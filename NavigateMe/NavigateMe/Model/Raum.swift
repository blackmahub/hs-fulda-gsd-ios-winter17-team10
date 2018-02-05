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
    var schedules = [Schedule]()
    
    // free duration in second
    var status = RaumStatus.FREE(Utils.defaultFreeDuration())
    
    init(number: Int) {
        
        self.number = number
    }
    
}
