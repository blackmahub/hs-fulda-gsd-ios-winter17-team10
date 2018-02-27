//
//  Schedule.swift
//  NavigateMe
//
//  Created by mahbub on 2/4/18.
//  Copyright © 2018 Fulda University Of Applied Sciences. All rights reserved.
//

import Foundation

struct Schedule: Hashable {
    
    var beginn: Date
    var ende: Date
    
    var hashValue: Int {
        
        return Int(beginn.timeIntervalSince1970)
    }
    
    static func == (lhs: Schedule, rhs: Schedule) -> Bool {
        
        return lhs.beginn.timeIntervalSince1970 == rhs.beginn.timeIntervalSince1970
    }
    
}
