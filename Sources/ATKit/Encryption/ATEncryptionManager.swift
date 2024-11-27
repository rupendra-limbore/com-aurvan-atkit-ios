//
//  ATEncryptionManager.swift
//  ATKit
//
//  Created by Rupendra on 27/11/24.
//

import Foundation

public class ATEncryptionManager {
    
    public static func randomString(length pLength: Int = 8, characterSets pCharacterSetArray: Array<CharacterSet> = [.upperCaseAlphabets, .lowerCaseAlphabets, .numbers]) -> String {
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
