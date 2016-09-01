//
//  DateExtension.swift
//  scenested-experiment
//
//  Created by Xie kesong on 8/18/16.
//  Copyright © 2016 ___Scenested___. All rights reserved.
//

import Foundation

extension NSDate {
    struct Date {
        static let timeFormatter: NSDateFormatter = {
            let df = NSDateFormatter()
            df.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
            df.dateFormat = "h:mm a"
            return df
        }()
    }
    var time: String { return Date.timeFormatter.stringFromDate(self) }
    
    var year:    Int { return NSCalendar.autoupdatingCurrentCalendar().component(.Year,   fromDate: self) }
    var month:   Int { return NSCalendar.autoupdatingCurrentCalendar().component(.Month,  fromDate: self) }
    var day:     Int { return NSCalendar.autoupdatingCurrentCalendar().component(.Day,    fromDate: self) }
    
    struct DateComponents {
        static let formatter: NSDateComponentsFormatter = {
            let dcFormatter = NSDateComponentsFormatter()
            dcFormatter.calendar = NSCalendar(identifier: NSCalendarIdentifierISO8601)!
            dcFormatter.unitsStyle = .Short
            dcFormatter.maximumUnitCount = 1
            dcFormatter.zeroFormattingBehavior = .Default
            dcFormatter.allowsFractionalUnits = false
            dcFormatter.allowedUnits = [.Year, .Month, .Weekday, .Day, .Hour, .Minute, .Second]
            return dcFormatter
        }()
    }
    
    var elapsedTime: String {
        if timeIntervalSinceNow > -60.0  { return "Just Now" }
//        if isDateInToday                 { return "Today at \(time)" }
//        if isDateInYesterday             { return "Yesterday at \(time)" }
        
        return (DateComponents.formatter.stringFromTimeInterval(NSDate().timeIntervalSinceDate(self)) ?? "") + " ago"
    }
    var isDateInToday: Bool {
        return NSCalendar.autoupdatingCurrentCalendar().isDateInToday(self)
    }
    var isDateInYesterday: Bool {
        return NSCalendar.autoupdatingCurrentCalendar().isDateInYesterday(self)
    }
}