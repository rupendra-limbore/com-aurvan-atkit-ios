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
    
    var md5 :String {
        var aReturnVal = ""
        
        let aMessageData = self.data(using:.utf8)!
        var aDigestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        _ = aDigestData.withUnsafeMutableBytes { pDigestBytes -> UInt8 in
            aMessageData.withUnsafeBytes { pMessageBytes -> UInt8 in
                if let aMessageBytesBaseAddress = pMessageBytes.baseAddress
                , let aBlindMemoryBaseAddress = pDigestBytes.bindMemory(to: UInt8.self).baseAddress {
                    let aMessageLength = CC_LONG(aMessageData.count)
                    CC_MD5(aMessageBytesBaseAddress, aMessageLength, aBlindMemoryBaseAddress)
                }
                return 0
            }
        }
        aReturnVal = aDigestData.map { String(format: "%02hhx", $0) }.joined()
        
        return aReturnVal
    }
    
    var sha512 :String {
        var aReturnVal = ""
        
        let aMessageData = self.data(using:.utf8)!
        var aDigestData = Data(count: Int(CC_SHA512_DIGEST_LENGTH))
        _ = aDigestData.withUnsafeMutableBytes { pDigestBytes -> UInt8 in
            aMessageData.withUnsafeBytes { pMessageBytes -> UInt8 in
                if let aMessageBytesBaseAddress = pMessageBytes.baseAddress
                   , let aBlindMemoryBaseAddress = pDigestBytes.bindMemory(to: UInt8.self).baseAddress {
                    let aMessageLength = CC_LONG(aMessageData.count)
                    CC_SHA512(aMessageBytesBaseAddress, aMessageLength, aBlindMemoryBaseAddress)
                }
                return 0
            }
        }
        aReturnVal = aDigestData.map { String(format: "%02hhx", $0) }.joined()
        
        return aReturnVal
    }
    
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
