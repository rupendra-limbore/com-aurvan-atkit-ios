//
//  ATEncryptionManager+Encoding.swift
//  ATKit
//
//  Created by Rupendra on 27/11/24.
//

import Foundation
import CommonCrypto

extension ATEncryptionManager {
    
    public static func base32Decode(string pString: String) throws -> Data {
        var aReturnVal: Data
        
        aReturnVal = try Base32.decode(string: pString.uppercased())
        
        return aReturnVal
    }
    
    
    public static func base32Encode(data pData: Data) -> String {
        var aReturnVal: String
        
        aReturnVal = Base32.encode(data: pData)
        
        return aReturnVal
    }
    
}


public extension ATEncryptionManager {
    
    enum Encoding {
        case base64
        case hex
    }
    
}
