//
//  UIViewAdditions.swift
//  ATKit
//
//  Created by Rupendra on 14/01/18.
//  Copyright © 2018 Rupendra. All rights reserved.
//

#if canImport(UIKit)
import UIKit

public extension UIView {
    
    func firstResponder() -> UIView? {
        var aReturnVal :UIView? = nil
        
        if self.isFirstResponder {
            aReturnVal = self
        } else {
            for aSubview in self.subviews {
                if let aFirstResponder = aSubview.firstResponder() {
                    aReturnVal = aFirstResponder
                    break
                }
            }
        }
        
        return aReturnVal
    }
    
}

#endif
