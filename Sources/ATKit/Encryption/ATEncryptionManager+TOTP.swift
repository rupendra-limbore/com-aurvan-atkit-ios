//
//  ATEncryptionManager+TOTP.swift
//  ATKit
//
//  Created by Rupendra on 27/11/24.
//

import Foundation
import CommonCrypto

extension ATEncryptionManager {
    
    public static func totp(
        secret pSecret: String,
        length pLength: Int = 6,
        timeSpanInSeconds pTimeSpanInSeconds: Int = 30
    ) throws -> String {
        var aReturnVal: String
        
        let aLength = pLength
        let aSecretBase32DecodedData = try self.base32Decode(string: pSecret)
        let aTimeInterval = TimeInterval(pTimeSpanInSeconds)
        
        var aCounter = UInt64(Date().timeIntervalSince1970 / aTimeInterval).bigEndian
        let aKeyData = Data(bytes: &aCounter, count: MemoryLayout.size(ofValue: aCounter))
        
        let aHashAlgorithm = CCHmacAlgorithm(kCCHmacAlgSHA1)
        let aHashLength = Int(CC_SHA1_DIGEST_LENGTH)
        
        let aHashPointer = UnsafeMutablePointer<Any>.allocate(capacity: Int(aHashLength))
        defer {
            aHashPointer.deallocate()
        }
        let aCounterData = Swift.withUnsafeBytes(of: &aCounter) { Array($0) }
        aSecretBase32DecodedData.withUnsafeBytes { pSecretByte in
            // Generate the key from the counter value.
            aCounterData.withUnsafeBytes { pCounterByte in
                CCHmac(aHashAlgorithm, pSecretByte.baseAddress, aSecretBase32DecodedData.count, pCounterByte.baseAddress, aKeyData.count, aHashPointer)
            }
        }
        
        let aHashData = Data(bytes: aHashPointer, count: Int(aHashLength))
        
        var aTruncatedHash = aHashData.withUnsafeBytes { pPointer -> UInt32 in
            let anOffset = pPointer[aHashData.count - 1] & 0x0F
            let aTruncatedHashPointer = pPointer.baseAddress! + Int(anOffset)
            return aTruncatedHashPointer.bindMemory(to: UInt32.self, capacity: 1).pointee
        }
        aTruncatedHash = UInt32(bigEndian: aTruncatedHash)
        aTruncatedHash = aTruncatedHash & 0x7FFF_FFFF
        aTruncatedHash = aTruncatedHash % UInt32(pow(10, Float(aLength)))
        
        aReturnVal = String(format: "%0*u", aLength, aTruncatedHash)
        
        return aReturnVal
    }
    
}
