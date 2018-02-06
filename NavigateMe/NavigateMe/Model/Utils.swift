//
//  Utils.swift
//  NavigateMe
//
//  Created by mahbub on 2/4/18.
//  Copyright © 2018 Fulda University Of Applied Sciences. All rights reserved.
//

import Foundation

class Utils {
    
    private enum TimeType {
        
        case OPEN, CLOSE
    }
    
    static private let dateFormatter = DateFormatter()
    static private let universityOpenTime = "08:00"
    static private let universityCloseTime = "20:30"
    
    
    
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
    
    static func secondToDateString(_ second: TimeInterval, format: String) -> String {
        
        dateFormatter.dateFormat = format
        let date = Date(timeIntervalSince1970: second)
        return dateFormatter.string(from: date)
    }
    
    static func dateToTime(_ date: Date) -> Date {
        
        dateFormatter.dateFormat = "HH:mm"
        let strTime = dateFormatter.string(from: date)
        return dateFormatter.date(from: strTime)!
    }
    
    static private func universityTime(of what: TimeType) -> Date {
     
        dateFormatter.dateFormat = "HH:mm"
        
        switch what {
            case .OPEN:
                return dateFormatter.date(from: Utils.universityOpenTime)!
            
            case .CLOSE:
                return dateFormatter.date(from: Utils.universityCloseTime)!
        }
    }
    
    static func defaultFreeDuration() -> TimeInterval {
        
        return Utils.universityTime(of: .CLOSE).timeIntervalSince1970 - Utils.universityTime(of: .OPEN).timeIntervalSince1970
    }
    
    static func freeDurationTillUniversityClose(from date: Date) -> TimeInterval {
        
        return Utils.universityTime(of: .CLOSE).timeIntervalSince1970 - Utils.dateToTime(date).timeIntervalSince1970
    }
    
    static func withinUniversityTime(_ date: Date) -> Bool {
        
        let time = Utils.dateToTime(date)
        let universityOpenTime = Utils.universityTime(of: .OPEN)
        let universityCloseTime = Utils.universityTime(of: .CLOSE)
        
        return (time == universityOpenTime || time > universityOpenTime) && time < universityCloseTime
    }
    
}
