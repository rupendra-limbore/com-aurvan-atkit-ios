//
//  DateAdditions.swift
//  ATKit
//
//  Created by Rupendra on 23/06/21.
//  Copyright © 2021 Rupendra. All rights reserved.
//

import Foundation


public extension Date {
    
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
