//
//  ATEncryptionManager+Hash.swift
//  ATKit
//
//  Created by Rupendra on 27/11/24.
//

import Foundation
import CommonCrypto

extension ATEncryptionManager {
    
    public static func md5(string pString: String) -> String {
        var aReturnVal: String
        
        let aMessageData = pString.data(using:.utf8)!
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
    
    
    public static func sha1(string pString: String) -> String {
        var aReturnVal: String
        
        let aData = Data(pString.utf8)
        var aDigest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        aData.withUnsafeBytes {
            _ = CC_SHA1($0.baseAddress, CC_LONG(aData.count), &aDigest)
        }
        let aHexByteArray = aDigest.map { String(format: "%02hhx", $0) }
        aReturnVal = aHexByteArray.joined()
    
        return aReturnVal
    }
    
    public static func sha256(string pString: String) -> String {
        var aReturnVal: String
        
        let aData = Data(pString.utf8)
        var aDigest = [UInt8](repeating: 0, count:Int(CC_SHA256_DIGEST_LENGTH))
        aData.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(aData.count), &aDigest)
        }
        let aHexByteArray = aDigest.map { String(format: "%02hhx", $0) }
        aReturnVal = aHexByteArray.joined()
    
        return aReturnVal
    }
    
    public static func sha512(string pString: String) -> String {
        var aReturnVal: String
        
        let aData = Data(pString.utf8)
        var aDigest = [UInt8](repeating: 0, count:Int(CC_SHA512_DIGEST_LENGTH))
        aData.withUnsafeBytes {
            _ = CC_SHA512($0.baseAddress, CC_LONG(aData.count), &aDigest)
        }
        let aHexByteArray = aDigest.map { String(format: "%02hhx", $0) }
        aReturnVal = aHexByteArray.joined()
    
        return aReturnVal
    }
    
}
