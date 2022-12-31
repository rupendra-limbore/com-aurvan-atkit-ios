//
//  DateAdditions.swift
//  ATKit
//
//  Created by Rupendra on 23/06/21.
//  Copyright © 2021 Rupendra. All rights reserved.
//

import Foundation


public extension Date {
    
    /**
     Method to get formatted date.
     
     **Date format as below,**
     - yyyy: Year in four digits. E.g. 1234
     - MM: Month in two digits. E.g. 01
     - MMM: Month name in three letters. E.g. Jan
     - MMMM: Month name in full. E.g. January
     - dd: Date with prefixed zero. E.g. 01
     - E: Day name in three letter. E.g. Sun
     - HH: Hour as 24 hour clock with prefixed zero. E.g. 13
     - hh: Hour as 12 hour clock with prefixed zero. E.g. 13
     - mm: Minute in two digits. E.g. 45
     - ss: Second in two digits. E.g. 12
     - a: AM, PM in upper case. E.g. AM, PM
     - Z: Timezone in four digits with +-sign. E.g. +0530
     - z: Timezone with name and hour:minute without prefixed zero. E.g. GMT+5:30
     - ZZZZ, zzzz: Timezone with name and hour:minute with prefixed zero. E.g. GMT+05:30
     - XXX, xxx: Timezone (without Z for zero) as hour:minute with prefixed zero. E.g. +05:30
     
     **Usage Example**
     ```swift
     NSLog("Date: %@", NSDate().string(dateFormat: "EEEE, dd-MMM-yyyy 'at' hh:mm:ss a Z"))
     NSLog("Date: %@", NSDate().string(dateFormat: "EEEE, dd-MMM-yyyy 'at' hh:mm:ss a Z"), timeZone: TimeZone(identifier: "GMT"))
     ```
     
     - Parameter pDateFormat :String. Date format.
     - Parameter pLocate :Locale. Locate in which date should be formatted.
     - Parameter pTimeZone :TimeZone. TimeZone in which date should be formatted.
     
     - Returns: String. Formatted date.
     
     - SeeAlso: `init?(dateString pDateString :String, dateFormat pDateFormat :String, locate pLocate :Locale = Locale.current, timeZone pTimeZone :TimeZone = TimeZone.current)`
     */
    func string(dateFormat pDateFormat :String, locate pLocate :Locale = Locale.current, timeZone pTimeZone :TimeZone = TimeZone.current) -> String {
        var aReturnVal :String = ""
        
        let aDateFormatter = DateFormatter()
        aDateFormatter.dateFormat = pDateFormat
        aDateFormatter.locale = pLocate
        aDateFormatter.timeZone = pTimeZone
        
        aReturnVal = aDateFormatter.string(from: self)
        
        return aReturnVal
    }
    
    var startOfDay :Date {
        let aReturnVal :Date = Calendar.current.startOfDay(for: self)
        return aReturnVal
    }
    
    var endOfDay :Date {
        var aReturnVal :Date = self
        
        var aDateComponents = DateComponents()
        aDateComponents.day = 1
        aDateComponents.second = -1
        
        aReturnVal = Calendar.current.date(byAdding: aDateComponents, to: self.startOfDay)!
        
        return aReturnVal
    }
    
    var startOfMonth :Date {
        var aReturnVal :Date = self
        
        let aDateComponents = Calendar.current.dateComponents([.year, .month], from: self)
        
        if let aValue = Calendar.current.date(from: aDateComponents) {
            aReturnVal = aValue
        }
        
        return aReturnVal
    }
    
    var endOfMonth :Date {
        var aReturnVal :Date = self
        
        var aDateComponents = DateComponents()
        aDateComponents.month = 1
        aDateComponents.day = -1
        
        if let aValue = Calendar.current.date(byAdding: aDateComponents, to: self.startOfMonth) {
            aReturnVal = aValue
        }
        
        return aReturnVal
    }
    
}
