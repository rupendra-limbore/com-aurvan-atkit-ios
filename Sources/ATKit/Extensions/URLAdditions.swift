//
//  URLAdditions.swift
//  ATKit
//
//  Created by Rupendra on 14/01/18.
//  Copyright © 2018 Rupendra. All rights reserved.
//

import UIKit


public extension URL {
    
    func appendingQueryItem(name pName: String, value pValue :String?) -> URL {
        var aReturnVal = self
        
        if var aUrlComponents = URLComponents(string: self.absoluteString) {
            if aUrlComponents.queryItems == nil {
                aUrlComponents.queryItems = []
            }
            aUrlComponents.queryItems!.append(URLQueryItem(name: pName, value: pValue))
            if let aUrl = aUrlComponents.url {
                aReturnVal = aUrl
            }
        }
        
        return aReturnVal
    }
    
    
    func appendingQueryItems(_ pItems :Array<URLQueryItem>) -> URL {
        var aReturnVal = self
        
        for anItem in pItems {
            aReturnVal = aReturnVal.appendingQueryItem(name: anItem.name, value: anItem.value)
        }
        
        return aReturnVal
    }
    
}
