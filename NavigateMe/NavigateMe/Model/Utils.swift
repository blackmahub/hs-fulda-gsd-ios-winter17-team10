//
//  Utils.swift
//  NavigateMe
//
//  Created by mahbub on 2/4/18.
//  Copyright © 2018 Fulda University Of Applied Sciences. All rights reserved.
//

import Foundation

class Utils {
    
    static private let dateFormatter = DateFormatter()
    
    static private func equal(_ date1: Date, to date2: Date, using format: String) -> Bool {
        
        dateFormatter.dateFormat = format
        
        let strDate1 = dateFormatter.string(from: date1)
        let strDate2 = dateFormatter.string(from: date2)
        
        let dateOnly1 = dateFormatter.date(from: strDate1)
        let dateOnly2 = dateFormatter.date(from: strDate2)
        
        return dateOnly1! == dateOnly2!
    }
    
    static func onlyDateEqual(_ date1: Date, to date2: Date) -> Bool {
    
        return equal(date1, to: date2, using: "yyyy-MM-dd")
    }
    
    static func onlyTimeEqual(_ date1: Date, to date2: Date) -> Bool {
        
        return equal(date1, to: date2, using: "HH:mm")
    }
    
    static func millisecondToDate(_ millisecond: TimeInterval) -> Date {
        
        let second = millisecond / 1000.0
        return Date(timeIntervalSince1970: second)
    }
    
    static func defaultFreeDuration(from date: Date) -> TimeInterval {
        
    }
    
    static func universityClosingTime() -> Date {
        
    }
    
}
