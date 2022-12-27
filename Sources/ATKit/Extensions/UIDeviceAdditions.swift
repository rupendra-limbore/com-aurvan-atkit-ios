//
//  UIDeviceAdditions.swift
//  ATKit
//
//  Created by Rupendra on 23/06/21.
//  Copyright © 2021 Rupendra. All rights reserved.
//

import UIKit


public extension UIDevice {
    
    var isSimulator :Bool {
        var aReturnVal = false
        #if os(iOS)
            aReturnVal = ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] != nil
        #endif
        return aReturnVal
    }
    
    var isMac :Bool {
        var aReturnVal = false
        #if os(macOS)
            aReturnVal = true
        #endif
        return aReturnVal
    }
    
    enum DeviceModel {
        case iPodTouch5thGeneration
        case iPodTouch6thGeneration
        case iPodTouch7thGeneration
        case iPhone4
        case iPhone4s
        case iPhone5
        case iPhone5c
        case iPhone5s
        case iPhone6
        case iPhone6Plus
        case iPhone6s
        case iPhone6sPlus
        case iPhone7
        case iPhone7Plus
        case iPhone8
        case iPhone8Plus
        case iPhoneX
        case iPhoneXS
        case iPhoneXSMax
        case iPhoneXR
        case iPhone11
        case iPhone11Pro
        case iPhone11ProMax
        case iPhone12Mini
        case iPhone12
        case iPhone12Pro
        case iPhone12ProMax
        case iPhone13Mini
        case iPhone13
        case iPhone13Pro
        case iPhone13ProMax
        case iPhone14
        case iPhone14Plus
        case iPhone14Pro
        case iPhone14ProMax
        case iPhoneSE
        case iPhoneSE2ndGeneration
        case iPhoneSE3rdGeneration
        case iPad2
        case iPad3rdGeneration
        case iPad4thGeneration
        case iPad5thGeneration
        case iPad6thGeneration
        case iPad7thGeneration
        case iPad8thGeneration
        case iPad9thGeneration
        case iPad10thGeneration
        case iPadAir
        case iPadAir2
        case iPadAir3rdGeneration
        case iPadAir4thGeneration
        case iPadAir5thGeneration
        case iPadMini
        case iPadMini2
        case iPadMini3
        case iPadMini4
        case iPadMini5thGeneration
        case iPadMini6thGeneration
        case iPadPro9_7Inch
        case iPadPro10_5Inch
        case iPadPro11Inch1stGeneration
        case iPadPro11Inch2ndGeneration
        case iPadPro11Inch3rdGeneration
        case iPadPro11Inch4thGeneration
        case iPadPro12_9Inch1stGeneration
        case iPadPro12_9Inch2ndGeneration
        case iPadPro12_9Inch3rdGeneration
        case iPadPro12_9Inch4thGeneration
        case iPadPro12_9Inch5thGeneration
        case iPadPro12_9Inch6thGeneration
        case appleTV
        case appleTV4K
        case homePod
        case homePodMini
        case unknown
    }
    
    var deviceModel :DeviceModel {
        var aReturnVal = DeviceModel.unknown
        
        var aDeviceModelIdentifier: String? = nil
        if self.isMac {
            // TODO: Implement mac model identifier
            aDeviceModelIdentifier = nil
        } else if self.isSimulator {
            aDeviceModelIdentifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"]
        } else {
            var aSystemInfo = utsname()
            uname(&aSystemInfo)
            let aModelIdentifier = withUnsafePointer(to: &aSystemInfo.machine) {
                $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                    aPointer in String.init(validatingUTF8: aPointer)
                }
            }
            aDeviceModelIdentifier = aModelIdentifier
        }
        
        switch aDeviceModelIdentifier {
        case "iPod5,1":
            aReturnVal = .iPodTouch5thGeneration
        case "iPod7,1":
            aReturnVal = .iPodTouch6thGeneration
        case "iPod9,1":
            aReturnVal = .iPodTouch7thGeneration
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":
            aReturnVal = .iPhone4
        case "iPhone4,1":
            aReturnVal = .iPhone4s
        case "iPhone5,1", "iPhone5,2":
            aReturnVal = .iPhone5
        case "iPhone5,3", "iPhone5,4":
            aReturnVal = .iPhone5c
        case "iPhone6,1", "iPhone6,2":
            aReturnVal = .iPhone5s
        case "iPhone7,2":
            aReturnVal = .iPhone6
        case "iPhone7,1":
            aReturnVal = .iPhone6Plus
        case "iPhone8,1":
            aReturnVal = .iPhone6s
        case "iPhone8,2":
            aReturnVal = .iPhone6sPlus
        case "iPhone9,1", "iPhone9,3":
            aReturnVal = .iPhone7
        case "iPhone9,2", "iPhone9,4":
            aReturnVal = .iPhone7Plus
        case "iPhone10,1", "iPhone10,4":
            aReturnVal = .iPhone8
        case "iPhone10,2", "iPhone10,5":
            aReturnVal = .iPhone8Plus
        case "iPhone10,3", "iPhone10,6":
            aReturnVal = .iPhoneX
        case "iPhone11,2":
            aReturnVal = .iPhoneXS
        case "iPhone11,4", "iPhone11,6":
            aReturnVal = .iPhoneXSMax
        case "iPhone11,8":
            aReturnVal = .iPhoneXR
        case "iPhone12,1":
            aReturnVal = .iPhone11
        case "iPhone12,3":
            aReturnVal = .iPhone11Pro
        case "iPhone12,5":
            aReturnVal = .iPhone11ProMax
        case "iPhone13,1":
            aReturnVal = .iPhone12Mini
        case "iPhone13,2":
            aReturnVal = .iPhone12
        case "iPhone13,3":
            aReturnVal = .iPhone12Pro
        case "iPhone13,4":
            aReturnVal = .iPhone12ProMax
        case "iPhone14,4":
            aReturnVal = .iPhone13Mini
        case "iPhone14,5":
            aReturnVal = .iPhone13
        case "iPhone14,2":
            aReturnVal = .iPhone13Pro
        case "iPhone14,3":
            aReturnVal = .iPhone13ProMax
        case "iPhone14,7":
            aReturnVal = .iPhone14
        case "iPhone14,8":
            aReturnVal = .iPhone14Plus
        case "iPhone15,2":
            aReturnVal = .iPhone14Pro
        case "iPhone15,3":
            aReturnVal = .iPhone14ProMax
        case "iPhone8,4":
            aReturnVal = .iPhoneSE
        case "iPhone12,8":
            aReturnVal = .iPhoneSE2ndGeneration
        case "iPhone14,6":
            aReturnVal = .iPhoneSE3rdGeneration
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":
            aReturnVal = .iPad2
        case "iPad3,1", "iPad3,2", "iPad3,3":
            aReturnVal = .iPad3rdGeneration
        case "iPad3,4", "iPad3,5", "iPad3,6":
            aReturnVal = .iPad4thGeneration
        case "iPad6,11", "iPad6,12":
            aReturnVal = .iPad5thGeneration
        case "iPad7,5", "iPad7,6":
            aReturnVal = .iPad6thGeneration
        case "iPad7,11", "iPad7,12":
            aReturnVal = .iPad7thGeneration
        case "iPad11,6", "iPad11,7":
            aReturnVal = .iPad8thGeneration
        case "iPad12,1", "iPad12,2":
            aReturnVal = .iPad9thGeneration
        case "iPad13,18", "iPad13,19":
            aReturnVal = .iPad10thGeneration
        case "iPad4,1", "iPad4,2", "iPad4,3":
            aReturnVal = .iPadAir
        case "iPad5,3", "iPad5,4":
            aReturnVal = .iPadAir2
        case "iPad11,3", "iPad11,4":
            aReturnVal = .iPadAir3rdGeneration
        case "iPad13,1", "iPad13,2":
            aReturnVal = .iPadAir4thGeneration
        case "iPad13,16", "iPad13,17":
            aReturnVal = .iPadAir5thGeneration
        case "iPad2,5", "iPad2,6", "iPad2,7":
            aReturnVal = .iPadMini
        case "iPad4,4", "iPad4,5", "iPad4,6":
            aReturnVal = .iPadMini2
        case "iPad4,7", "iPad4,8", "iPad4,9":
            aReturnVal = .iPadMini3
        case "iPad5,1", "iPad5,2":
            aReturnVal = .iPadMini4
        case "iPad11,1", "iPad11,2":
            aReturnVal = .iPadMini5thGeneration
        case "iPad14,1", "iPad14,2":
            aReturnVal = .iPadMini6thGeneration
        case "iPad6,3", "iPad6,4":
            aReturnVal = .iPadPro9_7Inch
        case "iPad7,3", "iPad7,4":
            aReturnVal = .iPadPro10_5Inch
        case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":
            aReturnVal = .iPadPro11Inch1stGeneration
        case "iPad8,9", "iPad8,10":
            aReturnVal = .iPadPro11Inch2ndGeneration
        case "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7":
            aReturnVal = .iPadPro11Inch3rdGeneration
        case "iPad14,3-A", "iPad14,3-B", "iPad14,4-A", "iPad14,4-B":
            aReturnVal = .iPadPro11Inch4thGeneration
        case "iPad6,7", "iPad6,8":
            aReturnVal = .iPadPro12_9Inch1stGeneration
        case "iPad7,1", "iPad7,2":
            aReturnVal = .iPadPro12_9Inch2ndGeneration
        case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":
            aReturnVal = .iPadPro12_9Inch3rdGeneration
        case "iPad8,11", "iPad8,12":
            aReturnVal = .iPadPro12_9Inch4thGeneration
        case "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11":
            aReturnVal = .iPadPro12_9Inch5thGeneration
        case "iPad14,5-A", "iPad14,5-B", "iPad14,6-A", "iPad14,6-B":
            aReturnVal = .iPadPro12_9Inch6thGeneration
        case "AppleTV5,3":
            aReturnVal = .appleTV
        case "AppleTV6,2":
            aReturnVal = .appleTV4K
        case "AudioAccessory1,1":
            aReturnVal = .homePod
        case "AudioAccessory5,1":
            aReturnVal = .homePodMini
        default:
            break
        }
        
        return aReturnVal
    }
    
    
    enum DeviceSizeType {
        case iPhone1To4S // 3.5"
        case iPhone5Series // 4"
        case iPhone6To8AndSE // 4.7", 4" (SE1)
        case iPhone6PlusTo8Plus // 5.5"
        case iPhoneFullScreenSeries
        case iPhoneFullScreenMaxSeries
        case iPhoneFullScreenMiniSeries
        case iPadSeries
        case iPadMiniSeries
        case unknown
    }
    
    var deviceSizeType :DeviceSizeType {
        var aReturnVal = DeviceSizeType.unknown
        
        switch self.deviceModel {
        case .iPodTouch5thGeneration
            , .iPodTouch6thGeneration
            , .iPodTouch7thGeneration:
            aReturnVal = .iPhone1To4S
        case .iPhone4
            , .iPhone4s:
            aReturnVal = .iPhone1To4S
        case .iPhone5
            , .iPhone5c
            ,.iPhone5s:
            aReturnVal = .iPhone5Series
        case .iPhone6
            , .iPhone6s
            , .iPhone7
            , .iPhone8:
            aReturnVal = .iPhone6To8AndSE
        case .iPhone6Plus
            , .iPhone6sPlus
            , .iPhone7Plus
            , .iPhone8Plus
            , .iPhoneSE
            , .iPhoneSE2ndGeneration
            , .iPhoneSE3rdGeneration:
            aReturnVal = .iPhone6PlusTo8Plus
        case .iPhoneX
            , .iPhoneXS
            , .iPhoneXR
            , .iPhone11
            , .iPhone11Pro
            , .iPhone12
            , .iPhone12Pro
            , .iPhone13
            , .iPhone13Pro
            , .iPhone14
            , .iPhone14Pro:
            aReturnVal = .iPhoneFullScreenSeries
        case .iPhoneXSMax
            , .iPhone11ProMax
            , .iPhone12ProMax
            , .iPhone13ProMax
            , .iPhone14Plus
            , .iPhone14ProMax:
            aReturnVal = .iPhoneFullScreenMaxSeries
        case .iPhone12Mini
            , .iPhone13Mini:
            aReturnVal = .iPhoneFullScreenMiniSeries
        case .iPad2
            , .iPad3rdGeneration
            , .iPad4thGeneration
            , .iPad5thGeneration
            , .iPad6thGeneration
            , .iPad7thGeneration
            , .iPad8thGeneration
            , .iPad9thGeneration
            , .iPad10thGeneration
            , .iPadAir
            , .iPadAir2
            , .iPadAir3rdGeneration
            , .iPadAir4thGeneration
            , .iPadAir5thGeneration:
            aReturnVal = .iPadSeries
        case .iPadMini
            , .iPadMini2
            , .iPadMini3
            , .iPadMini4
            , .iPadMini5thGeneration
            , .iPadMini6thGeneration
            , .iPadPro9_7Inch
            , .iPadPro10_5Inch
            , .iPadPro11Inch1stGeneration
            , .iPadPro11Inch2ndGeneration
            , .iPadPro11Inch3rdGeneration
            , .iPadPro11Inch4thGeneration:
            aReturnVal = .iPadMiniSeries
        case .iPadPro12_9Inch1stGeneration
            , .iPadPro12_9Inch2ndGeneration
            , .iPadPro12_9Inch3rdGeneration
            , .iPadPro12_9Inch4thGeneration
            , .iPadPro12_9Inch5thGeneration
            , .iPadPro12_9Inch6thGeneration:
            aReturnVal = .iPadMiniSeries
        case .appleTV
            , .appleTV4K
            , .homePod
            , .homePodMini
            , .unknown:
            aReturnVal = .unknown
        }
        
        return aReturnVal
    }
    
}
