//
//  ATEncryptionManager+RSA.swift
//  ATKit
//
//  Created by Rupendra on 27/11/24.
//

import Foundation
import CommonCrypto

extension ATEncryptionManager {
    
    public static func generateRsaSignature(string pString: String, privateKey pPrivateKey :String, encoding pEncoding: Encoding = .base64) throws -> String {
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
    
    public static func encryptRsa(string pString: String, publicKey pPublicKey :String) throws -> String {
        var aReturnVal :String
        
        guard let aPlainTextData = pString.data(using: .utf8) else {
            throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "Can not convert plain text string into data."])
        }
        aReturnVal = try self.encryptRsa(data: aPlainTextData, publicKey: pPublicKey)
        
        return aReturnVal
    }
    
    public static func encryptRsa(data pData: Data, publicKey pPublicKey :String) throws -> String {
        var aReturnVal :String
        
        let aPublicKey = try PublicKey(pemEncoded: pPublicKey)
        let aClearMessage = ClearMessage(data: pData)
        let anEncryptedMessage = try aClearMessage.encrypted(with: aPublicKey, secKeyAlgorithm: SecKeyAlgorithm.rsaEncryptionPKCS1)
        aReturnVal = anEncryptedMessage.data.base64EncodedString()
        
        return aReturnVal
    }
    
    public static func decryptRsa(base64EncodedString pBase64EncodedString: String, privateKey pPrivateKey :String) throws -> String {
        var aReturnVal :String
        
        let aPrivateKey = try PrivateKey(pemEncoded: pPrivateKey)
        let anEncryptedMessage: EncryptedMessage = try EncryptedMessage(base64Encoded: pBase64EncodedString)
        let aClearMessage = try anEncryptedMessage.decrypted(with: aPrivateKey, secKeyAlgorithm: SecKeyAlgorithm.rsaEncryptionPKCS1)
        guard let aDecryptedString = String(data: aClearMessage.data, encoding: .utf8) else {
            throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "Can not convert decrypted data into string."])
        }
        aReturnVal = aDecryptedString
        
        return aReturnVal
    }
    
}
