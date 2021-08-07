//
//  UIDeviceAdditions.swift
//  ATKit
//
//  Created by Rupendra on 23/06/21.
//  Copyright © 2021 Rupendra. All rights reserved.
//

import UIKit


public extension UIDevice {
    
    var isSimulator :Bool {
        return ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] != nil
    }
    
    var isMac :Bool {
        var aReturnVal = false
        if #available(macOS 11.0, *)  {
            aReturnVal = true
        }
        return aReturnVal
    }
    
}
