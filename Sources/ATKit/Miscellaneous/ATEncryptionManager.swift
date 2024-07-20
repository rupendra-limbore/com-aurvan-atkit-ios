//
//  Saadhan.swift
//  Saadhan
//
//

import Foundation
import CommonCrypto

public class ATEncryptionManager {
    
    public static var shared = ATEncryptionManager()
    
    public func randomString(length pLength: Int = 8, characterSets pCharacterSetArray: Array<CharacterSet> = [.upperCaseAlphabets, .lowerCaseAlphabets, .numbers]) -> String {
        var aReturnVal: String = ""
        let anAvailableCharacterString: Array<String> = Array(pCharacterSetArray.flatMap { $0.characters })
        let anAvailableCharacterArray = Array(anAvailableCharacterString)
        for _ in 0..<pLength {
            let aRandomInteger = Int(arc4random_uniform(UInt32(anAvailableCharacterString.count - 1)))
            aReturnVal += String(anAvailableCharacterArray[aRandomInteger])
        }
        return aReturnVal
    }
    
    public enum CharacterSet {
        case upperCaseAlphabets
        case lowerCaseAlphabets
        case numbers
        case specialCharacters
        
        private var characterString: String {
            var aReturnVal: String
            switch self {
            case .upperCaseAlphabets:
                aReturnVal = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
            case .lowerCaseAlphabets:
                aReturnVal = "abcdefghijklmnopqrstuvwxyz"
            case .numbers:
                aReturnVal = "1234567890"
            case .specialCharacters:
                aReturnVal = "~!#$%^&*()-_=+[]{}:;<>,.?"
            }
            return aReturnVal
        }
        
        var characters: Array<String> {
            var aReturnVal: Array<String>
            aReturnVal = Array(self.characterString).compactMap { String($0) }
            return aReturnVal
        }
    }
    
}


// MARK:- TOTP

extension ATEncryptionManager {
    
    public func totp(
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


// MARK:- Base32

extension ATEncryptionManager {
    
    public func base32Decode(string pString: String) throws -> Data {
        var aReturnVal: Data
        
        aReturnVal = try Base32.decode(string: pString.uppercased())
        
        return aReturnVal
    }
    
    
    public func base32Encode(data pData: Data) -> String {
        var aReturnVal: String
        
        aReturnVal = Base32.encode(data: pData)
        
        return aReturnVal
    }
    
}


// MARK:- Hash

extension ATEncryptionManager {
    
    public func md5(string pString: String) -> String {
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
    
    
    public func sha1(string pString: String) -> String {
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
    
    public func sha256(string pString: String) -> String {
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
    
    public func sha512(string pString: String) -> String {
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


// MARK:- AES

extension ATEncryptionManager {
    
    public func encryptAes(string pString: String, passKey pPassKey :String, initializationVector pInitializationVector :String? = nil, encoding pEncoding: Encoding = .base64) throws -> String {
        var aReturnVal :String
        
        aReturnVal = try self.cryptAes(operationType: kCCEncrypt, string: pString, passKey: pPassKey, initializationVector: pInitializationVector, encoding: pEncoding)
        
        return aReturnVal
    }
    
    
    public func decryptAes(string pString: String, passKey pPassKey :String, initializationVector pInitializationVector :String? = nil, encoding pEncoding: Encoding = .base64) throws -> String {
        var aReturnVal :String
        
        aReturnVal = try self.cryptAes(operationType: kCCDecrypt, string: pString, passKey: pPassKey, initializationVector: pInitializationVector, encoding: pEncoding)
        
        return aReturnVal
    }
    
    
    private func cryptAes(operationType pOperationType :Int, string pString: String, passKey pPassKey :String, initializationVector pInitializationVector :String?, encoding pEncoding: Encoding) throws -> String {
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


// MARK:- RSA

extension ATEncryptionManager {
    
    public func generateRsaSignature(string pString: String, privateKey pPrivateKey :String, encoding pEncoding: Encoding = .base64) throws -> String {
        var aReturnVal :String
        
        let aPrivateKey = try PrivateKey(pemEncoded: pPrivateKey)
        let aClearMessage = try ClearMessage(string: pString, using: .utf8)
        let aSignature = try aClearMessage.signed(with: aPrivateKey, digestType: .sha256)
        
        switch pEncoding {
        case .base64:
            aReturnVal = aSignature.data.base64EncodedString()
        case .hex:
            aReturnVal = aSignature.data.hexEncodedString()
        }
        
        return aReturnVal
    }
    
}


public extension ATEncryptionManager {
    
    enum Encoding {
        case base64
        case hex
    }
    
}
