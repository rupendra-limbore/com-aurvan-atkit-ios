//
//  ATEncryptionManager+AES.swift
//  ATKit
//
//  Created by Rupendra on 27/11/24.
//

import Foundation
import CommonCrypto

extension ATEncryptionManager {
    
    public static func encryptAes(string pString: String, passKey pPassKey :String, initializationVector pInitializationVector :String? = nil, encoding pEncoding: Encoding = .base64) throws -> String {
        var aReturnVal :String
        
        aReturnVal = try self.cryptAes(operationType: kCCEncrypt, string: pString, passKey: pPassKey, initializationVector: pInitializationVector, encoding: pEncoding)
        
        return aReturnVal
    }
    
    
    public static func decryptAes(string pString: String, passKey pPassKey :String, initializationVector pInitializationVector :String? = nil, encoding pEncoding: Encoding = .base64) throws -> String {
        var aReturnVal :String
        
        aReturnVal = try self.cryptAes(operationType: kCCDecrypt, string: pString, passKey: pPassKey, initializationVector: pInitializationVector, encoding: pEncoding)
        
        return aReturnVal
    }
    
    
    private static func cryptAes(operationType pOperationType :Int, string pString: String, passKey pPassKey :String, initializationVector pInitializationVector :String?, encoding pEncoding: Encoding) throws -> String {
        var aReturnVal :String
        
        if pPassKey.count != 32 {
            throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "For AES-256 the pass-key must of 32 character length."])
        }
        if let aValue = pInitializationVector, aValue.count != 16 {
            throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "Initialization vector must of 16 character length."])
        }
        
        var anInputData :Data?
        if pOperationType == kCCEncrypt {
            anInputData = pString.data(using: String.Encoding.utf8)
        } else {
            switch pEncoding {
            case .base64:
                anInputData = Data(base64Encoded: pString)
            case .hex:
                anInputData = Data(hexEncoded: pString)
            }
        }
        
        guard let aData = anInputData else {
            throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : String(format: "Invalid input data.")])
        }
        let anInitializationVectorString = pInitializationVector
        let anInitializationVectorData: Data? = anInitializationVectorString?.data(using: String.Encoding.utf8)!
        
        let aPassKeyString = pPassKey
        let aPassKeyData: Data = aPassKeyString.data(using: String.Encoding.utf8)!
        let aPassKeyLength = aPassKeyData.count
        
        let anOperation = CCOperation(pOperationType)

        let aCryptLength = aData.count + kCCBlockSizeAES128
        var aCryptData = Data(count: aCryptLength)
        
        let aCryptOptions = CCOptions(kCCOptionPKCS7Padding)

        var aByteLength = Int(0)
        
        let aResultStatus: CCStatus
        if let anIvData = anInitializationVectorData {
            aResultStatus = aCryptData.withUnsafeMutableBytes { pCryptBytes in
                aData.withUnsafeBytes { pDataBytes in
                    anIvData.withUnsafeBytes { pIvBytes in
                        aPassKeyData.withUnsafeBytes { pKeyBytes in
                        CCCrypt(anOperation, CCAlgorithm(kCCAlgorithmAES), aCryptOptions, pKeyBytes.baseAddress, aPassKeyLength, pIvBytes.baseAddress, pDataBytes.baseAddress, aData.count, pCryptBytes.baseAddress, aCryptLength, &aByteLength)
                        }
                    }
                }
            }
        } else {
            aResultStatus = aCryptData.withUnsafeMutableBytes { pCryptBytes in
                aData.withUnsafeBytes { pDataBytes in
                    aPassKeyData.withUnsafeBytes { pKeyBytes in
                    CCCrypt(anOperation, CCAlgorithm(kCCAlgorithmAES), aCryptOptions, pKeyBytes.baseAddress, aPassKeyLength, nil, pDataBytes.baseAddress, aData.count, pCryptBytes.baseAddress, aCryptLength, &aByteLength)
                    }
                }
            }
        }

        if UInt32(aResultStatus) == UInt32(kCCSuccess) {
            aCryptData.removeSubrange(aByteLength..<aCryptData.count)
        } else {
            throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : String(format: "Crypt operation failed. Status: %d", aResultStatus)])
        }
        
        if pOperationType == kCCEncrypt {
            switch pEncoding {
            case .base64:
                aReturnVal = aCryptData.base64EncodedString()
            case .hex:
                aReturnVal = aCryptData.hexEncodedString()
            }
        } else if let aValue = String(data: aCryptData, encoding: .utf8) {
            aReturnVal = aValue
        } else {
            throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : String(format: "Crypt operation failed. Unknown error.")])
        }
        
        return aReturnVal
    }
    
}
