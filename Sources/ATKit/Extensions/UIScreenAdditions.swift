//
//  UIScreenAdditions.swift
//  ATKit
//
//  Created by Rupendra on 14/06/22.
//  Copyright © 2021 Rupendra. All rights reserved.
//

import UIKit


public extension UIScreen {
    
    enum ScreenSizeType :String {
        case iPhoneSmall
        case iPhoneMedium
        case iPhoneLarge
        case iPadSmall
        case iPadMedium
        case iPadLarge
    }
    
    var screenSizeType :ScreenSizeType {
        var aReturnVal = ScreenSizeType.iPhoneMedium
        
        let aPpi = UIScreen.main.scale * (UIDevice.current.userInterfaceIdiom == .pad ? 132 : 163)
        let aScreenWidth = UIScreen.main.bounds.size.width * UIScreen.main.scale
        let aScreenHeight = UIScreen.main.bounds.size.height * UIScreen.main.scale
        let aScreenWidthPpi = aScreenWidth / aPpi
        let aScreenHeightPpi = aScreenHeight / aPpi
        let aScreenDiagonal = sqrt(pow(aScreenWidthPpi, 2) + pow(aScreenHeightPpi, 2))
        if aScreenDiagonal <= 4.5 {
            // iPhone 5, SE
            aReturnVal = ScreenSizeType.iPhoneSmall
        } else if aScreenDiagonal > 4.5 && aScreenDiagonal <= 5.0 {
            // iPhone 6, 6S, 7, 8, 12 mini
            aReturnVal = ScreenSizeType.iPhoneMedium
        } else if aScreenDiagonal > 5.0 && aScreenDiagonal <= 7.0 {
            // iPhone 6 Plus, 6S Plus, 7 Plus, 8 Plus, iPhone X 5.8, iPhone 12 6.1, iPhone 12 Max 6.7
            aReturnVal = ScreenSizeType.iPhoneLarge
        } else if aScreenDiagonal > 7.0 && aScreenDiagonal <= 10.0 {
            // iPad Mini 7.9
            aReturnVal = ScreenSizeType.iPadSmall
        } else if aScreenDiagonal > 10.0 && aScreenDiagonal <= 11.5 {
            // iPad 10.2, iPad Air 10.5, 10.9
            aReturnVal = ScreenSizeType.iPadMedium
        } else if aScreenDiagonal > 11.5 {
            // iPad Pro 12.9
            aReturnVal = ScreenSizeType.iPadLarge
        }
        
        return aReturnVal
    }
}
