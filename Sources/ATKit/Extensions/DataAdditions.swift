//
//  File.swift
//  ATKit
//
//  Created by Rupendra on 21-08-2023.
//  Copyright © 2023 Rupendra. All rights reserved.
//

import Foundation


public extension Data {
    
    init(hexEncoded pHexEncoded: String) {
        var aHexString = pHexEncoded
        var aData = Data()
        while(aHexString.count > 0) {
            let aSubIndex = aHexString.index(aHexString.startIndex, offsetBy: 2)
            let aSubString = String(aHexString[..<aSubIndex])
            aHexString = String(aHexString[aSubIndex...])
            var aChar32: UInt32 = 0
            Scanner(string: aSubString).scanHexInt32(&aChar32)
            var aChar = UInt8(aChar32)
            aData.append(&aChar, count: 1)
        }
        self = aData
    }
    
    struct HexEncodingOptions: OptionSet {
        public let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    
    func hexEncodedString(options pOptions: HexEncodingOptions = []) -> String {
        let aFormat = pOptions.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return self.map { String(format: aFormat, $0) }.joined()
    }
    
}
