//
//  ATKeychainManager.swift
//  DEFT
//
//  Created by Rupendra on 29/08/20.
//  Copyright © 2020 Rupendra. All rights reserved.
//

import UIKit
import Security


open class ATKeychainManager: NSObject {

    public static var shared :ATKeychainManager = {
        return ATKeychainManager()
    }()
    
    
    public func save(key pKey :String, value pValue :String, service pService: String? = nil) -> Error? {
        var aReturnVal :Error? = nil
        
        if UIDevice.current.isSimulator {
            aReturnVal = NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "Keychain is not supported on simulator."])
        } else {
            // For a keychain item of class kSecClassGenericPassword, the primary key is the combination of kSecAttrAccount and kSecAttrService.
            var aDict :[String:AnyObject] = [:]
            aDict[kSecClass as String] = kSecClassGenericPassword as AnyObject
            aDict[kSecAttrAccount as String] = pKey as AnyObject
            aDict[kSecAttrService as String] = pService as AnyObject
            aDict[kSecValueData as String] = pValue.data(using: String.Encoding.utf8) as AnyObject
            SecItemDelete(aDict as CFDictionary)
            var aResult : AnyObject?
            let aStatus = SecItemAdd(aDict as CFDictionary, &aResult)
            if aStatus != Security.errSecSuccess {
                var anErrorReason :String? = nil
                if #available(iOS 11.3, *) {
                    if let aValue = SecCopyErrorMessageString(aStatus, nil) {
                        anErrorReason = aValue as String
                    }
                }
                if anErrorReason == nil {
                    if aStatus == Security.errSecReadOnly {
                        anErrorReason = "Read-only error."
                    } else if aStatus == Security.errSecAuthFailed {
                        anErrorReason = "Authorization and/or authentication failed."
                    } else if aStatus == Security.errSecNoSuchKeychain {
                        anErrorReason = "The keychain does not exist."
                    }
                }
                let anErrorMessage = String(format: "Can not save data. %@ Code: %d.", anErrorReason ?? "Unknown error.", aStatus)
                aReturnVal = NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : anErrorMessage])
            }
        }
        
        return aReturnVal
    }
    
    
    public func getValue(forKey pKey :String, service pService: String? = nil) -> String? {
        var aReturnVal :String? = nil
        
        if UIDevice.current.isSimulator {
            aReturnVal = nil
        } else {
            var aDict :[String:AnyObject] = [:]
            aDict[kSecClass as String] = kSecClassGenericPassword as AnyObject
            aDict[kSecAttrAccount as String] = pKey as AnyObject
            aDict[kSecAttrService as String] = pService as AnyObject
            aDict[kSecReturnAttributes as String] = true as AnyObject
            aDict[kSecReturnData as String] = true as AnyObject
            var aResult : AnyObject?
            let aStatus = SecItemCopyMatching(aDict as CFDictionary, &aResult)
            if aStatus == Security.errSecSuccess {
                if let aResultDict = aResult as? [NSString : AnyObject], let aValue = aResultDict[kSecValueData] as? Data {
                    aReturnVal = String(data: aValue, encoding: String.Encoding.utf8)
                }
            } else if aStatus == Security.errSecItemNotFound {
                aReturnVal = nil
            }
        }
        
        return aReturnVal
    }
    
    
    public func remove(valueForKey pKey :String) {
        if UIDevice.current.isSimulator {
            
        } else {
            var aDict :[String:String] = [:]
            aDict[kSecClass as String] = kSecClassGenericPassword as String
            aDict[kSecAttrAccount as String] = pKey
            SecItemDelete(aDict as CFDictionary)
        }
    }
    
}
