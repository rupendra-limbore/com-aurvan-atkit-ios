//
//  UIImageAdditions.swift
//  ATKit
//
//  Created by Rupendra on 14/01/18.
//  Copyright © 2018 Rupendra. All rights reserved.
//

import UIKit


public extension UIImage {
    
    static func image(
        text pText :String
        , size pSize :CGSize = CGSize(width: 128.0, height: 128.0)
        , font pFont :UIFont = UIFont.systemFont(ofSize: 17.0)
        , foregroundColor pForegroundColor :UIColor = UIColor.white
        , backgroundColors pBackgroundColorArray :[UIColor] = [
            UIColor(red: 20.0/255.0, green: 130.0/255.0, blue: 126.0/255.0, alpha: 1.0)
            , UIColor(red: 78.0/255.0, green: 200.0/255.0, blue: 191.0/255.0, alpha: 1.0)
        ]
        , fontSize pFontSize :CGFloat = 50.0
    ) -> UIImage {
        let aFontSize = pFontSize
        let aFont = pFont.withSize(aFontSize)
        
        let aReturnVal = UIGraphicsImageRenderer(size: pSize).image { pContext in
            let aColorSpace = CGColorSpaceCreateDeviceRGB()
            
            let aStartColor = pBackgroundColorArray.first
            guard let aStartColorComponents = aStartColor?.cgColor.components else { return }
            let anEndColor = pBackgroundColorArray.last
            guard let anEndColorComponents = anEndColor?.cgColor.components else { return }
            let aColorComponentArray: Array<CGFloat> = [aStartColorComponents[0], aStartColorComponents[1], aStartColorComponents[2], aStartColorComponents[3], anEndColorComponents[0], anEndColorComponents[1], anEndColorComponents[2], anEndColorComponents[3]]
            
            let aLocationArray :Array<CGFloat> = [0,1]
            
            let aGradient = CGGradient(colorSpace: aColorSpace, colorComponents: aColorComponentArray, locations: aLocationArray, count: aLocationArray.count)!
            pContext.cgContext.drawLinearGradient(aGradient, start: CGPoint(x: 0.0, y: 0.0), end: CGPoint(x: pSize.width, y: pSize.height), options: .drawsBeforeStartLocation)
            
            let anAttributeArrray: [NSAttributedString.Key: Any] = [
                .font: aFont,
                .foregroundColor: pForegroundColor
            ]
            let aTextSize = (pText as NSString).size(withAttributes: anAttributeArrray)
            let anOrigin = CGPoint(x: (pSize.width - aTextSize.width) / 2.0, y: (pSize.height - aTextSize.height) / 2.0)
            (pText as NSString).draw(in: CGRect(origin: anOrigin, size: aTextSize), withAttributes: anAttributeArrray)
        }
        return aReturnVal
    }
    
}
