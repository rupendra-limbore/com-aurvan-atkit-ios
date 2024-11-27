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
    
}
