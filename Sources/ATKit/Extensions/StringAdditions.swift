//
//  StringAdditions.swift
//  ATKit
//
//  Created by Rupendra on 23/06/21.
//  Copyright © 2021 Rupendra. All rights reserved.
//

import Foundation
import CommonCrypto


public extension String {
    
    subscript(_ pRange: CountableRange<Int>) -> String {
        let aStart = index(startIndex, offsetBy: max(0, pRange.lowerBound))
        let anEnd = index(aStart, offsetBy: min(self.count - pRange.lowerBound, pRange.upperBound - pRange.lowerBound))
        return String(self[aStart..<anEnd])
    }

    subscript(_ pRange: CountablePartialRangeFrom<Int>) -> String {
        let aStart = index(startIndex, offsetBy: max(0, pRange.lowerBound))
        return String(self[aStart...])
    }
    
}
