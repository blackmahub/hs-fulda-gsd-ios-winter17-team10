//
//  DateExtension.swift
//  NavigateMe
//
//  Created by mahbub on 2/4/18.
//  Copyright © 2018 Fulda University Of Applied Sciences. All rights reserved.
//

import Foundation

extension Date {
    
    private enum TimeType {
        
        case OPEN, CLOSE
    }
    
    // Actual University open time is 08:00 and close time is 20:30 as per GMT+1
    static private let universityOpenTime = "07:00" // as per GMT+0
    static private let universityCloseTime = "19:30" // as per GMT+0
    
    static private func universityTime(of what: TimeType) -> Date {
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0000")
        dateFormatter.dateFormat = "HH:mm"
        
        switch what {
        case .OPEN:
            return dateFormatter.date(from: Date.universityOpenTime)!
            
        case .CLOSE:
            return dateFormatter.date(from: Date.universityCloseTime)!
        }
    }
    
    static func defaultFreeDuration() -> TimeInterval {
        
        return Date.universityTime(of: .CLOSE).timeIntervalSince1970 - Date.universityTime(of: .OPEN).timeIntervalSince1970
    }
    
    static func millisecondToDate(_ millisecond: TimeInterval) -> Date {
        
        let second = millisecond / 1000.0
        return Date(timeIntervalSince1970: second)
    }
    
    private func equal(to date2: Date, using format: String) -> Bool {
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0000")
        dateFormatter.dateFormat = format
        
        let strDate1 = dateFormatter.string(from: self)
        let strDate2 = dateFormatter.string(from: date2)
        
        let dateOnly1 = dateFormatter.date(from: strDate1)
        let dateOnly2 = dateFormatter.date(from: strDate2)
        
        return dateOnly1! == dateOnly2!
    }
    
    func onlyDateEqual(to date2: Date) -> Bool {
    
        return self.equal(to: date2, using: "yyyy-MM-dd")
    }
    
    func onlyTimeEqual(to date2: Date) -> Bool {
        
        return self.equal(to: date2, using: "HH:mm")
    }
    
    func string(format: String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0000")
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    func time() -> Date {

        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0000")
        dateFormatter.dateFormat = "HH:mm"
        let strTime = dateFormatter.string(from: self)
        return dateFormatter.date(from: strTime)!
    }
    
    func freeDurationTillUniversityClose() -> TimeInterval {

        return Date.universityTime(of: .CLOSE).timeIntervalSince1970 - self.time().timeIntervalSince1970
    }
    
    func isWithinUniversityTime() -> Bool {
        
        let time = self.time()
        let universityOpenTime = Date.universityTime(of: .OPEN)
        let universityCloseTime = Date.universityTime(of: .CLOSE)
        
        return (time == universityOpenTime || time > universityOpenTime) && time < universityCloseTime
    }
    
    func isPast() -> Bool {
        
        let today = Date()
        return self < today
    }
    
}
