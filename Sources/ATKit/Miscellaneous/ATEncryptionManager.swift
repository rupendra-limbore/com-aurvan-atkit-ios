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


extension ATEncryptionManager {
    
    public func encryptAes(string pString: String, passKey pPassKey :String, initializationVector pInitializationVector :String = "ABCDEFGHIJKLMNOP", encoding pEncoding: Encoding = .base64) throws -> String {
        var aReturnVal :String
        
        aReturnVal = try self.cryptAes(operationType: kCCEncrypt, string: pString, passKey: pPassKey, initializationVector: pInitializationVector, encoding: pEncoding)
        
        return aReturnVal
    }
    
    
    public func decryptAes(string pString: String, passKey pPassKey :String, initializationVector pInitializationVector :String = "ABCDEFGHIJKLMNOP", encoding pEncoding: Encoding = .base64) throws -> String {
        var aReturnVal :String
        
        aReturnVal = try self.cryptAes(operationType: kCCDecrypt, string: pString, passKey: pPassKey, initializationVector: pInitializationVector, encoding: pEncoding)
        
        return aReturnVal
    }
    
    
    private func cryptAes(operationType pOperationType :Int, string pString: String, passKey pPassKey :String, initializationVector pInitializationVector :String, encoding pEncoding: Encoding) throws -> String {
        var aReturnVal :String
        
        if pPassKey.count != 32 {
            throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "For AES-256 the pass-key must of 32 character length."])
        }
        if pInitializationVector.count != 16 {
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
        let anIvString = pInitializationVector
        let anIvData: Data = anIvString.data(using: String.Encoding.utf8)!
        
        let aPassKeyString = pPassKey
        let aPassKeyData: Data = aPassKeyString.data(using: String.Encoding.utf8)!
        let aPassKeyLength = aPassKeyData.count
        
        let anOperation = CCOperation(pOperationType)

        let aCryptLength = aData.count + kCCBlockSizeAES128
        var aCryptData = Data(count: aCryptLength)
        
        let aCryptOptions = CCOptions(kCCOptionPKCS7Padding)

        var aByteLength = Int(0)
        
        let aResultStatus = aCryptData.withUnsafeMutableBytes { pCryptBytes in
            aData.withUnsafeBytes { pDataBytes in
                anIvData.withUnsafeBytes { pIvBytes in
                    aPassKeyData.withUnsafeBytes { pKeyBytes in
                    CCCrypt(anOperation, CCAlgorithm(kCCAlgorithmAES), aCryptOptions, pKeyBytes.baseAddress, aPassKeyLength, pIvBytes.baseAddress, pDataBytes.baseAddress, aData.count, pCryptBytes.baseAddress, aCryptLength, &aByteLength)
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


public extension ATEncryptionManager {
    
    enum Encoding {
        case base64
        case hex
    }
    
}


//
//    Base32.swift
//
//    MIT License
//
//    Copyright (c) 2018 Mark Renaud
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.

import Foundation

fileprivate enum Base32Error: Error {
    case invalidBase32String
    case invalidBase32PaddedStringLength
}

fileprivate struct Base32 {
    
    fileprivate static let encodingTable = [
    //   0    1    2    3    4    5    6    7
        "A", "B", "C", "D", "E", "F", "G", "H",
    //   8    9    10   11   12   13   14   15
        "I", "J", "K", "L", "M", "N", "O", "P",
    //   16   17   18   19   20   21   22   23
        "Q", "R", "S", "T", "U", "V", "W", "X",
    //   24   25   26   27   28   29   30   31
        "Y", "Z", "2", "3", "4", "5", "6", "7"]
    
    fileprivate static let decodingTable: [Character:String] = [
        "A": "00000",
        "B": "00001",
        "C": "00010",
        "D": "00011",
        "E": "00100",
        "F": "00101",
        "G": "00110",
        "H": "00111",
        "I": "01000",
        "J": "01001",
        "K": "01010",
        "L": "01011",
        "M": "01100",
        "N": "01101",
        "O": "01110",
        "P": "01111",
        "Q": "10000",
        "R": "10001",
        "S": "10010",
        "T": "10011",
        "U": "10100",
        "V": "10101",
        "W": "10110",
        "X": "10111",
        "Y": "11000",
        "Z": "11001",
        "2": "11010",
        "3": "11011",
        "4": "11100",
        "5": "11101",
        "6": "11110",
        "7": "11111"
    ]

    /**
     Returns the index(es) and offsets of the quintet of bits from
     an array of octets (Bytes) aka `[UInt8]`
     - Note:                    if the quintet of bits is fully
                                contained within an octet, the
                                `octet2Index` will be nil
     - Parameter quintetIndex:  the index (0-based) quintet-bit
                                sequence to map against the indexes
                                (0-based) of octet-bit sequences
     - Returns:                 mapped octet-bit indexes of the `UInt8`s
                                involved and the offset of the quintet-bits
                                in the first octet
     - Important:               For better understanding - see block below
     ````
     +---------+----------+---------+
     |01234 567|01 23456 7|0123 4567|   Octets Offset
     +---------+----------+---------+
     |01110 110|11 00000 1|1111 1010|   Octet Data Bits
     +---------+----------+---------+
     |< 1 > < 2| > < 3 > <|.4 > < 5.|>  Quintets
     +---------+----------+---------+-+
     |01110|110 11|00000|1 1111|1010  | Quintent Data Bits
     +-----+------+-----+------+------+
                                <====> 5th character
                         <====> 4th character
                  <===> 3rd character
            <====> 2nd character
      <===> 1st character
     
     
     Thus, for 3 octets (bytes) of data we will have 5 quintets
     ````
     */
    fileprivate static func octetsForQuintet(_ quintetIndex: Int) -> (octet1Index: Int, octet2Index: Int?, bitOffset: Int) {
        let octetIndex = (quintetIndex * 5) / 8
        let octetBitOffset = (quintetIndex * 5) % 8
        let overhangsOctet = octetBitOffset > 3
        
        return (
            octet1Index: octetIndex,
            octet2Index: (overhangsOctet ? octetIndex + 1 : nil),
            bitOffset: octetBitOffset
        )
    }
    
    
    /**
     Joins two bytes together to form a 16-bit UInt
     - Parameter leadingByte:   an octet of bits (`UInt8`) that will
                                represent the leading 8-bits of resultant
                                `UInt16`
     - Parameter trailingByte:  an octet of bits (`UInt8`) that will
                                represent the trailing 8-bits of resultant
                                `UInt16`
     - Returns:                 the combined 8-bit bytes as a 16-bit `UInt16`
     - Note:                    example combination
     ````
     leadingByte     = 0b00000001            // 1
     trailingByte    =         0b10000001    // 129
     result          = 0b0000000110000001    // 385
     ````
     */
    fileprivate static func combineUInt8(leadingByte: UInt8, trailingByte: UInt8) -> UInt16 {
        // convert the leadingByte to UInt16 and bitshift it 8 positions
        // using the example from function documentation:
        // UInt8: 00000001 convert to UInt16: 00000000 00000001
        // bitshift UInt16 by 8: (- 00000000) 00000001 (+ 00000000) = 00000001 00000000
        let a16bit:UInt16 = UInt16(leadingByte) << 8 // eg. 00000001 00000000
        // convert the trailingByte to 16 bit
        // using the example from function documentation:
        // UInt8: 10000001 convert to UInt16: 00000000 10000001
        let b16bit:UInt16 = UInt16(trailingByte)      // 00000000 10000001
        // bitwise OR sextetPartA and sextetPartB
        // to give final combined UInt16
        let combined = a16bit | b16bit       // 00000001 10000001
        return combined
    }
    
    
    /**
     Retrieves a number of bits from a given `UInt16` and returns the
     representation of those bits as `UInt16`.  See the note for a worked
     example.
     - Parameter numberOfBits:  the number of bits to retrieve
     - Parameter from:          the 16-bit `UInt16` from which to retrieve
                                the bits
     - Parameter offset:        the offset of the bits to retrieve from
                                the leading bit
     - Returns:                 the desired bits placed as trailing bits
                                within a 16-bit integer
     - Note:                    example of retrieving 5 bits offset from
                                the leading bit by 3
     ````
     16-bit     = 0111010011110100         = 0b0111010011110100 -> 29940
     desired    = ---10100--------         = 0b10100            -> 20
     
     we can acheive this by bitshifting left by the offset (3)
     then bitshifting right by (16 - numberOfBits(5)) = (11)
     and then the trailing 5-bits will be our desired bits
     
     0111010011110100 << 3  = (-011) 1010011110100 (+ 000)
     = 1010011110100000
     1010011110100000 >> 11 = (+00000000000) 10100 (- 11110100000)
     0000000000010100       = 20 (desired result)
     ````
     */
    fileprivate static func getBitValue(numberOfBits:UInt16, from originalBits: UInt16, offset: UInt16) -> UInt16 {
        return (originalBits << offset) >> (16 - numberOfBits)
    }
    
    /**
     Converts a data array to an array of 5-bit values held in a `UInt8` array.
     - Note: max value of any number in the resultant aray will be
             `0b00011111` = `31` as we will be only using the 5-bits
             of the `UInt8`.  If there are not enough bits in the `UInt8`
             array to fill up the last 5-bit value, it should be padded
             with trailing `0`s (see example below)
     ````
     Example 8-bit byte data:
     [01110100] [11110111]
     
     Broken into 5-bits
     |01110 100|11 11011 1|
     |01110|100 11|11011|1 0000|
                           ^^^^ padding 0s
     Which will be stored as trailing bits in `UInt8` array
     [00001110] [00010011]  [00011011]  [00010000]
     = 14       = 19        = 27        = 16
     
     ````
     */
    fileprivate static func dataTo5BitValueArray(data: Data) -> [UInt8] {
        let totalBits = data.count * 8
        let totalQuintets = Int(ceil(Double(totalBits) / 5.0))
        
        var quintets:[UInt8] = []
        var representation:[String] = []
        for quintetIndex in 0..<totalQuintets {
            let mapping = octetsForQuintet(quintetIndex)
            
            let leadingByte: UInt8 = data[mapping.octet1Index]
            var trailingByte: UInt8 = 0
            
            // if spans quintets
            if let octet2Index = mapping.octet2Index {
                if octet2Index < data.count {
                    trailingByte = data[octet2Index]
                } else {
                    trailingByte = 0
                }
            }
            let twoBytes = combineUInt8(leadingByte: leadingByte, trailingByte: trailingByte)
            
            let requiredBits = getBitValue(numberOfBits: 5, from: twoBytes, offset: UInt16(mapping.bitOffset))
            quintets.append(UInt8(requiredBits))
            representation.append(encodingTable[Int(requiredBits)])
        }
        
        return quintets
    }
    
    /**
     Converts bytes of data into a Base32 encoded string based on RFC3548
     - parameter data:      the `Data` to encode
     - parameter padding:   a boolean representing whether the padding character
                            (`=`) should be appended to bring the number of
                            characters in the string to a multiple of 8 (`false`
                            by default)
     - returns:             `String` containing the Base32 encoded data
     */
    fileprivate static func encode(data: Data, padding: Bool = false) -> String {
        let mapped = dataTo5BitValueArray(data: data).map { (inputBits) -> String in
            return encodingTable[Int(inputBits)]
        }
        
        var encodedString = mapped.joined()
        if padding {
            let modulo = mapped.count % 8
            if modulo > 0 {
                let padding = String(repeating: "=", count: (8 - modulo))
                encodedString += padding
            }
        }
        
        return encodedString
    }
    
    /**
     Converts Base32 string (RFC3548) into bytes of data
     - parameter string:    the Base32 string to decode
     - parameter padded:    a boolean representing whether the Base32 string is padded:
                            ie. (`=`) is appended to bring the number of characters in
                            the string to a multiple of 8. (`false`by default)
     - returns:             `Data` containing the Base32 encoded data
     - throws:              if the string is not a valid base32 string (or correct size if padded)
     */
    fileprivate static func decode(string encodedString: String, padded: Bool = false) throws -> Data {
        
        // Verify string size is a multiple of 8 if we expect padding
        if padded {
            guard encodedString.count % 8 == 0 else {
                throw Base32Error.invalidBase32PaddedStringLength
            }
        }
        
        // Verify string only contains valid Base32 characters (allow `=` as a valid character
        // if a padded string
        var validCharacters = CharacterSet(charactersIn: Base32.encodingTable.joined())
        if padded {
            validCharacters.insert("=")
        }
        let stringCharacters = CharacterSet(charactersIn: encodedString)
        
        guard stringCharacters.isSubset(of: validCharacters) else {
            throw Base32Error.invalidBase32String
        }
        
        var strippedEncodedString = encodedString
        if padded {
            // remove trailing `=`
            if let leadingCharacters = strippedEncodedString.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: true).first {
                strippedEncodedString = String(leadingCharacters)
            }
        }

        // create a long binary string from the decoded character quintets
        // we can use ! here as we are guaranteed to only have characters in the decoding table
        // by character set guarding above
        let binaryString = strippedEncodedString.map { decodingTable[$0]! }.joined()
        
        // break into binary octets - note the last octet may be less than 8 characters
        // we can discard it - as it is additional '0's not required
        var octetStrings = stride(from: 0, to: binaryString.count, by: 8).map { (startPosition) -> String in
            let startIndex = binaryString.index(binaryString.startIndex, offsetBy: startPosition)
            let endPosition = min(startPosition + 8, binaryString.count)
            let endIndex = binaryString.index(binaryString.startIndex, offsetBy: endPosition)
            let octetString = String(binaryString[startIndex..<endIndex])
            return octetString
        }
        
        // discard any non-complete octet
        if let lastOctet = octetStrings.last {
            if lastOctet.count < 8 {
                let _ = octetStrings.popLast()
            }
        }
        
        // convert octet strings to bytes
        let bytes = octetStrings.map { (octetString) -> UInt8 in
            return UInt8(octetString, radix: 2) ?? 0
        }
        
        
        return Data(bytes)

    }

    
}

extension Data {
    /**
     Returns Base32 encoded string representation of the data (based on
     RFC3548)
     - parameter padded:    a boolean representing whether the padding
                            character (`=`) should be appended to bring the total
                            number of characters in the string to a multiple of 8
                            (`false` by default)
     */
    fileprivate func base32String(padded: Bool = false) -> String {
        return Base32.encode(data: self, padding: padded)
    }
}

extension String {
    /**
     Decodes a Base32 `String` into `Data` (based on RFC3548)
     - parameter padded:    a boolean representing whether the Base32 string is padded:
     ie. (`=`) is appended to bring the number of characters in
     the string to a multiple of 8. (`false`by default)
     - throws:              if the string is not a valid base32 string (or correct size if padded)
    */
    fileprivate func decodeBase32(padded: Bool = false) throws -> Data {
        return try Base32.decode(string: self, padded: padded)
    }
}
